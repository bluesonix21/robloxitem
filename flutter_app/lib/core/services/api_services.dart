import '../api/api_client.dart';
import '../api/api_config.dart';
import '../../data/models/job_model.dart';

/// Service for AI job creation and management
class JobService {
  final ApiClient _client;

  JobService(this._client);

  /// Create a new AI generation job
  /// 
  /// [prompt] - Text description of the 3D model
  /// [provider] - AI provider ('MESHY' or 'TRIPO')
  /// [createAsset] - Whether to create an asset record
  /// [assetTitle] - Title for the asset
  /// [assetDescription] - Description for the asset
  Future<ApiResult<JobCreateResponse>> createJob({
    required String prompt,
    String provider = 'MESHY',
    bool createAsset = true,
    String? assetTitle,
    String? assetDescription,
    String? negativePrompt,
    String? style,
  }) async {
    final preview = <String, dynamic>{
      'prompt': prompt,
      if (negativePrompt != null && negativePrompt.isNotEmpty)
        'negative_prompt': negativePrompt,
      if (style != null && style.isNotEmpty) 'art_style': style,
    };
    final result = await _client.post(
      ApiConfig.jobCreate,
      body: {
        'preview': preview,
        'prompt': prompt,
        'provider': provider,
        'create_asset': createAsset,
        if (assetTitle != null) 'asset_title': assetTitle,
        if (assetDescription != null) 'asset_description': assetDescription,
      },
      timeout: ApiConfig.longRequestTimeout,
    );

    if (result.isSuccess && result.data != null) {
      return ApiResult.success(JobCreateResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to create job');
  }

  /// Get job status with events
  Future<ApiResult<JobStatusResponse>> getJobStatus(String jobId) async {
    final result = await _client.get(
      ApiConfig.jobStatus,
      queryParams: {'job_id': jobId},
    );

    if (result.isSuccess && result.data != null) {
      return ApiResult.success(JobStatusResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to get job status');
  }

  /// Poll Meshy job for updates
  Future<ApiResult<JobPollResponse>> pollMeshyJob(String jobId) async {
    final result = await _client.get(
      ApiConfig.meshyPoll,
      queryParams: {'job_id': jobId},
    );

    if (result.isSuccess && result.data != null) {
      return ApiResult.success(JobPollResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to poll job');
  }

  /// Poll Tripo job for updates
  Future<ApiResult<JobPollResponse>> pollTripoJob(String jobId) async {
    final result = await _client.get(
      ApiConfig.tripoPoll,
      queryParams: {'job_id': jobId},
    );

    if (result.isSuccess && result.data != null) {
      return ApiResult.success(JobPollResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to poll job');
  }

  /// Cancel a job
  Future<ApiResult<void>> cancelJob(String jobId) async {
    final result = await _client.post(
      ApiConfig.jobCancel,
      body: {'job_id': jobId},
    );

    if (result.isSuccess) {
      return ApiResult.success(null);
    }
    return ApiResult.error(result.error ?? 'Failed to cancel job');
  }
}

/// Service for asset management
class AssetService {
  final ApiClient _client;

  AssetService(this._client);

  /// Fetch asset details with URLs
  Future<ApiResult<AssetFetchResponse>> fetchAsset(String assetId) async {
    final result = await _client.get(
      ApiConfig.assetFetch,
      queryParams: {'id': assetId},
    );

    if (result.isSuccess && result.data != null) {
      return ApiResult.success(AssetFetchResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to fetch asset');
  }
}

/// Service for credits management
class CreditService {
  final ApiClient _client;

  CreditService(this._client);

  /// Get user's credit balance and ledger
  Future<ApiResult<CreditResponse>> getCredits() async {
    final result = await _client.get(ApiConfig.credits);

    if (result.isSuccess && result.data != null) {
      return ApiResult.success(CreditResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to get credits');
  }
}

/// Service for premium purchase
class PremiumService {
  final ApiClient _client;

  PremiumService(this._client);

  Future<ApiResult<PremiumCheckoutResponse>> createCheckout({
    required String planId,
  }) async {
    final result = await _client.post(
      ApiConfig.premiumCheckout,
      body: {'plan_id': planId},
    );
    if (result.isSuccess && result.data != null) {
      return ApiResult.success(PremiumCheckoutResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to create checkout');
  }
}

/// Service for account actions
class AccountService {
  final ApiClient _client;

  AccountService(this._client);

  Future<ApiResult<void>> deleteAccount() async {
    final result = await _client.post(ApiConfig.deleteAccount);
    if (result.isSuccess) {
      return ApiResult.success(null);
    }
    return ApiResult.error(result.error ?? 'Account deletion failed');
  }
}

/// Service for Roblox integration
class RobloxService {
  final ApiClient _client;

  RobloxService(this._client);

  /// Start Roblox OAuth flow
  Future<ApiResult<String>> startOAuth() async {
    final result = await _client.post(ApiConfig.robloxOAuthStart);

    if (result.isSuccess && result.data != null) {
      final authorizeUrl = result.data!['authorize_url'] as String?;
      if (authorizeUrl != null) {
        return ApiResult.success(authorizeUrl);
      }
    }
    return ApiResult.error(result.error ?? 'Failed to start OAuth');
  }

  /// Publish asset to Roblox
  Future<ApiResult<PublishResponse>> publishAsset({
    required String assetId,
    required String name,
    required String description,
    required String assetType,
    required int creatorUserId,
  }) async {
    final result = await _client.post(
      ApiConfig.robloxPublish,
      body: {
        'asset_id': assetId,
        'name': name,
        'description': description,
        'asset_type': assetType,
        'creator_user_id': creatorUserId,
      },
    );

    if (result.isSuccess && result.data != null) {
      return ApiResult.success(PublishResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to publish asset');
  }

  /// Get publish job status
  Future<ApiResult<PublishStatusResponse>> getPublishStatus(String publishJobId) async {
    final result = await _client.get(
      ApiConfig.robloxPublishStatus,
      queryParams: {'publish_job_id': publishJobId},
    );

    if (result.isSuccess && result.data != null) {
      return ApiResult.success(PublishStatusResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to get publish status');
  }

  /// Fetch Roblox profile info stored for the user
  Future<ApiResult<RobloxProfileResponse>> getProfile() async {
    final result = await _client.get(ApiConfig.robloxProfile);
    if (result.isSuccess && result.data != null) {
      return ApiResult.success(RobloxProfileResponse.fromJson(result.data!));
    }
    return ApiResult.error(result.error ?? 'Failed to fetch Roblox profile');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESPONSE MODELS
// ═══════════════════════════════════════════════════════════════════════════

class JobCreateResponse {
  final String jobId;
  final String? assetId;
  final int creditCost;
  final int balance;

  JobCreateResponse({
    required this.jobId,
    this.assetId,
    required this.creditCost,
    required this.balance,
  });

  factory JobCreateResponse.fromJson(Map<String, dynamic> json) {
    return JobCreateResponse(
      jobId: json['job_id'] as String,
      assetId: json['asset_id'] as String?,
      creditCost: json['credit_cost'] as int? ?? 0,
      balance: json['balance'] as int? ?? 0,
    );
  }
}

class JobStatusResponse {
  final Job job;
  final List<JobEvent> events;

  JobStatusResponse({
    required this.job,
    required this.events,
  });

  factory JobStatusResponse.fromJson(Map<String, dynamic> json) {
    final jobJson = json['job'] as Map<String, dynamic>;
    return JobStatusResponse(
      job: Job.fromJson(jobJson),
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => JobEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class JobEvent {
  final String stage;
  final String status;
  final String? providerTaskId;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;

  JobEvent({
    required this.stage,
    required this.status,
    this.providerTaskId,
    this.payload,
    required this.createdAt,
  });

  factory JobEvent.fromJson(Map<String, dynamic> json) {
    return JobEvent(
      stage: json['stage'] as String? ?? '',
      status: json['status'] as String? ?? '',
      providerTaskId: json['provider_task_id'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class JobPollResponse {
  final String jobId;
  final String status;
  final String? stage;

  JobPollResponse({
    required this.jobId,
    required this.status,
    this.stage,
  });

  factory JobPollResponse.fromJson(Map<String, dynamic> json) {
    return JobPollResponse(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      stage: json['stage'] as String?,
    );
  }
}

class AssetFetchResponse {
  final String id;
  final String? meshUrl;
  final String? textureUrl;
  final String? pbrMetalnessUrl;
  final String? pbrRoughnessUrl;
  final String? pbrNormalUrl;

  AssetFetchResponse({
    required this.id,
    this.meshUrl,
    this.textureUrl,
    this.pbrMetalnessUrl,
    this.pbrRoughnessUrl,
    this.pbrNormalUrl,
  });

  factory AssetFetchResponse.fromJson(Map<String, dynamic> json) {
    return AssetFetchResponse(
      id: json['id'] as String,
      meshUrl: json['mesh_url'] as String?,
      textureUrl: json['texture_url'] as String?,
      pbrMetalnessUrl: json['pbr_metalness_url'] as String?,
      pbrRoughnessUrl: json['pbr_roughness_url'] as String?,
      pbrNormalUrl: json['pbr_normal_url'] as String?,
    );
  }
}

class CreditResponse {
  final int balance;
  final List<CreditLedgerEntry> ledger;

  CreditResponse({
    required this.balance,
    required this.ledger,
  });

  factory CreditResponse.fromJson(Map<String, dynamic> json) {
    final account = json['account'] as Map<String, dynamic>?;
    return CreditResponse(
      balance: account != null
          ? account['balance'] as int? ?? 0
          : (json['balance'] as int? ?? 0),
      ledger: (json['ledger'] as List<dynamic>?)
              ?.map((e) => CreditLedgerEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CreditLedgerEntry {
  final String id;
  final int amount;
  final String reason;
  final DateTime createdAt;

  CreditLedgerEntry({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  factory CreditLedgerEntry.fromJson(Map<String, dynamic> json) {
    return CreditLedgerEntry(
      id: json['id'] as String,
      amount: json['amount'] as int,
      reason: json['reason'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class PremiumCheckoutResponse {
  final String checkoutUrl;

  PremiumCheckoutResponse({required this.checkoutUrl});

  factory PremiumCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return PremiumCheckoutResponse(
      checkoutUrl: json['checkout_url'] as String,
    );
  }
}

class PublishResponse {
  final String publishJobId;
  final String? operationId;

  PublishResponse({
    required this.publishJobId,
    this.operationId,
  });

  factory PublishResponse.fromJson(Map<String, dynamic> json) {
    return PublishResponse(
      publishJobId: json['publish_job_id'] as String,
      operationId: json['operation_id'] as String?,
    );
  }
}

class PublishStatusResponse {
  final String status;
  final int? robloxAssetId;
  final String? error;

  PublishStatusResponse({
    required this.status,
    this.robloxAssetId,
    this.error,
  });

  factory PublishStatusResponse.fromJson(Map<String, dynamic> json) {
    final rawAssetId = json['roblox_asset_id'];
    return PublishStatusResponse(
      status: json['status'] as String,
      robloxAssetId: rawAssetId is num ? rawAssetId.toInt() : null,
      error: json['error'] as String?,
    );
  }
}

class RobloxProfileResponse {
  final bool connected;
  final String? robloxUserId;
  final String? username;
  final String? avatarUrl;

  RobloxProfileResponse({
    required this.connected,
    this.robloxUserId,
    this.username,
    this.avatarUrl,
  });

  factory RobloxProfileResponse.fromJson(Map<String, dynamic> json) {
    return RobloxProfileResponse(
      connected: json['connected'] as bool? ?? false,
      robloxUserId: json['roblox_user_id'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
