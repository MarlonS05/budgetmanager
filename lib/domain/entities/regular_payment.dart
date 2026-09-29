class RegularPayment {
  final int id;
  final String name;
  final double amount;
  final Set<int> months;

  const RegularPayment({
    required this.id,
    required this.name,
    required this.amount,
    required this.months,
  });

  factory RegularPayment.empty() {
    return const RegularPayment(id: 0, name: '', amount: 0, months: {});
  }

  bool occursInMonth(int month) => months.contains(month);
}
