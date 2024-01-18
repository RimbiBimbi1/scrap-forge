import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';
import 'package:scrap_forge/widgets/settings_section.dart';
import 'dart:math';

class GalleryFilterMenu extends StatefulWidget {
  final void Function(ProductFilter filter) setFilter;
  final ProductFilter filter;
  const GalleryFilterMenu(
      {super.key, required this.setFilter, required this.filter});

  @override
  State<GalleryFilterMenu> createState() => _GalleryFilterMenuState();
}

class _GalleryFilterMenuState extends State<GalleryFilterMenu> {
  final _formKey = GlobalKey<FormState>();
  ProductFilter customFilter = ProductFilter();

  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  bool enableMaterials = false;
  bool enableConsumed = false;
  bool enableAvailable = false;
  bool enableNeeded = false;

  TextEditingController minConsumed = TextEditingController();
  TextEditingController minAvaliable = TextEditingController();
  TextEditingController minNeeded = TextEditingController();
  TextEditingController maxConsumed = TextEditingController();
  TextEditingController maxAvaliable = TextEditingController();
  TextEditingController maxNeeded = TextEditingController();

  @override
  void initState() {
    super.initState();
    ProductFilter filter = widget.filter;

    this.customFilter = filter;
    enableMaterials = filter.showMaterials;
    enableConsumed = filter.minConsumed != null || filter.maxConsumed != null;
    enableAvailable =
        filter.minAvailable != null || filter.maxAvailable != null;
    enableNeeded = filter.minNeeded != null || filter.maxNeeded != null;
    minConsumed.text = (filter.minConsumed ?? '').toString();
    minAvaliable.text = (filter.minAvailable ?? '').toString();
    minNeeded.text = (filter.minNeeded ?? '').toString();
    maxConsumed.text = (filter.maxConsumed ?? '').toString();
    maxAvaliable.text = (filter.maxAvailable ?? '').toString();
    maxNeeded.text = (filter.maxNeeded ?? '').toString();
  }

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filtry"),
        actions: [
          IconButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.setFilter(
                    customFilter
                      ..showProjects = customFilter.showFinished ||
                          customFilter.showInProgress ||
                          customFilter.showPlanned
                      ..showMaterials = enableMaterials
                      ..nameHas = nameController.text
                      ..minConsumed = filterFieldValue(
                        enableConsumed,
                        minConsumed.text,
                      )
                      ..minAvailable = filterFieldValue(
                        enableAvailable,
                        minAvaliable.text,
                      )
                      ..minNeeded = filterFieldValue(
                        enableNeeded,
                        minNeeded.text,
                      )
                      ..maxConsumed = filterFieldValue(
                        enableConsumed,
                        maxConsumed.text,
                      )
                      ..maxAvailable = filterFieldValue(
                        enableAvailable,
                        maxAvaliable.text,
                      )
                      ..maxNeeded = filterFieldValue(
                        enableNeeded,
                        maxNeeded.text,
                      ),
                  );
                }
              },
              icon: const Icon(Icons.check))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: "Nazwa:",
                    controller: nameController,
                    validator: (value) => null,
                  ),
                  CustomTextField(
                    label: "Kategoria:",
                    controller: categoryController,
                    validator: (value) => null,
                  ),
                  SettingsSection(
                    header: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          bottom: BorderSide(
                              color: theme.colorScheme.outline, width: 2),
                        ),
                      ),
                      child: const Text(
                        "Wyświetl projekty:",
                        textScaleFactor: 1.2,
                      ),
                    ),
                    children: [
                      {
                        'label': "Ukończone",
                        'value': customFilter.showFinished,
                        'onChanged': (bool value) {
                          setState(() {
                            customFilter = customFilter..showFinished = value;
                          });
                        }
                      },
                      {
                        'label': "W trakcie realizacji",
                        'value': customFilter.showInProgress,
                        'onChanged': (bool value) {
                          setState(() {
                            customFilter = customFilter..showInProgress = value;
                          });
                        }
                      },
                      {
                        'label': "Planowane",
                        'value': customFilter.showPlanned,
                        'onChanged': (bool value) {
                          setState(() {
                            customFilter = customFilter..showPlanned = value;
                          });
                        }
                      },
                    ]
                        .map(
                          (progress) => FormField<bool>(
                            initialValue: progress['value'] as bool,
                            builder: (FormFieldState<bool> field) {
                              return SwitchListTile(
                                activeColor: theme.colorScheme.primary,
                                contentPadding: const EdgeInsets.all(0),
                                title: Text(progress['label'] as String),
                                value: progress['value'] as bool,
                                onChanged: progress['onChanged'] as void
                                    Function(bool val),
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
                  SettingsSection(
                    header: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          bottom: BorderSide(
                              color: theme.colorScheme.outline, width: 2),
                        ),
                      ),
                      child: FormField<bool>(
                        initialValue: enableMaterials,
                        builder: (FormFieldState<bool> field) {
                          return SwitchListTile(
                            activeColor: theme.colorScheme.primary,
                            contentPadding: const EdgeInsets.all(0),
                            title: Text("Wyświetl materiały:"),
                            value: enableMaterials,
                            onChanged: (value) {
                              if (!value) {
                                minConsumed.text = '';
                                maxConsumed.text = '';
                                minAvaliable.text = '';
                                maxAvaliable.text = '';
                                minNeeded.text = '';
                                maxNeeded.text = '';
                              }
                              setState(() {
                                enableMaterials = value;
                                if (!value) {
                                  enableConsumed = false;
                                  enableAvailable = false;
                                  enableNeeded = false;
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    children: [
                      {
                        'label': "Wykorzystane w liczbie:",
                        'enabled': enableConsumed,
                        'onChanged': (bool enabled) {
                          if (!enabled) {
                            minConsumed.text = '';
                            maxConsumed.text = '';
                          }
                          setState(() {
                            enableConsumed = enabled;
                            if (enabled) {
                              enableMaterials = true;
                            }
                          });
                        },
                        'minController': minConsumed,
                        'maxController': maxConsumed,
                      },
                      {
                        'label': "Dostępne w liczbie:",
                        'enabled': enableAvailable,
                        'onChanged': (bool enabled) {
                          if (!enabled) {
                            minAvaliable.text = '';
                            maxAvaliable.text = '';
                          }
                          setState(() {
                            enableAvailable = enabled;
                            if (enabled) {
                              enableMaterials = true;
                            }
                          });
                        },
                        'minController': minAvaliable,
                        'maxController': maxAvaliable,
                      },
                      {
                        'label': "Potrzebne w liczbie:",
                        'enabled': enableNeeded,
                        'onChanged': (bool enabled) {
                          if (!enabled) {
                            minNeeded.text = '';
                            maxNeeded.text = '';
                          }
                          setState(() {
                            enableNeeded = enabled;
                            if (enabled) {
                              enableMaterials = true;
                            }
                          });
                        },
                        'minController': minNeeded,
                        'maxController': maxNeeded,
                      },
                    ].map(
                      (progress) {
                        String label = progress['label'] as String;
                        bool enabled = progress['enabled'] as bool;
                        void Function(bool value) onSwitched =
                            progress['onChanged'] as void Function(bool val);
                        TextEditingController minController =
                            progress['minController'] as TextEditingController;
                        TextEditingController maxController =
                            progress['maxController'] as TextEditingController;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    child: Text(label),
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
                                          activeColor:
                                              theme.colorScheme.primary,
                                          contentPadding:
                                              const EdgeInsets.all(0),
                                          value: enabled,
                                          onChanged: onSwitched,
                                        );
                                      },
                                    ),
                                    crossFadeState: enabled
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: Duration(milliseconds: 200),
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
                                    label: "Co najmniej:",
                                    type: const TextInputType.numberWithOptions(
                                        signed: false),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    controller: progress['minController']
                                        as TextEditingController,
                                    validator: (value) {
                                      if (value != null) {
                                        int? minValue = int.tryParse(value);
                                        int? maxValue = filterFieldValue(
                                            true, maxController.text);
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
                                      bool shouldEnable =
                                          value != null && value.isNotEmpty ||
                                              maxController.text.isNotEmpty;
                                      onSwitched(shouldEnable);
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: CustomTextField(
                                    label: "Co najwyżej:",
                                    type: const TextInputType.numberWithOptions(
                                        signed: false),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    controller: progress['maxController']
                                        as TextEditingController,
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
                                      bool shouldEnable =
                                          value != null && value.isNotEmpty ||
                                              minController.text.isNotEmpty;
                                      onSwitched(shouldEnable);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                  SettingsSection(header: Text("Wymiary:"), children: [
                    SettingsSection(header: Text("Wieksze niż:"), children: []),
                    SettingsSection(
                        header: Text("Mniejsze niż:"), children: []),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
