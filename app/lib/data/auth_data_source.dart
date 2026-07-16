import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps Supabase Auth so screens depend on an interface instead of the
/// concrete client -- tests inject a fake instead of hitting a real project.
/// Phone OTP is primary (low-friction in SA); Google is the alternative
/// (docs/consumer-flow.md, Screen 5b's auth gate).
abstract class AuthDataSource {
  bool get isSignedIn;
  String? get currentUserId;

  Future<void> sendPhoneOtp(String phone);
  Future<void> verifyPhoneOtp({required String phone, required String token});
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

class SupabaseAuthDataSource implements AuthDataSource {
  SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  @override
  bool get isSignedIn => _client.auth.currentUser != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<void> sendPhoneOtp(String phone) => _client.auth.signInWithOtp(phone: phone);

  @override
  Future<void> verifyPhoneOtp({required String phone, required String token}) =>
      _client.auth.verifyOTP(type: OtpType.sms, phone: phone, token: token);

  @override
  Future<void> signInWithGoogle() => _client.auth.signInWithOAuth(
        OAuthProvider.google,
        // Requires a matching custom URL scheme registered natively
        // (AndroidManifest.xml intent-filter / iOS URL type) before this
        // redirect will actually return to the app -- see README.
        redirectTo: 'io.beautyhub.app://login-callback',
      );

  @override
  Future<void> signOut() => _client.auth.signOut();
}
