class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.bleServiceUuid,
    required this.bleCharacteristicUuid,
  });

  final String apiBaseUrl;
  final String bleServiceUuid;
  final String bleCharacteristicUuid;

  static const AppConfig dev = AppConfig(
    apiBaseUrl: 'https://dev-api.ai-tuner.io',
    bleServiceUuid: '0000FFF0-0000-1000-8000-00805F9B34FB',
    bleCharacteristicUuid: '0000FFF1-0000-1000-8000-00805F9B34FB',
  );

  // TODO(security): Externalize secrets and per-environment configs, load from secure storage or remote config.
}
