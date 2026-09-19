class Environment {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1/',
  );
  static Uri get apiUri {
    final uri = Uri.parse(
      apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/',
    );
    if (!uri.hasAuthority || !['http', 'https'].contains(uri.scheme)) {
      throw ArgumentError('API_BASE_URL must be an absolute HTTP(S) URL.');
    }
    return uri;
  }
}
