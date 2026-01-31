/// Asset model representing a 3D asset
class Asset {
  final String id;
  final String userId;
  final String? title;
  final String? description;
  final AssetCategory? category;
  final String? meshUrl;
  final String? textureUrl;
  final String? meshStoragePath;
  final String? textureStoragePath;
  final String? pbrMetalnessStoragePath;
  final String? pbrRoughnessStoragePath;
  final String? pbrNormalStoragePath;
  final String? thumbnailUrl;
  final int? polygonCount;
  final AssetStatus status;
  final bool isPublic;
  final Map<String, dynamic>? metadata;
  final String? prompt;
  final bool isAIGenerated;
  final String? sourceJobId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Asset({
    required this.id,
    required this.userId,
    this.title,
    this.description,
    this.category,
    this.meshUrl,
    this.textureUrl,
    this.meshStoragePath,
    this.textureStoragePath,
    this.pbrMetalnessStoragePath,
    this.pbrRoughnessStoragePath,
    this.pbrNormalStoragePath,
    this.thumbnailUrl,
    this.polygonCount,
    required this.status,
    this.isPublic = false,
    this.metadata,
    this.prompt,
    this.isAIGenerated = false,
    this.sourceJobId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory Asset.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    final prompt = _extractPrompt(metadata);
    final statusRaw = (json['status'] ?? metadata['status'])?.toString();
    final categoryRaw = (json['category'] ?? metadata['category'])?.toString();
    final sourceJobId = json['source_job_id']?.toString();
    final meshUrl = json['mesh_url'] as String?;
    final textureUrl = json['texture_url'] as String?;
    final meshStoragePath = json['mesh_storage_path'] as String?;
    final textureStoragePath = json['texture_storage_path'] as String?;
    final metalnessStoragePath = json['pbr_metalness_storage_path'] as String?;
    final roughnessStoragePath = json['pbr_roughness_storage_path'] as String?;
    final normalStoragePath = json['pbr_normal_storage_path'] as String?;

    return Asset(
      id: json['id'] as String,
      userId: (json['owner_id'] ?? json['user_id']) as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: _parseCategory(categoryRaw),
      meshUrl: meshUrl,
      textureUrl: textureUrl,
      meshStoragePath: meshStoragePath,
      textureStoragePath: textureStoragePath,
      pbrMetalnessStoragePath: metalnessStoragePath,
      pbrRoughnessStoragePath: roughnessStoragePath,
      pbrNormalStoragePath: normalStoragePath,
      thumbnailUrl: json['thumbnail_url'] as String?,
      polygonCount: (json['poly_count'] ?? json['polygon_count']) as int?,
      status: _parseStatus(
        statusRaw,
        metadata: metadata,
        meshUrl: meshUrl,
        textureUrl: textureUrl,
        meshStoragePath: meshStoragePath,
        textureStoragePath: textureStoragePath,
        sourceJobId: sourceJobId,
      ),
      isPublic: json['is_public'] as bool? ?? false,
      metadata: metadata,
      prompt: prompt,
      isAIGenerated: prompt != null || sourceJobId != null,
      sourceJobId: sourceJobId,
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
        'title': title,
        'description': description,
        'category': category?.name,
        'mesh_url': meshUrl,
        'texture_url': textureUrl,
        'mesh_storage_path': meshStoragePath,
        'texture_storage_path': textureStoragePath,
        'pbr_metalness_storage_path': pbrMetalnessStoragePath,
        'pbr_roughness_storage_path': pbrRoughnessStoragePath,
        'pbr_normal_storage_path': pbrNormalStoragePath,
        'thumbnail_url': thumbnailUrl,
        'polygon_count': polygonCount,
        'status': status.name,
        'is_public': isPublic,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// Check if asset is valid for Roblox (under 4000 polygons)
  bool get isRobloxValid => polygonCount == null || polygonCount! <= 4000;

  /// Check if asset has mesh
  bool get hasMesh =>
      (meshUrl != null && meshUrl!.isNotEmpty) ||
      (meshStoragePath != null && meshStoragePath!.isNotEmpty);

  /// Check if asset has texture
  bool get hasTexture =>
      (textureUrl != null && textureUrl!.isNotEmpty) ||
      (textureStoragePath != null && textureStoragePath!.isNotEmpty);

  /// Display name (fallback to id)
  String get name => title?.isNotEmpty == true ? title! : 'Design';

  /// Category label for UI
  String get categoryLabel => category?.displayName ?? 'Other';

  /// Copy with modifications
  Asset copyWith({
    String? title,
    String? description,
    String? meshUrl,
    String? textureUrl,
    String? meshStoragePath,
    String? textureStoragePath,
    String? pbrMetalnessStoragePath,
    String? pbrRoughnessStoragePath,
    String? pbrNormalStoragePath,
    String? thumbnailUrl,
    int? polygonCount,
    AssetStatus? status,
    bool? isPublic,
  }) {
    return Asset(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category,
      meshUrl: meshUrl ?? this.meshUrl,
      textureUrl: textureUrl ?? this.textureUrl,
      meshStoragePath: meshStoragePath ?? this.meshStoragePath,
      textureStoragePath: textureStoragePath ?? this.textureStoragePath,
      pbrMetalnessStoragePath:
          pbrMetalnessStoragePath ?? this.pbrMetalnessStoragePath,
      pbrRoughnessStoragePath:
          pbrRoughnessStoragePath ?? this.pbrRoughnessStoragePath,
      pbrNormalStoragePath: pbrNormalStoragePath ?? this.pbrNormalStoragePath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      polygonCount: polygonCount ?? this.polygonCount,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static AssetStatus _parseStatus(
    String? value, {
    Map<String, dynamic>? metadata,
    String? meshUrl,
    String? textureUrl,
    String? meshStoragePath,
    String? textureStoragePath,
    String? sourceJobId,
  }) {
    final normalized = value?.toLowerCase();
    switch (normalized) {
      case 'completed':
        return AssetStatus.completed;
      case 'processing':
        return AssetStatus.processing;
      case 'published':
        return AssetStatus.published;
      case 'failed':
        return AssetStatus.failed;
      case 'draft':
        return AssetStatus.draft;
    }

    final metaStatus = metadata?['status']?.toString().toLowerCase() ??
        metadata?['job_status']?.toString().toLowerCase();
    switch (metaStatus) {
      case 'completed':
      case 'succeeded':
        return AssetStatus.completed;
      case 'processing':
      case 'in_progress':
      case 'queued':
      case 'submitted':
        return AssetStatus.processing;
      case 'published':
        return AssetStatus.published;
      case 'failed':
        return AssetStatus.failed;
    }

    final hasOutput = (meshUrl != null && meshUrl.isNotEmpty) ||
        (textureUrl != null && textureUrl.isNotEmpty) ||
        (meshStoragePath != null && meshStoragePath.isNotEmpty) ||
        (textureStoragePath != null && textureStoragePath.isNotEmpty);
    if (hasOutput) {
      return AssetStatus.completed;
    }
    if (sourceJobId != null && sourceJobId.isNotEmpty) {
      return AssetStatus.processing;
    }
    return AssetStatus.draft;
  }

  static AssetCategory? _parseCategory(String? value) {
    switch (value?.toLowerCase()) {
      case 'hat':
      case 'şapka':
        return AssetCategory.hat;
      case 'hair':
      case 'saç':
        return AssetCategory.hair;
      case 'face':
      case 'yüz':
        return AssetCategory.face;
      case 'shirt':
      case 'gömlek':
        return AssetCategory.shirt;
      case 'pants':
      case 'pantolon':
        return AssetCategory.pants;
      case 'accessory':
      case 'aksesuar':
        return AssetCategory.accessory;
      case 'back':
      case 'sırt':
        return AssetCategory.back;
      case 'shoulders':
      case 'omuz':
        return AssetCategory.shoulders;
      case 'weapon':
      case 'silah':
        return AssetCategory.weapon;
      case 'other':
      case 'diğer':
        return AssetCategory.other;
      default:
        return null;
    }
  }

  static String? _extractPrompt(Map<String, dynamic> metadata) {
    final prompt = metadata['prompt'] ?? metadata['ai_prompt'];
    if (prompt is String && prompt.isNotEmpty) return prompt;
    return null;
  }
}

/// Asset status enum
enum AssetStatus {
  draft,
  processing,
  completed,
  published,
  failed,
}

extension AssetStatusExtension on AssetStatus {
  String get displayName {
    switch (this) {
      case AssetStatus.draft:
        return 'Draft';
      case AssetStatus.processing:
        return 'Processing';
      case AssetStatus.completed:
        return 'Ready';
      case AssetStatus.published:
        return 'Published';
      case AssetStatus.failed:
        return 'Failed';
    }
  }
}

/// Asset category enum
enum AssetCategory {
  hat,
  hair,
  face,
  shirt,
  pants,
  accessory,
  back,
  shoulders,
  weapon,
  other,
}

/// Extension for category display names
extension AssetCategoryExtension on AssetCategory {
  String get displayName {
    switch (this) {
      case AssetCategory.hat:
        return 'Şapka';
      case AssetCategory.hair:
        return 'Saç';
      case AssetCategory.face:
        return 'Yüz';
      case AssetCategory.shirt:
        return 'Gömlek';
      case AssetCategory.pants:
        return 'Pantolon';
      case AssetCategory.accessory:
        return 'Aksesuar';
      case AssetCategory.back:
        return 'Sırt';
      case AssetCategory.shoulders:
        return 'Omuz';
      case AssetCategory.weapon:
        return 'Silah';
      case AssetCategory.other:
        return 'Diğer';
    }
  }

  String get englishName => name;
}
