import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/asset_model.dart';

/// Repository for querying assets via Supabase.
class AssetRepository {
  final SupabaseClient _client;

  AssetRepository(this._client);

  Future<List<Asset>> fetchUserAssets({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _client
        .from('assets')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return _parseList(data);
  }

  Future<List<Asset>> fetchPublicAssets({int limit = 50}) async {
    final data = await _client
        .from('assets')
        .select()
        .eq('is_public', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return _parseList(data);
  }

  Future<List<Asset>> searchAssets(
    String query, {
    bool publicOnly = true,
    int limit = 50,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final sanitized = _sanitizeQuery(trimmed);
    var builder = _client
        .from('assets')
        .select()
        .or('title.ilike.%$sanitized%,description.ilike.%$sanitized%');
    if (publicOnly) {
      builder = builder.eq('is_public', true);
    }
    final data = await builder.order('created_at', ascending: false).limit(limit);
    return _parseList(data);
  }

  Future<void> updateAssetPaths(
    String assetId, {
    String? meshPath,
    String? texturePath,
    String? metalnessPath,
    String? roughnessPath,
    String? normalPath,
  }) async {
    final updates = <String, dynamic>{};
    if (meshPath != null) {
      updates['mesh_storage_path'] = meshPath;
    }
    if (texturePath != null) {
      updates['texture_storage_path'] = texturePath;
    }
    if (metalnessPath != null) {
      updates['pbr_metalness_storage_path'] = metalnessPath;
    }
    if (roughnessPath != null) {
      updates['pbr_roughness_storage_path'] = roughnessPath;
    }
    if (normalPath != null) {
      updates['pbr_normal_storage_path'] = normalPath;
    }
    if (updates.isEmpty) return;
    await _client.from('assets').update(updates).eq('id', assetId);
  }

  Future<void> updateVisibility(String assetId, {required bool isPublic}) async {
    await _client.from('assets').update({'is_public': isPublic}).eq('id', assetId);
  }

  Future<void> deleteAsset(Asset asset) async {
    final paths = <String>[];
    if (asset.meshStoragePath != null && asset.meshStoragePath!.isNotEmpty) {
      paths.add(asset.meshStoragePath!);
    }
    if (asset.textureStoragePath != null && asset.textureStoragePath!.isNotEmpty) {
      paths.add(asset.textureStoragePath!);
    }
    if (asset.pbrMetalnessStoragePath != null &&
        asset.pbrMetalnessStoragePath!.isNotEmpty) {
      paths.add(asset.pbrMetalnessStoragePath!);
    }
    if (asset.pbrRoughnessStoragePath != null &&
        asset.pbrRoughnessStoragePath!.isNotEmpty) {
      paths.add(asset.pbrRoughnessStoragePath!);
    }
    if (asset.pbrNormalStoragePath != null &&
        asset.pbrNormalStoragePath!.isNotEmpty) {
      paths.add(asset.pbrNormalStoragePath!);
    }

    if (paths.isNotEmpty) {
      try {
        await _client.storage.from('assets').remove(paths);
      } catch (_) {
        // Ignore storage cleanup errors; asset deletion still proceeds.
      }
    }

    await _client.from('assets').delete().eq('id', asset.id);
  }

  List<Asset> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Asset.fromJson)
          .toList();
    }
    return [];
  }

  Future<Asset?> fetchAssetById(String assetId) async {
    final data = await _client.from('assets').select().eq('id', assetId).maybeSingle();
    if (data == null) return null;
    return Asset.fromJson(Map<String, dynamic>.from(data));
  }

  String _sanitizeQuery(String query) {
    return query
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_')
        .replaceAll(',', ' ');
  }
}
