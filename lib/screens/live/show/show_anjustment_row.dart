import 'package:flutter/material.dart';
import 'package:budgetmanager/screens/components/adjust_button.dart';

class ShowAdjustmentRow extends StatelessWidget {
  final double amount;
  final Function(double) adjust;
  const ShowAdjustmentRow(this.amount, this.adjust, {super.key});

  @override
  Widget build(BuildContext context) {
    double absAmount = amount.abs();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: AdjustButton(
              label: '-$absAmount',
              onPressed: () => adjust(-absAmount),
            ),
          ),
          Expanded(
            child: AdjustButton(
              label: '+$absAmount',
              onPressed: () => adjust(absAmount),
            ),
          ),
        ],
      ),
    );
  }
}

