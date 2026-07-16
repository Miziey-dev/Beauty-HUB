import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Uploads a picked photo and returns its public URL. Uses dart:io File,
/// so this is mobile-only by design (Android is the v1 target per
/// docs/consumer-flow.md) -- a web build would need XFile.readAsBytes +
/// uploadBinary instead.
abstract class PhotoUploadService {
  Future<String> uploadReviewPhoto(String localFilePath);
}

class SupabasePhotoUploadService implements PhotoUploadService {
  SupabasePhotoUploadService(this._client);

  final SupabaseClient _client;
  static const _bucket = 'review-photos';

  @override
  Future<String> uploadReviewPhoto(String localFilePath) async {
    final file = File(localFilePath);
    final objectPath = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    await _client.storage.from(_bucket).upload(objectPath, file);
    return _client.storage.from(_bucket).getPublicUrl(objectPath);
  }
}
