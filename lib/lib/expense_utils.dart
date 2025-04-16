class ExpenseUtils {
  static List<double> equalSplit(double totalAmount) {
    return [totalAmount / 2, totalAmount / 2];
  }

  static List<double> customSplit(double totalAmount, double percentageA) {
    double shareA = totalAmount * (percentageA / 100);
    double shareB = totalAmount - shareA;
    return [shareA, shareB];
  }
}
