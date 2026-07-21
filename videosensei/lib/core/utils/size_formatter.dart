/// Utility to format byte sizes into human-readable strings.
abstract class SizeFormatter {
  static String format(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Returns a human-readable reduction percentage.
  /// e.g. "−47.3%"
  static String reductionPercent(int original, int compressed) {
    if (original <= 0) return '—';
    final reduction = (1.0 - compressed / original) * 100;
    final sign = reduction >= 0 ? '−' : '+';
    return '$sign${reduction.abs().toStringAsFixed(1)}%';
  }

  /// e.g. "3.2 MB → 1.7 MB (−47%)"
  static String summarize(int original, int compressed) {
    return '${format(original)} → ${format(compressed)} (${reductionPercent(original, compressed)})';
  }
}

/// Formats a duration to HH:MM:SS or MM:SS.
abstract class DurationFormatter {
  static String format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  static String formatSeconds(double seconds) =>
      format(Duration(milliseconds: (seconds * 1000).round()));
}
