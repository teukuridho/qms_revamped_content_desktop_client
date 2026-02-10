class ServerAddressParser {
  static Uri parse(String serverAddress) {
    final raw = serverAddress.trim();
    if (raw.isEmpty) {
      throw const FormatException('serverAddress is empty');
    }

    if (!raw.contains('://')) {
      final fixed = 'http://$raw';
      final uri = Uri.parse(fixed);
      if (uri.host.isEmpty) {
        throw FormatException('Invalid serverAddress: $serverAddress');
      }
      return uri;
    }

    final uri = Uri.parse(raw);
    if (uri.host.isEmpty) {
      throw FormatException('Invalid serverAddress: $serverAddress');
    }
    return uri;
  }

  static String normalizeBasePath(Uri baseUri) {
    // ApiClient.basePath concatenates basePath + path, where path starts with '/'.
    // Keep any configured path prefix but avoid trailing '/' to prevent '//...'.
    final trimmed = baseUri.replace(
      path: baseUri.path.replaceAll(RegExp(r'/+$'), ''),
    );
    return trimmed.toString();
  }
}
