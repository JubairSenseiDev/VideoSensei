extension StringExtensions on String {
  /// Returns file extension without the dot (lowercase).
  String get fileExtension {
    final idx = lastIndexOf('.');
    if (idx < 0) return '';
    return substring(idx + 1).toLowerCase();
  }

  /// Returns file name without path and extension.
  String get fileBaseName {
    final withExt = split('/').last.split('\\').last;
    final idx = withExt.lastIndexOf('.');
    if (idx < 0) return withExt;
    return withExt.substring(0, idx);
  }

  /// Returns the directory portion of a path.
  String get dirPath {
    final idx = lastIndexOf('/');
    if (idx < 0) return '';
    return substring(0, idx);
  }

  /// Truncates string to [maxLength] with ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 1)}…';
  }
}
