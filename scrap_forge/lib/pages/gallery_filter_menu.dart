import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/utils/pick_date.dart';
import 'package:scrap_forge/utils/safe_calculator.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';
import 'package:scrap_forge/widgets/input_reset_switch.dart';
import 'package:scrap_forge/widgets/settings_section.dart';
import 'package:scrap_forge/widgets/shared_input_error.dart';

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

  bool enableLength = false;
  bool enableWidth = false;
  bool enableHeight = false;

  TextEditingController minLength = TextEditingController();
  TextEditingController minWidth = TextEditingController();
  TextEditingController minHeight = TextEditingController();
  TextEditingController maxLength = TextEditingController();
  TextEditingController maxWidth = TextEditingController();
  TextEditingController maxHeight = TextEditingController();

  final lengthUnitController = TextEditingController();
  SizeUnit lengthUnit = SizeUnit.millimeter;
  final widthUnitController = TextEditingController();
  SizeUnit widthUnit = SizeUnit.millimeter;
  final heightUnitController = TextEditingController();
  SizeUnit heightUnit = SizeUnit.millimeter;

  bool enableStartDate = false;
  TextEditingController minStartDate = TextEditingController();
  TextEditingController maxStartDate = TextEditingController();

  bool enableFinishDate = false;
  TextEditingController minFinishDate = TextEditingController();
  TextEditingController maxFinishDate = TextEditingController();

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

    minLength.text = getInitialDimensionFilter(
      filter.minDimensions?.length,
      filter.minDimensions?.lengthDisplayUnit,
    );

    minWidth.text = getInitialDimensionFilter(
      filter.minDimensions?.width,
      filter.minDimensions?.widthDisplayUnit,
    );
    minHeight.text = getInitialDimensionFilter(
      filter.minDimensions?.height,
      filter.minDimensions?.heightDisplayUnit,
    );

    maxLength.text = getInitialDimensionFilter(
      filter.maxDimensions?.length,
      filter.maxDimensions?.lengthDisplayUnit,
    );
    maxWidth.text = getInitialDimensionFilter(
      filter.maxDimensions?.width,
      filter.maxDimensions?.widthDisplayUnit,
    );
    maxHeight.text = getInitialDimensionFilter(
      filter.maxDimensions?.height,
      filter.maxDimensions?.heightDisplayUnit,
    );

    enableLength = (minLength.text.isNotEmpty || maxLength.text.isNotEmpty);
    enableWidth = (minWidth.text.isNotEmpty || maxWidth.text.isNotEmpty);
    enableHeight = (minHeight.text.isNotEmpty || maxHeight.text.isNotEmpty);

    lengthUnit = (filter.minDimensions?.lengthDisplayUnit ??
        filter.maxDimensions?.lengthDisplayUnit ??
        SizeUnit.millimeter);
    widthUnit = (filter.minDimensions?.widthDisplayUnit ??
        filter.maxDimensions?.widthDisplayUnit ??
        SizeUnit.millimeter);
    heightUnit = (filter.minDimensions?.heightDisplayUnit ??
        filter.maxDimensions?.heightDisplayUnit ??
        SizeUnit.millimeter);

    minStartDate.text = getInitialDateFilter(filter.minStartDate);
    maxStartDate.text = getInitialDateFilter(filter.maxStartDate);
    minFinishDate.text = getInitialDateFilter(filter.minFinishDate);
    maxFinishDate.text = getInitialDateFilter(filter.maxFinishDate);
  }

  String? minMaxDateValidator(
    TextEditingController minController,
    TextEditingController maxController,
  ) {
    if (minController.text.isEmpty && maxController.text.isEmpty) {
      return null;
    }
    DateTime? minDate = DateTime.tryParse(minController.text);
    DateTime? maxDate = DateTime.tryParse(maxController.text);

    if (minDate != null && maxDate != null && minDate.isAfter(maxDate)) {
      return "Minimalna data nie może być większa od maksymalnej.";
    }
    return null;
  }

  String? minMaxValidator(
    TextEditingController minController,
    TextEditingController maxController,
  ) {
    if (minController.text.isEmpty && maxController.text.isEmpty) {
      return null;
    }
    num? minValue = filterFieldValue(minController.text);
    num? maxValue = filterFieldValue(maxController.text);
    if ((minController.text.isNotEmpty && minValue == null) ||
        (maxController.text.isNotEmpty && maxValue == null)) {
      return "Wpisz liczbę dodatnią, lub pozostaw pole puste.";
    }
    if (minValue != null && maxValue != null && minValue > maxValue) {
      return "Wartość minimalna nie może być większa od maksymalnej";
    }
    return null;
  }

  String getInitialDimensionFilter(double? value, SizeUnit? unit) {
    return (SafeCalculator.divide(
              value,
              unit?.multiplier,
            ) ??
            '')
        .toString();
  }

  num? filterFieldValue(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    num? value = double.tryParse(input.replaceAll(RegExp(','), '.'));

    return value;
  }

  String getInitialDateFilter(DateTime? date) {
    if (date == null) {
      return '';
    }
    return date.toString().split(' ')[0];
  }

  DateTime? filterFieldDate(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    DateTime? date = DateTime.tryParse(input);

    return date;
  }

  List<Widget> minMaxInputs({
    required TextEditingController minController,
    required TextEditingController maxController,
    required void Function(bool value) onSwitched,
    required TextInputType type,
    required List<TextInputFormatter> inputFormatters,
  }) {
    return [
      CustomTextField(
        label: const Text("Od:"),
        type: type,
        inputFormatters: inputFormatters,
        controller: minController,
        validator: (value) => null,
        onChanged: (value) {
          bool shouldEnable = value != null && value.isNotEmpty ||
              maxController.text.isNotEmpty;
          onSwitched(shouldEnable);
        },
      ),
      CustomTextField(
        label: const Text("Do:"),
        type: type,
        inputFormatters: inputFormatters,
        controller: maxController,
        validator: (value) => null,
        onChanged: (value) {
          bool shouldEnable = value != null && value.isNotEmpty ||
              minController.text.isNotEmpty;
          onSwitched(shouldEnable);
        },
      ),
    ];
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
                  customFilter
                    // ..showFinished =
                    ..showProjects = customFilter.showFinished ||
                        customFilter.showInProgress ||
                        customFilter.showPlanned
                    ..showMaterials = enableMaterials
                    ..nameHas = nameController.text
                    ..minConsumed = filterFieldValue(minConsumed.text)?.toInt()
                    ..minAvailable =
                        filterFieldValue(minAvaliable.text)?.toInt()
                    ..minNeeded = filterFieldValue(minNeeded.text)?.toInt()
                    ..maxConsumed = filterFieldValue(maxConsumed.text)?.toInt()
                    ..maxAvailable =
                        filterFieldValue(maxAvaliable.text)?.toInt()
                    ..maxNeeded = filterFieldValue(maxNeeded.text)?.toInt()
                    ..minDimensions = Dimensions(
                      length: SafeCalculator.multiply(
                        filterFieldValue(minLength.text)?.toDouble(),
                        lengthUnit.multiplier,
                      )?.toDouble(),
                      width: SafeCalculator.multiply(
                        filterFieldValue(minWidth.text)?.toDouble(),
                        widthUnit.multiplier,
                      )?.toDouble(),
                      height: SafeCalculator.multiply(
                        filterFieldValue(minHeight.text)?.toDouble(),
                        heightUnit.multiplier,
                      )?.toDouble(),
                      lengthDisplayUnit: lengthUnit,
                      widthDisplayUnit: widthUnit,
                      heightDisplayUnit: heightUnit,
                    )
                    ..maxDimensions = Dimensions(
                      length: SafeCalculator.multiply(
                              filterFieldValue(maxLength.text)?.toDouble(),
                              lengthUnit.multiplier)
                          ?.toDouble(),
                      width: SafeCalculator.multiply(
                        filterFieldValue(maxWidth.text)?.toDouble(),
                        widthUnit.multiplier,
                      )?.toDouble(),
                      height: SafeCalculator.multiply(
                              filterFieldValue(maxHeight.text)?.toDouble(),
                              heightUnit.multiplier)
                          ?.toDouble(),
                      lengthDisplayUnit: lengthUnit,
                      widthDisplayUnit: widthUnit,
                      heightDisplayUnit: heightUnit,
                    )
                    ..minStartDate = filterFieldDate(minStartDate.text)
                    ..maxStartDate = filterFieldDate(maxStartDate.text)
                    ..minFinishDate = filterFieldDate(minFinishDate.text)
                    ..maxFinishDate = filterFieldDate(maxFinishDate.text);

                  widget.setFilter(customFilter);
                  // print(customFilter.nameHas);
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
                    label: const Text("Nazwa:"),
                    controller: nameController,
                    validator: (value) => null,
                  ),
                  CustomTextField(
                    label: const Text("Kategoria:"),
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
                      child: Text(
                        "Wyświetl tylko projekty:",
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                        ),
                        textScaleFactor: 1.15,
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
                    header: InputResetSwitch(
                      label: "Data rozpoczęcia",
                      enabled: enableStartDate,
                      onSwitched: (enable) {
                        setState(() {
                          enableStartDate = enable;
                        });
                        if (!enable) {
                          minStartDate.text = '';
                          maxStartDate.text = '';
                        }
                      },
                    ),
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: CustomTextField(
                              onTap: () async {
                                DateTime? date = await selectDate(context);

                                if (date != null) {
                                  minStartDate.text =
                                      date.toString().split(" ")[0];
                                  setState(() {
                                    enableStartDate = true;
                                  });
                                }
                              },
                              readOnly: true,
                              label: const Text("Od"),
                              controller: minStartDate,
                              validator: (value) => null,
                              prefixIcon:
                                  const Icon(Icons.calendar_today_outlined),
                            ),
                          ),
                          Flexible(
                            child: CustomTextField(
                              onTap: () async {
                                DateTime? date = await selectDate(context);

                                if (date != null) {
                                  maxStartDate.text =
                                      date.toString().split(" ")[0];
                                  setState(() {
                                    enableStartDate = true;
                                  });
                                }
                              },
                              readOnly: true,
                              label: const Text("Do"),
                              controller: maxStartDate,
                              validator: (value) => null,
                              prefixIcon:
                                  const Icon(Icons.calendar_today_outlined),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: SharedErrorField(
                              validator: (value) => minMaxDateValidator(
                                minStartDate,
                                maxStartDate,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SettingsSection(
                    header: InputResetSwitch(
                      label: "Data ukończenia",
                      enabled: enableFinishDate,
                      onSwitched: (enable) {
                        setState(() {
                          enableFinishDate = enable;
                        });
                        if (!enable) {
                          minFinishDate.text = '';
                          maxFinishDate.text = '';
                        }
                      },
                    ),
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: CustomTextField(
                              onTap: () async {
                                DateTime? date = await selectDate(context);

                                if (date != null) {
                                  minFinishDate.text =
                                      date.toString().split(" ")[0];
                                  setState(() {
                                    enableFinishDate = true;
                                  });
                                }
                              },
                              readOnly: true,
                              label: const Text("Od"),
                              controller: minFinishDate,
                              validator: (value) => null,
                              prefixIcon:
                                  const Icon(Icons.calendar_today_outlined),
                            ),
                          ),
                          Flexible(
                            child: CustomTextField(
                              onTap: () async {
                                DateTime? date = await selectDate(context);

                                if (date != null) {
                                  maxFinishDate.text =
                                      date.toString().split(" ")[0];
                                  setState(() {
                                    enableFinishDate = true;
                                  });
                                }
                              },
                              readOnly: true,
                              label: const Text("Do"),
                              controller: maxFinishDate,
                              validator: (value) => null,
                              prefixIcon:
                                  const Icon(Icons.calendar_today_outlined),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: SharedErrorField(
                              validator: (value) => minMaxDateValidator(
                                minFinishDate,
                                maxFinishDate,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
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
                            title: Text(
                              "Wyświetl tylko materiały:",
                              style: TextStyle(
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
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
                            InputResetSwitch(
                              label: label,
                              enabled: enabled,
                              onSwitched: onSwitched,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: minMaxInputs(
                                minController: minController,
                                maxController: maxController,
                                onSwitched: onSwitched,
                                type: const TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: false,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              )
                                  .map((widget) => Flexible(child: widget))
                                  .toList(),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: SharedErrorField(
                                    validator: (value) => minMaxValidator(
                                      minController,
                                      maxController,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ).toList(),
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
                      child: Text(
                        "Wymiary:",
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                        ),
                        textScaleFactor: 1.2,
                      ),
                    ),
                    children: [
                      ...[
                        {
                          'label': "Długość:",
                          'enabled': enableLength,
                          'onChanged': (bool enabled) {
                            if (!enabled) {
                              minLength.text = '';
                              maxLength.text = '';
                            }
                            setState(() {
                              enableLength = enabled;
                            });
                          },
                          'minController': minLength,
                          'maxController': maxLength,
                          'unitController': lengthUnitController,
                          'unit': lengthUnit,
                          'setUnit': (value) {
                            setState(() {
                              lengthUnit = value ?? SizeUnit.millimeter;
                            });
                          }
                        },
                        {
                          'label': "Szerokość:",
                          'enabled': enableWidth,
                          'onChanged': (bool enabled) {
                            if (!enabled) {
                              minWidth.text = '';
                              maxWidth.text = '';
                            }
                            setState(() {
                              enableWidth = enabled;
                            });
                          },
                          'minController': minWidth,
                          'maxController': maxWidth,
                          'unitController': widthUnitController,
                          'unit': widthUnit,
                          'setUnit': (value) {
                            setState(() {
                              widthUnit = value ?? SizeUnit.millimeter;
                            });
                          }
                        },
                        {
                          'label': "Wysokość:",
                          'enabled': enableHeight,
                          'onChanged': (bool enabled) {
                            if (!enabled) {
                              minHeight.text = '';
                              maxHeight.text = '';
                            }
                            setState(() {
                              enableHeight = enabled;
                            });
                          },
                          'minController': minHeight,
                          'maxController': maxHeight,
                          'unitController': heightUnitController,
                          'unit': heightUnit,
                          'setUnit': (value) {
                            setState(() {
                              heightUnit = value ?? SizeUnit.millimeter;
                            });
                          }
                        },
                      ].map((dim) {
                        String label = dim['label'] as String;
                        bool enabled = dim['enabled'] as bool;
                        void Function(bool value) onSwitched =
                            dim['onChanged'] as void Function(bool val);
                        TextEditingController minController =
                            dim['minController'] as TextEditingController;
                        TextEditingController maxController =
                            dim['maxController'] as TextEditingController;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InputResetSwitch(
                              label: label,
                              enabled: enabled,
                              onSwitched: onSwitched,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...minMaxInputs(
                                  minController: minController,
                                  maxController: maxController,
                                  onSwitched: onSwitched,
                                  type: const TextInputType.numberWithOptions(
                                    signed: false,
                                    decimal: false,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp('[0-9.,]'),
                                    )
                                  ],
                                )
                                    .map((widget) => Flexible(child: widget))
                                    .toList(),
                                Flexible(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  child: DropdownMenu<SizeUnit>(
                                    width: 100,
                                    inputDecorationTheme: InputDecorationTheme(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 22, horizontal: 10),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: theme.colorScheme.outline,
                                            width: 1),
                                      ),
                                    ),
                                    dropdownMenuEntries: const [
                                      DropdownMenuEntry(
                                          value: SizeUnit.millimeter,
                                          label: "mm"),
                                      DropdownMenuEntry(
                                          value: SizeUnit.centimeter,
                                          label: "cm"),
                                      DropdownMenuEntry(
                                          value: SizeUnit.meter, label: "m"),
                                    ],
                                    initialSelection: dim['unit'] as SizeUnit,
                                    controller: dim['unitController']
                                        as TextEditingController,
                                    onSelected: dim['setUnit'] as ValueSetter,
                                  ),
                                ))
                              ],
                            ),
                            //Error field
                            Row(
                              children: [
                                Flexible(
                                  child: SharedErrorField(
                                    validator: (value) => minMaxValidator(
                                      minController,
                                      maxController,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
