import 'package:beauty_hub/data/auth_data_source.dart';

class FakeAuthDataSource implements AuthDataSource {
  bool signedIn;
  String userId;
  bool throwOnVerify;

  FakeAuthDataSource({this.signedIn = true, this.userId = 'test-user-1', this.throwOnVerify = false});

  @override
  bool get isSignedIn => signedIn;

  @override
  String? get currentUserId => signedIn ? userId : null;

  @override
  Future<void> sendPhoneOtp(String phone) async {}

  @override
  Future<void> verifyPhoneOtp({required String phone, required String token}) async {
    if (throwOnVerify) throw Exception('invalid code');
    signedIn = true;
  }

  @override
  Future<void> signInWithGoogle() async {
    signedIn = true;
  }

  @override
  Future<void> signOut() async {
    signedIn = false;
  }
}
