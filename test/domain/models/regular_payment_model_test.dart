import 'package:budgetmanager/domain/models/regular_payment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegularPaymentModel month mask', () {
    test('encodes and decodes selected calendar months', () {
      const months = {1, 3, 12};

      final mask = RegularPaymentModel.maskFromMonths(months);

      expect(mask, 0x805);
      expect(RegularPaymentModel.monthsFromMask(mask), months);
    });

    test('supports no selected months for an empty draft', () {
      expect(RegularPaymentModel.maskFromMonths({}), 0);
      expect(RegularPaymentModel.monthsFromMask(0), isEmpty);
    });

    test('rejects calendar months outside 1 through 12', () {
      expect(
        () => RegularPaymentModel.maskFromMonths({0, 1}),
        throwsArgumentError,
      );
      expect(
        () => RegularPaymentModel.maskFromMonths({12, 13}),
        throwsArgumentError,
      );
    });

    test('rejects masks containing bits outside the twelve months', () {
      expect(
        () => RegularPaymentModel.monthsFromMask(1 << 12),
        throwsArgumentError,
      );
    });
  });
}
