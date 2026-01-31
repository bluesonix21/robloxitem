import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../../core/services/asset_repository.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_services.dart';
import '../../data/models/asset_model.dart';
import '../../data/models/credit_model.dart';
import '../../data/models/job_model.dart';

// ============================================================================
// Core Providers
// ============================================================================

/// Supabase client provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// API Config provider
final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig();
});

/// Current session provider (for API auth)
final sessionProvider = StreamProvider<Session?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session);
});

/// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  ref.watch(apiConfigProvider);
  final session = ref.watch(sessionProvider).maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
  final client = ApiClient();
  final token = session?.accessToken;
  if (token != null && token.isNotEmpty) {
    client.setAuthToken(token);
  }
  return client;
});

/// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Auth state provider
final authStateProvider = Provider<AsyncValue<User?>>((ref) {
  return ref.watch(currentUserProvider);
});

// ============================================================================
// Service Providers
// ============================================================================

/// Job service provider
final jobServiceProvider = Provider<JobService>((ref) {
  final client = ref.watch(apiClientProvider);
  return JobService(client);
});

/// Credit service provider
final creditServiceProvider = Provider<CreditService>((ref) {
  final client = ref.watch(apiClientProvider);
  return CreditService(client);
});

/// Premium purchase service provider
final premiumServiceProvider = Provider<PremiumService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PremiumService(client);
});

/// Account service provider
final accountServiceProvider = Provider<AccountService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AccountService(client);
});

/// Asset service provider
final assetServiceProvider = Provider<AssetService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AssetService(client);
});

/// Asset repository provider (Supabase queries)
final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AssetRepository(supabase);
});

/// Storage service provider (TUS uploads)
final storageServiceProvider = Provider<StorageService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return StorageService(supabase);
});

/// Roblox service provider
final robloxServiceProvider = Provider<RobloxService>((ref) {
  final client = ref.watch(apiClientProvider);
  return RobloxService(client);
});

// ============================================================================
// Credit Providers
// ============================================================================

/// User credits state
class CreditsNotifier extends StateNotifier<AsyncValue<CreditBalance>> {
  final CreditService _service;

  CreditsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.getCredits();
      if (result.isError || result.data == null) {
        throw Exception(result.error ?? 'Credits error');
      }
      final response = result.data!;
      final transactions = response.ledger.map((entry) {
        CreditTransactionType type;
        switch (entry.reason.toUpperCase()) {
          case 'REFUND':
            type = CreditTransactionType.refund;
            break;
          case 'ADJUSTMENT':
            type = CreditTransactionType.bonus;
            break;
          case 'RESERVE':
          default:
            type = CreditTransactionType.aiGeneration;
            break;
        }
        return CreditTransaction(
          id: entry.id,
          amount: entry.amount,
          type: type,
          description: entry.reason,
          referenceId: entry.id,
          createdAt: entry.createdAt,
        );
      }).toList();
      final balance = CreditBalance(
        balance: response.balance,
        transactions: transactions,
        lastUpdated: DateTime.now(),
      );
      state = AsyncValue.data(balance);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _loadCredits();

  void deduct(int amount) {
    state.whenData((balance) {
      state = AsyncValue.data(CreditBalance(
        balance: balance.balance - amount,
        transactions: balance.transactions,
        lastUpdated: DateTime.now(),
      ));
    });
  }
}

final creditsProvider =
    StateNotifierProvider<CreditsNotifier, AsyncValue<CreditBalance>>((ref) {
  final service = ref.watch(creditServiceProvider);
  return CreditsNotifier(service);
});

// ============================================================================
// Asset Providers
// ============================================================================

final userAssetsProvider = FutureProvider.autoDispose<List<Asset>>((ref) async {
  final repo = ref.watch(assetRepositoryProvider);
  return repo.fetchUserAssets();
});

final publicAssetsProvider = FutureProvider.autoDispose<List<Asset>>((ref) async {
  final repo = ref.watch(assetRepositoryProvider);
  return repo.fetchPublicAssets();
});

