import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';

class MinMaxInput extends StatelessWidget {
  final String? label;
  final bool enabled;
  final void Function(bool value) onSwitched;
  final TextEditingController minController;
  final TextEditingController maxController;
  const MinMaxInput({
    super.key,
    this.label,
    required this.enabled,
    required this.minController,
    required this.maxController,
    required this.onSwitched,
  });

  int? filterFieldValue(
    bool enabled,
    String? input, {
    int? ifDisabled = null,
    int? ifEmpty = null,
  }) {
    if (!enabled) return ifDisabled;
    if (input == null || input.isEmpty) return ifEmpty;
    return int.tryParse(input);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  label ?? '',
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
                crossFadeState: enabled
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            )
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: CustomTextField(
                label: Text("Od:"),
                type: const TextInputType.numberWithOptions(signed: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: minController,
                validator: (value) {
                  if (value != null) {
                    int? minValue = int.tryParse(value);
                    int? maxValue = filterFieldValue(true, maxController.text);
                    if (minValue == null ||
                        maxValue == null ||
                        minValue <= maxValue) {
                      return null;
                    }
                    return "Wartość minimalna nie może być większa od maksymalnej";
                  }
                  return "Wpisz dodatnią liczbę całkowitą, lub pozostaw to pole puste.";
                },
                onChanged: (value) {
                  bool shouldEnable = value != null && value.isNotEmpty ||
                      maxController.text.isNotEmpty;
                  onSwitched(shouldEnable);
                },
              ),
            ),
            Flexible(
              child: CustomTextField(
                label: Text("Do:"),
                type: const TextInputType.numberWithOptions(signed: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: maxController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }

                  int? maxValue = int.tryParse(value);

                  if (maxValue != null) {
                    return null;
                  }

                  return "Wpisz dodatnią liczbę całkowitą, lub pozostaw to pole puste.";
                },
                onChanged: (value) {
                  bool shouldEnable = value != null && value.isNotEmpty ||
                      minController.text.isNotEmpty;
                  onSwitched(shouldEnable);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
