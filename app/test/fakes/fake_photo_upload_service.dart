import 'package:beauty_hub/data/photo_upload_service.dart';

class FakePhotoUploadService implements PhotoUploadService {
  @override
  Future<String> uploadReviewPhoto(String localFilePath) async => 'https://example.com/uploaded.jpg';
}
