class Budget {
  final int id;
  final String name;
  final double limit;
  final DateTime? hiddenOn;

  Budget({
    required this.id,
    required this.name,
    required this.limit,
    required this.hiddenOn,
  });

  factory Budget.empty() {
    return Budget(id: 0, name: 'empty', limit: 0, hiddenOn: null);
  }
}
