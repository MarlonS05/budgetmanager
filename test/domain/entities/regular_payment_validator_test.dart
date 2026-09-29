import 'package:budgetmanager/domain/entities/regular_payment_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegularPaymentValidator', () {
    test('requires a trimmed name', () {
      expect(
        RegularPaymentValidator.validate(
          name: '   ',
          amountText: '10',
          months: {1},
        ),
        'Enter a name.',
      );
    });

    test('requires a positive finite numeric amount', () {
      for (final amount in [
        '',
        'words',
        '0',
        '-2',
        'Infinity',
        List.filled(400, '9').join(),
      ]) {
        expect(
          RegularPaymentValidator.validate(
            name: 'Rent',
            amountText: amount,
            months: {1},
          ),
          'Enter an amount greater than 0.',
        );
      }
    });

    test('accepts comma decimal input', () {
      expect(
        RegularPaymentValidator.validate(
          name: 'Insurance',
          amountText: '12,50',
          months: {3},
        ),
        isNull,
      );
    });

    test('requires at least one selected month', () {
      expect(
        RegularPaymentValidator.validate(
          name: 'Rent',
          amountText: '10',
          months: {},
        ),
        'Select at least one month.',
      );
    });
  });
}
