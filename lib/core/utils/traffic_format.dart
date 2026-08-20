int parseTrafficBytes(String raw) {
  final trimmed = raw.trim().replaceAll(',', '');
  final asInt = int.tryParse(trimmed);
  if (asInt != null) return asInt < 0 ? 0 : asInt;
  final match = RegExp(
    r'^([\d.]+)\s*([kmgt]?i?b)?$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (match == null) return 0;
  final n = double.tryParse(match.group(1)!) ?? 0;
  final unit = (match.group(2) ?? '').toLowerCase();
  final mul = switch (unit) {
    'kb' || 'kib' => 1024,
    'mb' || 'mib' => 1024 * 1024,
    'gb' || 'gib' => 1024 * 1024 * 1024,
    _ => 1,
  };
  return (n * mul).round();
}

String formatRate(double bytesPerSecond) {
  if (bytesPerSecond < 0 || bytesPerSecond.isNaN) return '—';
  return '${formatBytes(bytesPerSecond.round())}/s';
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
