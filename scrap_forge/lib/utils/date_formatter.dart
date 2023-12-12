class DateFormatter {
  static fromTimestamp(int ts) {
    String localIso =
        DateTime.fromMillisecondsSinceEpoch(ts).toLocal().toString();

    return "${localIso.substring(8, 10)}.${localIso.substring(5, 7)}.${localIso.substring(0, 4)}";
  }
}
