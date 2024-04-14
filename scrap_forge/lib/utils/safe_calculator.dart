class SafeCalculator {
  static num? multiply(num? a, num? b) {
    if (a == null || b == null) {
      return null;
    }
    return a * b;
  }

  static num? divide(num? a, num? b) {
    if (a == null || b == null) {
      return null;
    }
    return a / b;
  }
}
