import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'dio_client.dart';

/// Service d'upload de fichier vers le backend MinIO.
///
/// Endpoint backend: `POST /files` (multipart) — public (utilisé pendant
/// l'inscription avant qu'un compte ne soit créé). Retourne `{id, url}`.
class FileUploader {
  final DioClient client;
  FileUploader(this.client);

  /// Upload un fichier (bytes + filename) et retourne le fileId UUID.
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
      'size': bytes.length.toString(),
    });

    final res = await client.dio.post(
      '/files',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final body = res.data as Map<String, dynamic>;
    return body['id'] as String;
  }

  /// Récupère une URL pré-signée (1h par défaut) pour lire un fichier MinIO.
  Future<String> presignedUrl(String fileId, {Duration? ttl}) async {
    final res = await client.dio.get(
      '/files/$fileId/url',
      queryParameters: ttl == null ? null : {'ttlSeconds': ttl.inSeconds},
    );
    return (res.data as Map<String, dynamic>)['url'] as String;
  }

  /// URL absolue de récupération (via le proxy backend) — préfère [presignedUrl]
  /// pour avoir un lien direct vers MinIO sans passer par le backend.
  String backendUrl(String fileId) => '${ApiConfig.apiBase}/files/$fileId';
}
