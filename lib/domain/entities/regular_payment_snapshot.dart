class RegularPaymentSnapshot {
  final int id;
  final int monthId;
  final double amount;
  final List<String> items;

  const RegularPaymentSnapshot({
    required this.id,
    required this.monthId,
    required this.amount,
    required this.items,
  });

  factory RegularPaymentSnapshot.empty() {
    return const RegularPaymentSnapshot(
      id: 0,
      monthId: 0,
      amount: 0,
      items: [],
    );
  }
}
