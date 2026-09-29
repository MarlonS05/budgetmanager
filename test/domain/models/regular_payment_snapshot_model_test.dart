import 'package:budgetmanager/domain/entities/regular_payment_snapshot.dart';
import 'package:budgetmanager/domain/models/regular_payment_snapshot_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegularPaymentSnapshotModel', () {
    test('round-trips names through JSON and map conversion', () {
      const snapshot = RegularPaymentSnapshot(
        id: 0,
        monthId: 42,
        amount: 1250.5,
        items: ['Rent', 'Streaming "Plus"'],
      );

      final map = RegularPaymentSnapshotModel.fromEntity(snapshot).toMap();
      final restored = RegularPaymentSnapshotModel.fromMap({
        'id': 7,
        ...map,
      }).toEntity();

      expect(map, isNot(contains('id')));
      expect(restored.id, 7);
      expect(restored.monthId, 42);
      expect(restored.amount, 1250.5);
      expect(restored.items, ['Rent', 'Streaming "Plus"']);
    });

    test('uses an empty list for malformed JSON', () {
      expect(RegularPaymentSnapshotModel.decodeItems('{broken'), isEmpty);
      expect(RegularPaymentSnapshotModel.decodeItems('[1, 2]'), isEmpty);
      expect(RegularPaymentSnapshotModel.decodeItems(null), isEmpty);
    });
  });
}