final searchAssetsProvider =
    FutureProvider.family.autoDispose<List<Asset>, String>((ref, query) async {
  final repo = ref.watch(assetRepositoryProvider);
  return repo.searchAssets(query, publicOnly: true);
});

// ============================================================================
// Job Providers
// ============================================================================

/// Active jobs state
class JobsNotifier extends StateNotifier<List<Job>> {
  final JobService _service;
  final Ref _ref;
  StreamSubscription<List<Map<String, dynamic>>>? _jobSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  JobsNotifier(this._service, this._ref) : super([]) {
    _initRealtime();
  }

  void _initRealtime() {
    final supabase = _ref.read(supabaseProvider);
    _startJobStream(supabase.auth.currentUser?.id);
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      _startJobStream(event.session?.user.id);
    });
  }

  void _startJobStream(String? userId) {
    _jobSubscription?.cancel();
    if (userId == null || userId.isEmpty) {
      state = [];
      return;
    }

    final supabase = _ref.read(supabaseProvider);
    _jobSubscription = supabase
        .from('ai_jobs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((rows) {
      if (rows.isEmpty) return;
      final incoming = rows
          .whereType<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList();
      final merged = <String, Job>{};
      for (final job in state) {
        merged[job.id] = job;
      }
      for (final job in incoming) {
        merged[job.id] = job;
      }
      final ordered = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = ordered;
    });
  }

  /// Create a new AI generation job
  Future<Job?> createJob({
    required String prompt,
    required AIProvider provider,
    String? negativePrompt,
    String style = 'realistic',
  }) async {
    try {
      final result = await _service.createJob(
        prompt: prompt,
        provider: provider.name,
        negativePrompt: negativePrompt,
        style: style,
      );
      if (result.isError || result.data == null) {
        return null;
      }
      final response = result.data!;

      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final job = Job(
        id: response.jobId,
        userId: userId,
        assetId: response.assetId,
        prompt: prompt,
        status: JobStatus.queued,
        stage: JobStage.preview,
        provider: provider,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      state = [...state, job];

      // Deduct credits
      _ref.read(creditsProvider.notifier).deduct(response.creditCost);

      // Start polling for status
      _pollJob(job);

      return job;
    } catch (e) {
      return null;
    }
  }

  /// Poll job status until complete
  Future<void> _pollJob(Job job) async {
    const maxPolls = 60; // 5 minutes with 5 second intervals
    const pollInterval = Duration(seconds: 5);

    for (int i = 0; i < maxPolls; i++) {
      await Future.delayed(pollInterval);

      try {
        if (job.provider == AIProvider.meshy) {
          await _service.pollMeshyJob(job.id);
        } else {
          await _service.pollTripoJob(job.id);
        }

        final result = await _service.getJobStatus(job.id);
        if (result.isError || result.data == null) {
          continue;
        }
        final response = result.data!;

        // Update job in state
        state = state.map((j) {
          if (j.id == job.id) {
            return response.job;
          }
          return j;
        }).toList();

        // Check if job is complete
        if (response.job.isComplete || response.job.isFailed) {
          break;
        }
      } catch (e) {
        // Continue polling on error
      }
    }
  }

  /// Cancel a job
  Future<bool> cancelJob(String jobId) async {
    try {
      final result = await _service.cancelJob(jobId);
      if (result.isSuccess) {
        state = state.map((j) {
          if (j.id == jobId) {
            return j.copyWith(status: JobStatus.cancelled);
          }
          return j;
        }).toList();
      }
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Get job by ID
  Job? getJob(String jobId) {
    try {
      return state.firstWhere((j) => j.id == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Remove completed jobs
  void clearCompleted() {
    state = state.where((j) => !j.isComplete && !j.isFailed).toList();
  }

  @override
  void dispose() {
    _jobSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}

final jobsProvider = StateNotifierProvider<JobsNotifier, List<Job>>((ref) {
  final service = ref.watch(jobServiceProvider);
  return JobsNotifier(service, ref);
});

/// Currently selected job provider
final selectedJobProvider = StateProvider<Job?>((ref) => null);

/// Active jobs count
final activeJobsCountProvider = Provider<int>((ref) {
  final jobs = ref.watch(jobsProvider);
  return jobs.where((j) => j.isInProgress).length;
});

// ============================================================================
// UI State Providers
// ============================================================================

/// Current bottom navigation index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Editor state
class EditorState {
  final bool showGrid;
  final double zoom;
  final bool showLayers;
  final String? selectedLayerId;

  const EditorState({
    this.showGrid = true,
    this.zoom = 1.0,
    this.showLayers = false,
    this.selectedLayerId,
  });

  EditorState copyWith({
    bool? showGrid,
    double? zoom,
    bool? showLayers,
    String? selectedLayerId,
  }) {
    return EditorState(
      showGrid: showGrid ?? this.showGrid,
      zoom: zoom ?? this.zoom,
      showLayers: showLayers ?? this.showLayers,
      selectedLayerId: selectedLayerId ?? this.selectedLayerId,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier() : super(const EditorState());

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.5, 3.0));
  }

  void zoomIn() {
    setZoom(state.zoom + 0.25);
  }

  void zoomOut() {
    setZoom(state.zoom - 0.25);
  }

  void toggleLayers() {
    state = state.copyWith(showLayers: !state.showLayers);
  }

  void selectLayer(String? layerId) {
    state = state.copyWith(selectedLayerId: layerId);
  }

  void reset() {
    state = const EditorState();
  }
}

final editorProvider =
    StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});

// ============================================================================
// Search & Filter Providers
// ============================================================================

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Selected AI provider for generation
final selectedAIProviderProvider = StateProvider<AIProvider>((ref) {
  return AIProvider.meshy;
});

// ============================================================================
// Theme Provider
// ============================================================================

/// Dark mode state
final darkModeProvider = StateProvider<bool>((ref) => false);

// ============================================================================
// Roblox Integration Providers
// ============================================================================

/// Roblox connection state
class RobloxConnectionState {
  final bool isConnected;
  final String? username;
  final String? avatarUrl;
  final String? robloxUserId;
  final DateTime? connectedAt;

  const RobloxConnectionState({
    this.isConnected = false,
    this.username,
    this.avatarUrl,
    this.robloxUserId,
    this.connectedAt,
  });

  RobloxConnectionState copyWith({
    bool? isConnected,
    String? username,
    String? avatarUrl,
    String? robloxUserId,
    DateTime? connectedAt,
  }) {
    return RobloxConnectionState(
      isConnected: isConnected ?? this.isConnected,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      robloxUserId: robloxUserId ?? this.robloxUserId,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }
}

class RobloxConnectionNotifier extends StateNotifier<RobloxConnectionState> {
  final RobloxService _service;

  RobloxConnectionNotifier(this._service)
      : super(const RobloxConnectionState());

  Future<String?> startOAuth() async {
    try {
      final result = await _service.startOAuth();
      if (result.isSuccess) {
        return result.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadProfile() async {
    try {
      final result = await _service.getProfile();
      if (result.isError || result.data == null) {
        return;
      }
      final profile = result.data!;
      if (!profile.connected) {
        state = const RobloxConnectionState();
        return;
      }
      state = state.copyWith(
        isConnected: true,
        username: profile.username ?? state.username,
        avatarUrl: profile.avatarUrl ?? state.avatarUrl,
        robloxUserId: profile.robloxUserId ?? state.robloxUserId,
        connectedAt: state.connectedAt ?? DateTime.now(),
      );
    } catch (e) {
      // Keep existing state on error
    }
  }

  void setConnected({
    String? username,
    String? avatarUrl,
    String? robloxUserId,
  }) {
    state = state.copyWith(
      isConnected: true,
      username: username,
      avatarUrl: avatarUrl,
      robloxUserId: robloxUserId,
      connectedAt: DateTime.now(),
    );
  }

  void disconnect() {
    state = const RobloxConnectionState();
  }
}

final robloxConnectionProvider =
    StateNotifierProvider<RobloxConnectionNotifier, RobloxConnectionState>(
        (ref) {
  final service = ref.watch(robloxServiceProvider);
  return RobloxConnectionNotifier(service);
});

// ============================================================================
// Publish State Providers
// ============================================================================

/// Publishing state for an asset
enum PublishStatus { idle, publishing, success, failed }

class PublishState {
  final PublishStatus status;
  final String? publishJobId;
  final String? error;
  final double progress;

  const PublishState({
    this.status = PublishStatus.idle,
    this.publishJobId,
    this.error,
    this.progress = 0.0,
  });

  PublishState copyWith({
    PublishStatus? status,
    String? publishJobId,
    String? error,
    double? progress,
  }) {
    return PublishState(
      status: status ?? this.status,
      publishJobId: publishJobId ?? this.publishJobId,
      error: error ?? this.error,
      progress: progress ?? this.progress,
    );
  }
}

class PublishNotifier extends StateNotifier<PublishState> {
  final RobloxService _service;

  PublishNotifier(this._service) : super(const PublishState());

  Future<bool> publish({
    required String assetId,
    required String name,
    required String description,
    required String assetType,
    required int creatorUserId,
  }) async {
    state = state.copyWith(status: PublishStatus.publishing, progress: 0.0);

    try {
      final result = await _service.publishAsset(
        assetId: assetId,
        name: name,
        description: description,
        assetType: assetType,
        creatorUserId: creatorUserId,
      );
      if (result.isError || result.data == null) {
        state = state.copyWith(
          status: PublishStatus.failed,
          error: result.error ?? 'Publish failed',
        );
        return false;
      }
      final response = result.data!;
      state = state.copyWith(publishJobId: response.publishJobId, progress: 0.2);

      // Poll for completion
      return await _pollPublishStatus(response.publishJobId);
    } catch (e) {
      state = state.copyWith(
        status: PublishStatus.failed,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> _pollPublishStatus(String publishJobId) async {
    const maxPolls = 30;
    const pollInterval = Duration(seconds: 2);

    for (int i = 0; i < maxPolls; i++) {
      await Future.delayed(pollInterval);

      try {
        final result = await _service.getPublishStatus(publishJobId);
        if (result.isError || result.data == null) {
          continue;
        }
        final response = result.data!;

        state = state.copyWith(progress: 0.2 + (i / maxPolls) * 0.8);

        if (response.status == 'PUBLISHED') {
          state = state.copyWith(
            status: PublishStatus.success,
            progress: 1.0,
          );
          return true;
        }

        if (response.status == 'FAILED') {
          state = state.copyWith(
            status: PublishStatus.failed,
            error: response.error,
          );
          return false;
        }
      } catch (e) {
        // Continue polling on error
      }
    }

    state = state.copyWith(
      status: PublishStatus.failed,
      error: 'Publish timeout',
    );
    return false;
  }

  void reset() {
    state = const PublishState();
  }
}

final publishProvider =
    StateNotifierProvider<PublishNotifier, PublishState>((ref) {
  final service = ref.watch(robloxServiceProvider);
  return PublishNotifier(service);
});

// ============================================================================
// OAuth Callback State
// ============================================================================

enum OAuthStatus { idle, success, error }

class OAuthState {
  final OAuthStatus status;
  final String? message;

  const OAuthState({this.status = OAuthStatus.idle, this.message});

  OAuthState copyWith({OAuthStatus? status, String? message}) {
    return OAuthState(
      status: status ?? this.status,
      message: message,
    );
  }
}

class RobloxOAuthNotifier extends StateNotifier<OAuthState> {
  RobloxOAuthNotifier() : super(const OAuthState());

  void success() => state = const OAuthState(status: OAuthStatus.success);

  void error(String? message) =>
      state = OAuthState(status: OAuthStatus.error, message: message);

  void reset() => state = const OAuthState();
}

final robloxOAuthProvider =
    StateNotifierProvider<RobloxOAuthNotifier, OAuthState>((ref) {
  return RobloxOAuthNotifier();
});
