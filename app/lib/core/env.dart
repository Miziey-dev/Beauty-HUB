/// Supabase config, passed at build/run time via --dart-define so no
/// secrets need to be bundled as assets or committed to the repo:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=your-anon-key
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
