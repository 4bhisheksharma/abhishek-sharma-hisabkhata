class ImageUtils {
  static const String _mediaBaseUrl = "http://10.0.2.2:8000";

  /// Converts relative/file URLs to complete media URLs.
  /// Returns null for empty/null inputs.
  static String? getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;

    // If already a complete URL, return as-is.
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }

    // Remove file:/// protocol if present.
    String cleanPath = relativePath
        .replaceFirst(RegExp(r'^file:///'), '')
        .replaceFirst(RegExp(r'^file://'), '')
        .replaceFirst(RegExp(r'^file:/'), '');

    // Add /media/ prefix if not present.
    if (!cleanPath.startsWith('/media/')) {
      // Remove leading slash if present before adding /media
      cleanPath = cleanPath.replaceFirst(RegExp(r'^/'), '');
      cleanPath = '/media/$cleanPath';
    }

    return '$_mediaBaseUrl$cleanPath';
  }
}
