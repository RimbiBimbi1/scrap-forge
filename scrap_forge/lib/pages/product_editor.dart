import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/utils/pick_date.dart';
import 'package:scrap_forge/utils/safe_calculator.dart';
import 'package:scrap_forge/utils/string_multiliner.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';
import 'package:scrap_forge/widgets/shared_input_error.dart';

class ProductEditor extends StatefulWidget {
  final BuildContext context;
  final SizeUnit defaultSizeUnit;
  const ProductEditor(
      {super.key, required this.context, required this.defaultSizeUnit});

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  IsarService db = IsarService();

  Product? edit;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final countController = TextEditingController();
  final categoryController = TextEditingController();

  final lengthController = TextEditingController();
  final lengthUnitController = TextEditingController();
  SizeUnit lengthUnit = SizeUnit.millimeter;

  final widthController = TextEditingController();
  final widthUnitController = TextEditingController();
  SizeUnit widthUnit = SizeUnit.millimeter;

  final heightController = TextEditingController();
  final heightUnitController = TextEditingController();
  SizeUnit heightUnit = SizeUnit.millimeter;

  final areaController = TextEditingController();
  final areaUnitController = TextEditingController();
  SizeUnit areaUnit = SizeUnit.centimeter;

  bool addAsProject = true;
  final progressController = TextEditingController();
  ProjectLifeCycle? progress = ProjectLifeCycle.inProgress;

  bool addAsMaterial = false;
  final consumedController = TextEditingController();
  final availableController = TextEditingController();
  final neededController = TextEditingController();

  TextEditingController startDate = TextEditingController();
  TextEditingController finishDate = TextEditingController();

  List<Photo> photos = List.empty();
  List<Product> madeFrom = List.empty();
  List<Product> usedIn = List.empty();

  List<Widget> displayedPhotos = List.empty();

