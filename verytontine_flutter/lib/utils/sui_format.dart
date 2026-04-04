/// Sui amounts on-chain are in MIST (1 SUI = 10^9 MIST).
abstract final class SuiFormat {
  static const int mistPerSui = 1000000000;

  static double mistToSui(num mist) => mist / mistPerSui;

  /// Converts a user-entered SUI string (e.g. "0.1" or "1") to MIST.
  static int? suiInputToMist(String input) {
    final trimmed = input.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    final v = double.tryParse(trimmed);
    if (v == null || v <= 0) return null;
    return (v * mistPerSui).round();
  }

  static String formatMist(num mist, {int maxDecimals = 4}) {
    final sui = mistToSui(mist);
    var s = sui.toStringAsFixed(maxDecimals);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    if (s.isEmpty || s == '-') return '0 SUI';
    return '$s SUI';
  }

  static String shortenAddress(String address, {int head = 6, int tail = 4}) {
    if (address.length <= head + tail + 1) return address;
    return '${address.substring(0, head)}…${address.substring(address.length - tail)}';
  }
}
