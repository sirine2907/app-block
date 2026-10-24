/// Formatting helpers for durations shown around the app.
class DurationFormat {
  DurationFormat._();

  /// `HH:MM:SS`, always two digits per field.
  static String clock(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  /// Friendly label like "1 h 30 min" or "45 min".
  static String friendly(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '$h h $m min';
    if (h > 0) return '$h h';
    return '$m min';
  }

  /// Rounded hours for stats, e.g. "12.5 hours".
  static String hours(Duration d) {
    final hrs = d.inMinutes / 60.0;
    final text = hrs == hrs.roundToDouble()
        ? hrs.toStringAsFixed(0)
        : hrs.toStringAsFixed(1);
    return '$text ${hrs == 1 ? 'hour' : 'hours'}';
  }
}
