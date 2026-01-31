import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tus_client_dart/tus_client_dart.dart';

import '../api/api_config.dart';

class StorageUploadResult {
  final String bucket;
  final String path;
  final int size;

  const StorageUploadResult({
    required this.bucket,
    required this.path,
    required this.size,
  });
}

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  String get _storageHost {
    return ApiConfig.storageBaseUrl();
  }

  Uri get _tusEndpoint {
    return Uri.parse('$_storageHost/storage/v1/upload/resumable');
  }

  Future<StorageUploadResult> uploadResumableFile({
    required File file,
    required String bucket,
    required String objectPath,
    String? contentType,
    bool upsert = true,
    int chunkSizeBytes = 6 * 1024 * 1024,
    Map<String, String>? extraMetadata,
    void Function(double progress)? onProgress,
  }) async {
    final session = _client.auth.currentSession;
    final token = session?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('User not authenticated');
    }

    final resolvedContentType =
        contentType ?? lookupMimeType(file.path) ?? 'application/octet-stream';

    final store = await _createStore();
    final metadata = <String, String>{
      'bucketName': bucket,
      'objectName': objectPath,
      'contentType': resolvedContentType,
      if (extraMetadata != null) ...extraMetadata,
    };

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'apikey': ApiConfig.supabaseAnonKey,
      'x-upsert': upsert ? 'true' : 'false',
    };

    final client = TusClient(
      XFile(file.path),
      store: store,
      maxChunkSize: chunkSizeBytes,
    );

    await client.upload(
      uri: _tusEndpoint,
      headers: headers,
      metadata: metadata,
      onProgress: (progress, _) {
        if (onProgress != null) {
          onProgress(progress);
        }
      },
    );

    return StorageUploadResult(
      bucket: bucket,
      path: objectPath,
      size: await file.length(),
    );
  }

  Future<TusFileStore> _createStore() async {
    final directory = await getApplicationDocumentsDirectory();
    final storeDir = Directory(p.join(directory.path, 'tus_store'));
    if (!storeDir.existsSync()) {
      storeDir.createSync(recursive: true);
    }
    return TusFileStore(storeDir);
  }

  String buildAssetObjectPath({
    required String userId,
    required String assetId,
    required String fileName,
    String? prefix,
  }) {
    final safePrefix = prefix != null && prefix.isNotEmpty ? '${prefix}_' : '';
    return '$userId/$assetId/$safePrefix$fileName';
  }
}
