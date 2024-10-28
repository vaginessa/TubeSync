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
