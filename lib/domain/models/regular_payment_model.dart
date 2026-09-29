import '../entities/regular_payment.dart';

class RegularPaymentModel {
  final int id;
  final String name;
  final double amount;
  final Set<int> months;

  const RegularPaymentModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.months,
  });

  factory RegularPaymentModel.fromMap(Map<String, dynamic> map) {
    return RegularPaymentModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      months: monthsFromMask((map['months_mask'] as num).toInt()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'amount': amount,
      'months_mask': maskFromMonths(months),
    };
  }

  RegularPayment toEntity() {
    return RegularPayment(id: id, name: name, amount: amount, months: months);
  }

  factory RegularPaymentModel.fromEntity(RegularPayment payment) {
    return RegularPaymentModel(
      id: payment.id,
      name: payment.name,
      amount: payment.amount,
      months: payment.months,
    );
  }

  static int maskFromMonths(Set<int> months) {
    if (months.any((month) => month < 1 || month > 12)) {
      throw ArgumentError.value(months, 'months', 'Must contain only 1–12.');
    }
    return months.fold(0, (mask, month) => mask | (1 << (month - 1)));
  }

  static Set<int> monthsFromMask(int mask) {
    if (mask < 0 || mask > 0xFFF) {
      throw ArgumentError.value(mask, 'mask', 'Must use only 12 month bits.');
    }
    return {
      for (var month = 1; month <= 12; month++)
        if (mask & (1 << (month - 1)) != 0) month,
    };
  }
}
