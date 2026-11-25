/// Compile-time switches. Phase 1 runs on mock repositories.
///
/// ```sh
/// flutter run --dart-define=USE_MOCK=true
/// flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.example
/// ```
class AppConfig {
  const AppConfig._();

  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.casetrak.local',
  );
}
