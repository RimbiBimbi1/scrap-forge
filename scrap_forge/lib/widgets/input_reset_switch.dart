import 'package:flutter/material.dart';

class InputResetSwitch extends StatelessWidget {
  final String label;
  final bool enabled;
  final void Function(bool value) onSwitched;
  const InputResetSwitch({
    super.key,
    required this.label,
    required this.enabled,
    required this.onSwitched,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 4,
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              label,
              textScaleFactor: 1.1,
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: AnimatedCrossFade(
            firstChild: Container(),
            secondChild: FormField<bool>(
              initialValue: enabled,
              builder: (FormFieldState<bool> field) {
                return SwitchListTile(
                  activeColor: theme.colorScheme.primary,
                  contentPadding: const EdgeInsets.all(0),
                  value: enabled,
                  onChanged: onSwitched,
                );
              },
            ),
            crossFadeState:
                enabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        )
      ],
    );
  }
}
