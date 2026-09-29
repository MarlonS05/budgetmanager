class RegularPaymentValidator {
  const RegularPaymentValidator._();

  static String? validate({
    required String name,
    required String amountText,
    required Set<int> months,
  }) {
    if (name.trim().isEmpty) return 'Enter a name.';

    final normalizedAmount = amountText.trim().replaceAll(',', '.');
    final amount = double.tryParse(normalizedAmount);
    if (amount == null || amount <= 0 || !amount.isFinite) {
      return 'Enter an amount greater than 0.';
    }

    if (months.isEmpty) return 'Select at least one month.';
    return null;
  }
}
