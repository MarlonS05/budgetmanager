import 'dart:convert';

import '../entities/regular_payment_snapshot.dart';

class RegularPaymentSnapshotModel {
  final int id;
  final int monthId;
  final double amount;
  final List<String> items;

  const RegularPaymentSnapshotModel({
    required this.id,
    required this.monthId,
    required this.amount,
    required this.items,
  });

  factory RegularPaymentSnapshotModel.fromMap(Map<String, dynamic> map) {
    return RegularPaymentSnapshotModel(
      id: (map['id'] as num).toInt(),
      monthId: (map['month_id'] as num).toInt(),
      amount: (map['amount'] as num).toDouble(),
      items: decodeItems(map['items_json'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'month_id': monthId,
      'amount': amount,
      'items_json': encodeItems(items),
    };
  }

  RegularPaymentSnapshot toEntity() {
    return RegularPaymentSnapshot(
      id: id,
      monthId: monthId,
      amount: amount,
      items: List.unmodifiable(items),
    );
  }

  factory RegularPaymentSnapshotModel.fromEntity(
    RegularPaymentSnapshot snapshot,
  ) {
    return RegularPaymentSnapshotModel(
      id: snapshot.id,
      monthId: snapshot.monthId,
      amount: snapshot.amount,
      items: snapshot.items,
    );
  }

  static String encodeItems(List<String> items) => jsonEncode(items);

  static List<String> decodeItems(String? raw) {
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.any((item) => item is! String)) {
        return const [];
      }
      return List<String>.unmodifiable(decoded.cast<String>());
    } on FormatException {
      return const [];
    }
  }
}
