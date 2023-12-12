class StringMultiliner {
  static StringBuffer multiline(String? uniLine) {
    StringBuffer sb = StringBuffer();
    if (uniLine != null) {
      for (String line in (uniLine.split('\\n'))) {
        sb.write("$line\n");
      }
    }
    return sb;
  }
}
