/// Job status enum
enum JobStatus {
  queued,
  submitted,
  inProgress,
  succeeded,
  failed,
  cancelled,
}

extension JobStatusExtension on JobStatus {
  String get displayName {
    switch (this) {
      case JobStatus.queued:
        return 'Kuyrukta';
      case JobStatus.submitted:
        return 'Gönderildi';
      case JobStatus.inProgress:
        return 'İşleniyor';
      case JobStatus.succeeded:
        return 'Tamamlandı';
      case JobStatus.failed:
        return 'Başarısız';
      case JobStatus.cancelled:
        return 'İptal edildi';
    }
  }

  bool get isProcessing =>
      this == JobStatus.queued ||
      this == JobStatus.submitted ||
      this == JobStatus.inProgress;

  bool get isTerminal =>
      this == JobStatus.succeeded ||
      this == JobStatus.failed ||
      this == JobStatus.cancelled;
}

/// Job stage enum (for AI generation pipeline)
enum JobStage {
  preview,    // Initial preview generation
  refine,     // Refinement stage
  remesh,     // Mesh optimization
}

extension JobStageExtension on JobStage {
  String get displayName {
    switch (this) {
      case JobStage.preview:
        return 'Önizleme';
      case JobStage.refine:
        return 'İyileştirme';
      case JobStage.remesh:
        return 'Mesh Optimizasyonu';
    }
  }
}

/// AI Provider enum
enum AIProvider {
  meshy,
  tripo,
}

/// Job model representing an AI generation job
class Job {
  final String id;
  final String userId;
  final String? assetId;
  final AIProvider provider;
  final String? providerTaskId;
  final JobStatus status;
  final JobStage? stage;
  final double? progress;
  final String prompt;
  final String? errorMessage;
  final Map<String, dynamic>? requestPayload;
  final Map<String, dynamic>? resultPayload;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Job({
    required this.id,
    required this.userId,
    this.assetId,
    required this.provider,
    this.providerTaskId,
    required this.status,
    this.stage,
    this.progress,
    required this.prompt,
    this.errorMessage,
    this.requestPayload,
    this.resultPayload,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory Job.fromJson(Map<String, dynamic> json) {
    final requestPayload = json['request_payload'] as Map<String, dynamic>?;
    final resultPayload = json['result_payload'] as Map<String, dynamic>?;
    final prompt = _extractPrompt(requestPayload);
    final progress = _extractProgress(resultPayload);

    return Job(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      assetId: json['asset_id'] as String?,
      provider: _parseProvider(json['provider'] as String?),
      providerTaskId: json['provider_task_id'] as String?,
      status: _parseStatus(json['status'] as String?),
      stage: _parseStage(json['stage'] as String?),
      progress: progress,
      prompt: prompt,
      errorMessage: json['error_message'] as String?,
      requestPayload: requestPayload,
      resultPayload: resultPayload,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'asset_id': assetId,
        'provider': provider.name.toUpperCase(),
        'provider_task_id': providerTaskId,
        'status': statusValue,
        'stage': stage?.name.toUpperCase(),
        'progress': progress,
        'prompt': prompt,
        'error_message': errorMessage,
        'request_payload': requestPayload,
        'result_payload': resultPayload,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// Check if job is in progress
  bool get isInProgress => status.isProcessing;

  /// Check if job is complete
  bool get isComplete => status == JobStatus.succeeded;

  /// Check if job failed
  bool get isFailed => status == JobStatus.failed;

  /// Get progress percentage (0-100)
  int get progressPercent => ((progressValue) * 100).toInt();

  double get progressValue {
    if (progress != null) {
      return progress!.clamp(0.0, 1.0);
    }
    if (status == JobStatus.succeeded) {
      return 1.0;
    }
    switch (stage) {
      case JobStage.preview:
        return 0.33;
      case JobStage.refine:
        return 0.66;
      case JobStage.remesh:
        return 0.9;
      default:
        return status.isProcessing ? 0.2 : 0.0;
    }
  }

  String get stageDisplayName => stage?.displayName ?? 'İşleniyor';

  bool get isCancellable =>
      status == JobStatus.queued ||
      status == JobStatus.submitted ||
      status == JobStatus.inProgress;

  String get error => errorMessage ?? '';

  String get statusValue {
    switch (status) {
      case JobStatus.queued:
        return 'QUEUED';
      case JobStatus.submitted:
        return 'SUBMITTED';
      case JobStatus.inProgress:
        return 'IN_PROGRESS';
      case JobStatus.succeeded:
        return 'SUCCEEDED';
      case JobStatus.failed:
        return 'FAILED';
      case JobStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Copy with modifications
  Job copyWith({
    JobStatus? status,
    JobStage? stage,
    double? progress,
    String? errorMessage,
    Map<String, dynamic>? requestPayload,
    Map<String, dynamic>? resultPayload,
  }) {
    return Job(
      id: id,
      userId: userId,
      assetId: assetId,
      provider: provider,
      providerTaskId: providerTaskId,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
      prompt: prompt,
      errorMessage: errorMessage ?? this.errorMessage,
      requestPayload: requestPayload ?? this.requestPayload,
      resultPayload: resultPayload ?? this.resultPayload,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static AIProvider _parseProvider(String? value) {
    switch (value?.toUpperCase()) {
      case 'TRIPO':
        return AIProvider.tripo;
      case 'MESHY':
      default:
        return AIProvider.meshy;
    }
  }

  static JobStatus _parseStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'QUEUED':
        return JobStatus.queued;
      case 'SUBMITTED':
        return JobStatus.submitted;
      case 'IN_PROGRESS':
        return JobStatus.inProgress;
      case 'SUCCEEDED':
        return JobStatus.succeeded;
      case 'FAILED':
        return JobStatus.failed;
      case 'CANCELLED':
        return JobStatus.cancelled;
      default:
        return JobStatus.queued;
    }
  }

  static JobStage? _parseStage(String? value) {
    switch (value?.toUpperCase()) {
      case 'PREVIEW':
        return JobStage.preview;
      case 'REFINE':
        return JobStage.refine;
      case 'REMESH':
        return JobStage.remesh;
      default:
        return null;
    }
  }

  static String _extractPrompt(Map<String, dynamic>? payload) {
    if (payload == null) return 'Prompt yok';
    final preview = payload['preview'];
    if (preview is Map<String, dynamic>) {
      final prompt = preview['prompt'];
      if (prompt is String && prompt.isNotEmpty) return prompt;
    }
    final direct = payload['prompt'];
    if (direct is String && direct.isNotEmpty) return direct;
    return 'Prompt yok';
  }

  static double? _extractProgress(Map<String, dynamic>? payload) {
    if (payload == null) return null;
    final lastTask = payload['last_task'];
    if (lastTask is Map<String, dynamic>) {
      final value = lastTask['progress'];
      return _normalizeProgress(value);
    }
    return _normalizeProgress(payload['progress']);
  }

  static double? _normalizeProgress(dynamic value) {
    if (value is num) {
      final raw = value.toDouble();
      if (raw <= 1.0) return raw;
      return (raw / 100.0).clamp(0.0, 1.0);
    }
    return null;
  }
}
