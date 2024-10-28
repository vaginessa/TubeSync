extension DurationExtensions on Duration? {
  String formatHHMM() {
    if (this == null) return "??:??";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(this!.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(this!.inSeconds.remainder(60));
    final hour = twoDigits(this!.inHours);
    return " ${hour == '00' ? '' : '$hour:'}$twoDigitMinutes:$twoDigitSeconds ";
  }
}

extension StringExtensions on String {
  /// Converts SUSSY BAKA, SuSSy bAKA sussY BaKA etc to Sussy Baka
  String toCapitalCase() => splitMapJoin(" ", onNonMatch: (n) {
        if (n.length <= 2) return n.toUpperCase();
        return "${n[0].toUpperCase()}${n.substring(1).toLowerCase()}";
      });

  /// sussyBaka -> sussy Baka
  String normalizeCamelCase() => replaceAllMapped(
        RegExp(r"([A-Z]){1,3}"),
        (match) => " ${match[0]}",
      );
}