  List<Widget> displayPhotos(List<Photo> photos) {
    return photos
        .asMap()
        .map(
          (index, bytes) => MapEntry(
            index,
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                alignment: AlignmentDirectional.topEnd,
                height: 200,
                width: 135,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  image: DecorationImage(
                      image: MemoryImage(
                        Uint8List.fromList(
                          bytes.data,
                        ),
                      ),
                      fit: BoxFit.cover),
                ),
                child: IconButton(
                  onPressed: () {
                    List<Photo> temp = List.from(photos);
                    temp.removeAt(index);
                    setState(() {
                      this.photos = temp;
                      this.displayedPhotos = displayPhotos(temp);
                    });
                  },
                  icon: const Icon(
                    Icons.close_outlined,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  @override
  void initState() {
    super.initState();

    lengthUnit = widget.defaultSizeUnit;
    widthUnit = widget.defaultSizeUnit;
    heightUnit = widget.defaultSizeUnit;
    areaUnit = widget.defaultSizeUnit;

    final arguments = (ModalRoute.of(widget.context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (arguments.isNotEmpty) {
      Product? product = arguments['productData'];

      //init controllers

      if (product != null) {
        nameController.text = product.name ?? "";
        descriptionController.text =
            StringMultiliner.multiline(product.description ?? "")
                .toString()
                .trimLeft()
                .trimRight();
        countController.text =
            (product.count != null) ? product.count.toString() : "";
        categoryController.text = product.category ?? "";
        if (product.dimensions != null) {
          lengthController.text = getInitialDimension(
            product.dimensions?.length,
            product.dimensions?.lengthDisplayUnit,
          );
          lengthUnitController.text =
              "${product.dimensions!.lengthDisplayUnit?.abbr}";

          widthController.text = getInitialDimension(
            product.dimensions?.width,
            product.dimensions?.widthDisplayUnit,
          );
          widthUnitController.text =
              "${product.dimensions!.widthDisplayUnit?.abbr}";

          heightController.text = getInitialDimension(
            product.dimensions?.height,
            product.dimensions?.heightDisplayUnit,
          );
          heightUnitController.text =
              "${product.dimensions!.heightDisplayUnit?.abbr}";

          areaController.text = getInitialDimension(
            SafeCalculator.divide(
              product.dimensions?.projectionArea,
              product.dimensions?.areaDisplayUnit?.multiplier,
            )?.toDouble(),
            product.dimensions?.areaDisplayUnit,
          );
          areaUnitController.text =
              "${product.dimensions!.areaDisplayUnit?.abbr}";
        }
        progress = product.progress;
        consumedController.text =
            (product.consumed != null) ? product.consumed.toString() : "0";
        availableController.text =
            (product.available != null) ? product.available.toString() : "0";
        neededController.text =
            (product.needed != null) ? product.needed.toString() : "0";

        //init other variables

        addAsProject = product.progress != null;
        addAsMaterial = (product.consumed != null ||
            product.available != null ||
            product.needed != null);

        // photos = product.photos.map((photo) => base64Decode(photo)).toList();
        photos = product.photos;
        displayedPhotos = displayPhotos(photos);

        madeFrom = product.madeFrom.toList();

        usedIn = product.usedIn.toList();

        if (product.dimensions != null) {
          lengthUnit =
              product.dimensions!.lengthDisplayUnit ?? widget.defaultSizeUnit;
          widthUnit =
              product.dimensions!.widthDisplayUnit ?? widget.defaultSizeUnit;
          heightUnit =
              product.dimensions!.heightDisplayUnit ?? widget.defaultSizeUnit;
          areaUnit =
              product.dimensions!.areaDisplayUnit ?? widget.defaultSizeUnit;
        }

        startDate.text = getInitialDateString(
            product.startedTimestamp ?? DateTime.now().millisecondsSinceEpoch);

        finishDate.text = getInitialDateString(product.finishedTimestamp);

        edit = product;
      }
    }
  }

  String getInitialDimension(double? value, SizeUnit? unit) {
    num? result = SafeCalculator.divide(
      value,
      unit?.multiplier,
    );
    return (result != null ? result.toStringAsFixed(2) : '').toString();
  }

  String getInitialDateString(int? timestamp) {
    if (timestamp == null) {
      return '';
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp)
        .toString()
        .split(' ')[0];
  }

  int? asMaterialValueParse(String? value) {
    if (addAsMaterial) {
      if (value != null && value.isNotEmpty) {
        return int.parse(value);
      }
      return 0;
    }
    return null;
  }

  num? textFieldValue(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    num? value = double.tryParse(input.replaceAll(RegExp(','), '.'));
    if (value == null) {
      return null;
    }
    return value;
  }

  DateTime? textFieldDate(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }
    DateTime? date = DateTime.tryParse(input);
    return date;
  }

  String? numberValidator(String? value) {
    if (value == null || value == "") {
      return null;
    }
    RegExp digits = RegExp("^[0-9]*[,.]?[0-9]*");
    Match? match = digits.matchAsPrefix(value);
    if (match != null && match.group(0)!.length == value.length) {
      return null;
    }

    return "Wpisz liczbę dodatnią, lub pozostaw pole puste.";
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
      return "Data zakończenia nie może być wcześniejsza od daty rozpoczęcia.";
    }
    return null;
  }

  String? switchValidator(final value) {
    if (!addAsMaterial && !addAsProject) {
      return "Zaznacz przynajmniej jedną z opcji";
    }
    if (addAsMaterial &&
        consumedController.text == "" &&
        availableController.text == "" &&
        neededController.text == "") {
      return "Uzupełnij jedno z powyższych pól";
    }
    return null;
  }

  Future<Uint8List> fromXFile(XFile file) async {
    return await file.readAsBytes();
  }

  Future<void> pickImagesFromGallery() async {
    List<XFile> images = await ImagePicker().pickMultiImage(
      maxHeight: 1080,
      maxWidth: 1080,
      imageQuality: 75,
    );
    List<Uint8List> bytes =
        await Future.wait(images.map((img) => img.readAsBytes()));
    List<Photo> added = bytes.map((data) => Photo()..data = data).toList();
    List<Photo> photos = [...this.photos, ...added];
    if (photos.length > 10) photos = photos.sublist(0, 10);
    setState(() {
      this.photos = photos;
      displayedPhotos = displayPhotos(photos);
    });
  }

  Future<void> pickImageFromCamera() async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 1080,
      maxWidth: 1080,
      imageQuality: 75,
    );
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      Photo added = Photo()..data = bytes;
      List<Photo> photos = [...this.photos, added];
      if (photos.length > 10) photos = photos.sublist(0, 10);
      setState(() {
        this.photos = photos;
        displayedPhotos = displayPhotos(photos);
      });
    }
  }

  void onMaterialsUsedPicked(List<Product> materials) {
    materials.removeWhere(
        (p) => madeFrom.any((u) => u.id == p.id) || edit?.id == p.id);
    setState(() {
      madeFrom = [
        ...madeFrom,
        ...materials,
      ];
    });
    Navigator.pop(context);
  }

  void onProductsMadeWithPicked(List<Product> products) {
    products.removeWhere(
        (p) => usedIn.any((u) => u.id == p.id) || edit?.id == p.id);
    setState(() {
      usedIn = [
        ...usedIn,
        ...products,
      ];
    });
    Navigator.pop(context);
  }

  Text label(String text) => Text(
        text,
        textScaleFactor: 1.2,
      );

  void updateDimensions(List<double> received) {
    List<TextEditingController> dimCtrls =
        List.from([lengthController, widthController, heightController]);
    List<SizeUnit> dimUnits = List.from([lengthUnit, widthUnit, heightUnit]);

    int emptyCount = List.from(dimCtrls.map((e) => e.text.isEmpty ? 1 : 0))
        .reduce((value, element) => value + element);

    switch (emptyCount) {
      case 3:
        lengthController.text =
            (received[0] / lengthUnit.multiplier).toStringAsFixed(2);
        widthController.text =
            (received[1] / widthUnit.multiplier).toStringAsFixed(2);
        break;
      case 2:
        int updatedCount = 0;
        for (final (index, ctrl) in dimCtrls.indexed) {
          if (ctrl.text.isEmpty) {
            ctrl.text = (received[updatedCount] / dimUnits[index].multiplier)
                .toStringAsFixed(2);
            updatedCount++;
          }
        }
        break;
      case 1:
        int toUpdate = 2;
        int updatedCount = 0;
        List<double> diffs = List.empty(growable: true);
        for (final (index, ctrl) in dimCtrls.indexed) {
          if (ctrl.text.isNotEmpty) {
            diffs.add((double.parse(ctrl.text) * dimUnits[index].multiplier -
                    received[updatedCount])
                .abs());
            updatedCount++;
          } else {
            toUpdate = index;
          }
        }
        dimCtrls[toUpdate].text =
            (((diffs[0] > diffs[1]) ? received[0] : received[1]) /
                    dimUnits[toUpdate].multiplier)
                .toStringAsFixed(2);
        break;
      default:
        break;
    }

    if (areaController.text.isEmpty) {
      areaController.text =
          (received[2] / (areaUnit.multiplier * areaUnit.multiplier))
              .toStringAsFixed(2);
    }
  }

  void confirmEdit() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        Product p = Product()
          ..name = nameController.text
          ..description = descriptionController.text
          ..count = int.tryParse(countController.text)
          ..photos = photos
          ..category = categoryController.text
          ..progress = addAsProject ? progress : null
          ..startedTimestamp = addAsProject
              ? textFieldDate(startDate.text)?.millisecondsSinceEpoch
              : null
          ..finishedTimestamp = addAsProject
              ? textFieldDate(finishDate.text)?.millisecondsSinceEpoch
              : null
          ..lastModifiedTimestamp = DateTime.now().millisecondsSinceEpoch
          ..dimensions = Dimensions(
            length: SafeCalculator.multiply(
              textFieldValue(lengthController.text),
              lengthUnit.multiplier,
            )?.toDouble(),
            lengthDisplayUnit: SizeUnit.fromString(lengthUnitController.text),
            width: SafeCalculator.multiply(
              textFieldValue(widthController.text),
              widthUnit.multiplier,
            )?.toDouble(),
            widthDisplayUnit: SizeUnit.fromString(widthUnitController.text),
            height: SafeCalculator.multiply(
              textFieldValue(heightController.text),
              heightUnit.multiplier,
            )?.toDouble(),
            heightDisplayUnit: SizeUnit.fromString(heightUnitController.text),
            projectionArea: SafeCalculator.multiply(
              SafeCalculator.multiply(
                textFieldValue(areaController.text),
                areaUnit.multiplier,
              ),
              areaUnit.multiplier,
            )?.toDouble(),
            areaDisplayUnit: SizeUnit.fromString(areaUnitController.text
                .substring(0, areaUnitController.text.length - 1)),
          )
          ..consumed = asMaterialValueParse(consumedController.text)
          ..available = asMaterialValueParse(availableController.text)
          ..needed = asMaterialValueParse(neededController.text)
          ..madeFrom.addAll(madeFrom)
          ..usedIn.addAll(usedIn);

        if (edit != null) {
          p.id = edit!.id;
        }
        db.saveProduct(p);

        if (edit != null) {
          Navigator.pop(context);
        }
        Navigator.pushReplacementNamed(
          context,
          "/product",
          arguments: {'productData': p},
        );
      }
    }
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
        title: Text(
            edit == null ? "Dodaj nowy produkt" : "Edytuj \"${edit?.name}\""),
        actions: [
          IconButton(onPressed: confirmEdit, icon: const Icon(Icons.check))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: const Text("Nazwa:"),
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value == "") {
                        return "To pole jest wymagane";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: const Text("Kategoria:"),
                    controller: categoryController,
                    validator: (value) {
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: const Text("Opis:"),
                    controller: descriptionController,
                    validator: (value) {
                      return null;
                    },
                    type: TextInputType.multiline,
                    maxLines: null,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Zdjęcia:",
                          textScaleFactor: 1.2,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("Dodaj maksymalnie 10 zdjęć"),
                      ),
                      SizedBox(
                        height: 200,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView(
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...displayedPhotos,
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  height: 200,
                                  width: 135,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.tight,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.background,
                                            side: BorderSide(
                                              color: theme.colorScheme.outline,
                                              width: 1,
                                            ),
                                          ),
                                          onPressed: pickImagesFromGallery,
                                          child: const Icon(
                                              Icons.add_photo_alternate),
                                        ),
                                      ),
                                      Flexible(
                                        fit: FlexFit.tight,
                                        child: OutlinedButton(
                                          onPressed: pickImageFromCamera,
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.background,
                                            side: BorderSide(
                                              color: theme.colorScheme.outline,
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(Icons.add_a_photo),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Wymiary:",
                            textScaleFactor: 1.2,
                            // style: TextStyle(color: Colors.white),
                          ),
                          Flexible(
                            flex: 10,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                color: theme.colorScheme.outline,
                                width: 1,
                              )),
                              onPressed: () {
                                Navigator.pushNamed(context, "/measure",
                                    arguments: {
                                      'onBoundingBoxConfirmed':
                                          updateDimensions,
                                    });
                              },
                              child: const Icon(
                                Icons.straighten,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...[
                        {
                          'label': "Długość",
                          'controller': lengthController,
                          'unitController': lengthUnitController,
                          'unit': lengthUnit,
                          'setUnit': (value) {
                            setState(() {
                              lengthUnit = value ?? SizeUnit.millimeter;
                            });
                          }
                        },
                        {
                          'label': "Szerokość",
                          'controller': widthController,
                          'unitController': widthUnitController,
                          'unit': widthUnit,
                          'setUnit': (value) {
                            setState(() {
                              widthUnit = value ?? SizeUnit.millimeter;
                            });
                          }
                        },
                        {
                          'label': "Wysokość",
                          'controller': heightController,
                          'unitController': heightUnitController,
                          'unit': heightUnit,
                          'setUnit': (value) {
                            setState(() {
                              heightUnit = value ?? SizeUnit.millimeter;
                            });
                          }
                        }
                      ]
                          .map((dimension) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      label: Text(dimension['label'] as String),
                                      controller: dimension['controller']
                                          as TextEditingController,
                                      validator: numberValidator,
                                      type:
                                          const TextInputType.numberWithOptions(
                                              signed: false),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[0-9.,]'))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 4,
                                    ),
                                    child: DropdownMenu<SizeUnit>(
                                      inputDecorationTheme:
                                          InputDecorationTheme(
                                        contentPadding:
                                            const EdgeInsets.all(20),
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
                                          value: SizeUnit.meter,
                                          label: "m",
                                        ),
                                      ],
                                      initialSelection:
                                          dimension['unit'] as SizeUnit,
                                      controller: dimension['unitController']
                                          as TextEditingController,
                                      onSelected:
                                          dimension['setUnit'] as ValueSetter,
                                    ),
                                  )
                                ],
                              ))
                          .toList(),
                      Row(
                        children: [
                          Flexible(
                            child: CustomTextField(
                              label: const Text("Powierzchnia rzutu:"),
                              controller: areaController,
                              validator: numberValidator,
                              type: TextInputType.number,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: DropdownMenu<SizeUnit>(
                              inputDecorationTheme: InputDecorationTheme(
                                contentPadding: const EdgeInsets.all(20),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.outline,
                                      width: 1),
                                ),
                              ),
                              dropdownMenuEntries: const [
                                DropdownMenuEntry(
                                    value: SizeUnit.millimeter,
                                    label: "mm\u00B2"),
                                DropdownMenuEntry(
                                    value: SizeUnit.centimeter,
                                    label: "cm\u00B2"),
                                DropdownMenuEntry(
                                    value: SizeUnit.meter, label: "m\u00B2"),
                              ],
                              initialSelection: areaUnit,
                              controller: areaUnitController,
                              onSelected: (value) => setState(() {
                                areaUnit = value ?? SizeUnit.millimeter;
                              }),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormField(
                        initialValue: addAsProject,
                        builder: (FormFieldState<bool> field) {
                          return SwitchListTile(
                            activeColor: theme.colorScheme.primary,
                            contentPadding: const EdgeInsets.all(0),
                            title: const Text("Dodaj jako projekt"),
                            value: addAsProject,
                            onChanged: (val) {
                              setState(() {
                                addAsProject = val;
                              });
                            },
                          );
                        },
                      ),
                      AnimatedCrossFade(
                          layoutBuilder: ((
                            topChild,
                            topChildKey,
                            bottomChild,
                            bottomChildKey,
                          ) {
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: <Widget>[
                                Positioned(
                                    key: bottomChildKey,
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: bottomChild),
                                Positioned(key: topChildKey, child: topChild),
                              ],
                            );
                          }),
                          crossFadeState: addAsProject
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 250),
                          firstChild: Column(
                            children: [
                              CustomTextField(
                                label: const Text("Ilość:"),
                                controller: countController,
                                validator: numberValidator,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: DropdownMenu<ProjectLifeCycle>(
                                  inputDecorationTheme: InputDecorationTheme(
                                    contentPadding: const EdgeInsets.all(20),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: theme.colorScheme.outline,
                                          width: 1),
                                    ),
                                  ),
                                  width: MediaQuery.of(context).size.width - 28,
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(
                                        value: ProjectLifeCycle.finished,
                                        label: "Ukończony"),
                                    DropdownMenuEntry(
                                        value: ProjectLifeCycle.inProgress,
                                        label: "W trakcie realizacji"),
                                    DropdownMenuEntry(
                                        value: ProjectLifeCycle.planned,
                                        label: "Planowany"),
                                  ],
                                  initialSelection:
                                      progress ?? ProjectLifeCycle.inProgress,
                                  controller: progressController,
                                  onSelected: (value) {
                                    if (value != null) {
                                      setState(() {
                                        progress = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              CustomTextField(
                                onTap: () async {
                                  DateTime? date = await selectDate(context);

                                  if (date != null) {
                                    startDate.text =
                                        date.toString().split(" ")[0];
                                  }
                                },
                                readOnly: true,
                                label: Text(
                                    "Data rozpoczęcia${progress == ProjectLifeCycle.planned ? ' (planowana)' : ''}"),
                                controller: startDate,
                                validator: (value) => null,
                                prefixIcon:
                                    const Icon(Icons.calendar_today_outlined),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.cancel_outlined),
                                  onPressed: () {
                                    startDate.text = '';
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              ),
                              CustomTextField(
                                onTap: () async {
                                  DateTime? date = await selectDate(context);
                                  if (date != null) {
                                    finishDate.text =
                                        date.toString().split(" ")[0];
                                  }
                                },
                                readOnly: true,
                                label: Text(
                                    "Data ukończenia${progress != ProjectLifeCycle.finished ? ' (planowana)' : ''}"),
                                controller: finishDate,
                                validator: (value) => minMaxDateValidator(
                                  startDate,
                                  finishDate,
                                ),
                                prefixIcon:
                                    const Icon(Icons.calendar_today_outlined),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.cancel_outlined),
                                  onPressed: () {
                                    finishDate.text = '';
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Flexible(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Text(
                                        "Wykonany z:",
                                        textScaleFactor: 1.1,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () => {
                                            Navigator.pushNamed(
                                                context, "/products",
                                                arguments: {
                                                  'productFilter':
                                                      ProductFilter.materials()
                                                        ..forceMaterials = true,
                                                  'select': true,
                                                  'confirmSelection':
                                                      onMaterialsUsedPicked,
                                                })
                                          },
                                      icon: const Icon(Icons.list))
                                ],
                              ),
                              ...madeFrom
                                  .asMap()
                                  .map(
                                    (index, value) => MapEntry(
                                      index,
                                      SizedBox(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(value.name ??
                                                  "Materiał bez nazwy"),
                                            ),
                                            Flexible(
                                              child: IconButton(
                                                icon: const Icon(Icons
                                                    .remove_circle_outline),
                                                onPressed: () {
                                                  List<Product> madeFromCopy = [
                                                    ...madeFrom
                                                  ];
                                                  madeFromCopy.removeAt(index);
                                                  setState(
                                                    () {
                                                      madeFrom = madeFromCopy;
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .values
                                  .toList()
                            ],
                          ),
                          secondChild: const SizedBox.shrink())
                    ],
                  ),
                  Column(
                    children: [
                      FormField(
                        initialValue: addAsMaterial,
                        validator: switchValidator,
                        builder: (FormFieldState<bool> field) {
                          return SwitchListTile(
                            activeColor: theme.colorScheme.primary,
                            contentPadding: const EdgeInsets.all(0),
                            title: const Text("Dodaj jako materiał"),
                            value: addAsMaterial,
                            onChanged: (val) {
                              setState(() {
                                addAsMaterial = val;
                              });
                            },
                          );
                        },
                      ),
                      AnimatedCrossFade(
                        layoutBuilder: ((
                          topChild,
                          topChildKey,
                          bottomChild,
                          bottomChildKey,
                        ) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: <Widget>[
                              Positioned(
                                  key: bottomChildKey,
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: bottomChild),
                              Positioned(key: topChildKey, child: topChild),
                            ],
                          );
                        }),
                        crossFadeState: addAsMaterial
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 250),
                        firstChild: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: CustomTextField(
                                    label: const Text("Użyte:"),
                                    controller: consumedController,
                                    validator: addAsMaterial
                                        ? numberValidator
                                        : (value) => null,
                                    type: TextInputType.number,
                                  ),
                                ),
                                Flexible(
                                  child: CustomTextField(
                                    label: const Text("Dostępne:"),
                                    controller: availableController,
                                    validator: addAsMaterial
                                        ? numberValidator
                                        : (value) => null,
                                    type: TextInputType.number,
                                  ),
                                ),
                                Flexible(
                                  child: CustomTextField(
                                    label: const Text("Potrzebne"),
                                    controller: neededController,
                                    validator: addAsMaterial
                                        ? numberValidator
                                        : (value) => null,
                                    type: TextInputType.number,
                                  ),
                                )
                              ],
                            ),
                            SharedErrorField(validator: switchValidator),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      "Wykorzystany przy:",
                                      textScaleFactor: 1.1,
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () => {
                                          Navigator.pushNamed(
                                              context, "/products",
                                              arguments: {
                                                'productFilter':
                                                    ProductFilter.projects()
                                                      ..forceProjects = true,
                                                'select': true,
                                                'confirmSelection':
                                                    onProductsMadeWithPicked,
                                              })
                                        },
                                    icon: const Icon(Icons.list))
                              ],
                            ),
                            ...usedIn
                                .asMap()
                                .map(
                                  (index, value) => MapEntry(
                                    index,
                                    SizedBox(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(value.name ??
                                                "Projekt bez nazwy"),
                                          ),
                                          Flexible(
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline),
                                              onPressed: () {
                                                List<Product> usedInCopy = [
                                                  ...usedIn
                                                ];
                                                usedInCopy.removeAt(index);
                                                setState(() {
                                                  usedIn = usedInCopy;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .values
                                .toList()
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                      )
                    ],
                  ),
                  if (!addAsMaterial && !addAsProject)
                    SharedErrorField(validator: switchValidator),
                  ElevatedButton(
                    onPressed: confirmEdit,
                    child: const Text("Zapisz"),
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
