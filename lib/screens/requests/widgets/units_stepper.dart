import 'package:flutter/material.dart';

import '../../../utils/request_rules.dart';

/// "−  2 units  +" for the number of bags needed.
///
/// Buttons instead of a text box: no keyboard, and no way to type 0 or
/// letters. The limits come from utils/request_rules.dart.
class UnitsStepper extends StatelessWidget {
  const UnitsStepper({super.key, required this.units, required this.onChanged});

  final int units;

  /// Called with -1 or +1.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = units == 1 ? '1 unit' : '$units units';

    return Row(
      children: [
        // IconButton.outlined is a round 48 dp button with a border.
        // A null onPressed greys it out at the limit.
        IconButton.outlined(
          tooltip: 'One unit fewer',
          icon: const Icon(Icons.remove),
          onPressed: units > minUnits ? () => onChanged(-1) : null,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton.outlined(
          tooltip: 'One unit more',
          icon: const Icon(Icons.add),
          onPressed: units < maxUnits ? () => onChanged(1) : null,
        ),
      ],
    );
  }
}
