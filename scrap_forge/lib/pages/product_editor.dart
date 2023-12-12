import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/utils/string_multiliner.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';

import '../db_entities/photo.dart';

class ProductEditor extends StatefulWidget {
  BuildContext context;
  ProductEditor({super.key, required this.context});

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  IsarService db = IsarService();

  Product? edit;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
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
  SizeUnit areaUnit = SizeUnit.millimeter;

  bool addAsProject = true;
  final progressController = TextEditingController();
  ProjectLifeCycle? progress = ProjectLifeCycle.inProgress;

  bool addAsMaterial = false;
  final consumedController = TextEditingController();
  final availableController = TextEditingController();
  final neededController = TextEditingController();

  List<Uint8List> photos = List.empty();
  List<Product> madeFrom = List.empty();
  List<TextEditingController> madeFromCounts = List.empty();
  List<Product> usedIn = List.empty();
  List<TextEditingController> usedInCounts = List.empty();

  @override
  void initState() {
    super.initState();
    final arguments = (ModalRoute.of(widget.context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (arguments.isNotEmpty) {
      Product? product = arguments['productData'];
      if (product != null) {
        nameController.text = product.name ??= "";
        descriptionController.text =
            StringMultiliner.multiline(product.description ??= "")
                .toString()
                .trimLeft()
                .trimRight();
        categoryController.text = product.category ??= "";
        lengthController.text =
            (product.length != null) ? product.length.toString() : "";
        lengthUnitController.text = "${product.lengthDisplayUnit?.abbr}";
        widthController.text =
            (product.width != null) ? product.width.toString() : "";
        widthUnitController.text = "${product.widthDisplayUnit?.abbr}";
        heightController.text =
            (product.height != null) ? product.height.toString() : "";
        heightUnitController.text = "${product.heightDisplayUnit?.abbr}";
        areaController.text = (product.projectionArea != null)
            ? product.projectionArea.toString()
            : "";
        progress = product.progress;
        areaUnitController.text = "${product.areaDisplayUnit?.abbr}";
        consumedController.text =
            (product.consumed != null) ? product.consumed.toString() : "";
        availableController.text =
            (product.available != null) ? product.available.toString() : "";
        neededController.text =
            (product.needed != null) ? product.needed.toString() : "";

        setState(() {
          addAsProject = product.progress != null;
          addAsMaterial = (product.consumed != null ||
              product.available != null ||
              product.needed != null);

          photos = product.photos
              .map((photo) => base64Decode(photo.imgData ??= ""))
              .toList();

          madeFrom = product.madeFrom.toList();
          madeFromCounts = List.generate(
              product.madeFrom.length, (index) => TextEditingController());
          usedIn = product.usedIn.toList();
          usedInCounts = List.generate(
              product.usedIn.length, (index) => TextEditingController());

          lengthUnit = product.lengthDisplayUnit ?? SizeUnit.millimeter;
          widthUnit = product.widthDisplayUnit ?? SizeUnit.millimeter;
          heightUnit = product.heightDisplayUnit ?? SizeUnit.millimeter;
          areaUnit = product.areaDisplayUnit ?? SizeUnit.millimeter;

          edit = product;
        });
      }
    }
  }

  String? numberValidator(String? value) {
    if (value == null || value == "") {
      return null;
    }
    RegExp digits = RegExp("^[0123456789]*[,.]?[0123456789]*");
    Match? match = digits.matchAsPrefix(value);
    if (match != null && match.group(0)!.length == value.length) {
      return null;
    }

    return "To pole powinno zawierać liczbę, lub pozostać puste.";
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
    List<XFile> images = await ImagePicker().pickMultiImage();
    List<Uint8List> bytes =
        await Future.wait(images.map((img) => img.readAsBytes()));

    if (bytes.isNotEmpty) {
      setState(() {
        this.photos = List.from([...this.photos, ...bytes]);
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        this.photos = List.from([...this.photos, bytes]);
      });
    }
  }

  void onMaterialsUsedPicked(materials) {
    setState(() {
      madeFrom = materials;
      madeFromCounts =
          List.generate(madeFrom.length, (index) => TextEditingController());
    });
    Navigator.pop(context);
  }

  void onProductsmadeFromPicked(products) {
    setState(() {
      usedIn = products;
      usedInCounts =
          List.generate(usedIn.length, (index) => TextEditingController());
    });
    Navigator.pop(context);
  }

  Text label(String text) => Text(
        text,
        style: TextStyle(color: Colors.white),
        textScaleFactor: 1.2,
      );

  void updateDimensions(List<double> received) {
    lengthController.text = received[0].round().toString();
    widthController.text = received[1].round().toString();
    areaController.text = received[2].round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
            edit == null ? "Dodaj nowy produkt" : "Edytuj \"${edit?.name}\""),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  label: "Nazwa:",
                  controller: nameController,
                  validator: (value) {
                    if (value == "") {
                      return "To pole jest wymagane";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  label: "Kategoria:",
                  controller: categoryController,
                  validator: (value) {
                    return null;
                  },
                ),
                CustomTextField(
                  label: "Opis:",
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
                    Text(
                      "Zdjęcia:",
                      textScaleFactor: 1.2,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: ListView(
                          primary: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...photos.map(
                              (bytes) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: 200,
                                  width: 135,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    image: DecorationImage(
                                        image: MemoryImage(bytes),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              width: 135,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: OutlinedButton(
                                      onPressed: pickImagesFromGallery,
                                      child: Icon(
                                        IconData(0xe057,
                                            fontFamily: 'MaterialIcons'),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: OutlinedButton(
                                      onPressed: pickImageFromCamera,
                                      child: Icon(
                                        IconData(0xe048,
                                            fontFamily: 'MaterialIcons'),
                                      ),
                                    ),
                                  ),
                                ],
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
                          "Wymiary (w mm):",
                          textScaleFactor: 1.2,
                          style: TextStyle(color: Colors.white),
                        ),
                        Flexible(
                          flex: 10,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/measure",
                                  arguments: {
                                    'onExit': updateDimensions,
                                  });
                            },
                            child: Icon(
                              IconData(0xe048, fontFamily: 'MaterialIcons'),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: CustomTextField(
                                    label: dimension['label'] as String,
                                    controller: dimension['controller']
                                        as TextEditingController,
                                    validator: numberValidator,
                                    type: TextInputType.number,
                                  ),
                                ),
                                DropdownMenu<SizeUnit>(
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
                                )
                              ],
                            ))
                        .toList(),
                    Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            label: "Powierzchnia rzutu:",
                            controller: areaController,
                            validator: numberValidator,
                            type: TextInputType.number,
                          ),
                        ),
                        DropdownMenu<SizeUnit>(
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(
                                value: SizeUnit.millimeter, label: "mm2"),
                            DropdownMenuEntry(
                                value: SizeUnit.centimeter, label: "cm2"),
                            DropdownMenuEntry(
                                value: SizeUnit.meter, label: "m2"),
                          ],
                          initialSelection: areaUnit,
                          controller: areaUnitController,
                          onSelected: (value) => setState(() {
                            areaUnit = value ?? SizeUnit.millimeter;
                          }),
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
                          contentPadding: EdgeInsets.all(0),
                          title: Text("Dodaj jako projekt"),
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
                      firstChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownMenu<ProjectLifeCycle>(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
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
                                                  ProductFilter.materials(),
                                              'select': true,
                                              'confirmSelection':
                                                  onMaterialsUsedPicked,
                                            })
                                      },
                                  icon: Icon(Icons.list))
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
                                          child: CustomTextField(
                                            label: "Ilość:",
                                            controller: madeFromCounts[index],
                                            validator: addAsProject
                                                ? numberValidator
                                                : (value) => null,
                                            type: TextInputType.number,
                                          ),
                                        ),
                                        Flexible(
                                          child: IconButton(
                                            icon: Icon(
                                                Icons.remove_circle_outline),
                                            onPressed: () {
                                              List<Product> madeFromCopy =
                                                  List.of(madeFrom);
                                              List<TextEditingController>
                                                  madeFromCountsCopy =
                                                  List.of(madeFromCounts);
                                              madeFromCopy.removeAt(index);
                                              madeFromCountsCopy
                                                  .removeAt(index);
                                              setState(() {
                                                madeFrom = madeFromCopy;
                                                madeFromCounts =
                                                    madeFromCountsCopy;
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
                      secondChild: SizedBox.shrink(),
                      crossFadeState: addAsProject
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 200),
                    )
                  ],
                ),
                Column(
                  children: [
                    FormField(
                      initialValue: addAsMaterial,
                      validator: switchValidator,
                      builder: (FormFieldState<bool> field) {
                        return SwitchListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text("Dodaj jako materiał"),
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
                      firstChild: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: CustomTextField(
                                  label: "Użyte:",
                                  controller: consumedController,
                                  validator: addAsMaterial
                                      ? numberValidator
                                      : (value) => null,
                                  type: TextInputType.number,
                                ),
                              ),
                              Flexible(
                                child: CustomTextField(
                                  label: "Dostępne:",
                                  controller: availableController,
                                  validator: addAsMaterial
                                      ? numberValidator
                                      : (value) => null,
                                  type: TextInputType.number,
                                ),
                              ),
                              Flexible(
                                child: CustomTextField(
                                  label: "Potrzebne",
                                  controller: neededController,
                                  validator: addAsMaterial
                                      ? numberValidator
                                      : (value) => null,
                                  type: TextInputType.number,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      secondChild: SizedBox.shrink(),
                      crossFadeState: addAsMaterial
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 200),
                    )
                  ],
                ),
                SizedBox(
                  height: 25,
                  child: TextFormField(
                    maxLines: 1,
                    validator: switchValidator,
                    readOnly: true,

                    // enabled: false,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState != null) {
                      if (_formKey.currentState!.validate()) {
                        // if (edit != null) {
                        //   db.clearProductLinked(edit!);
                        // }
                        Product p = Product()
                          ..name = nameController.text
                          ..description = descriptionController.text
                          ..photos.addAll(photos.map((bytes) =>
                              Photo()..imgData = base64Encode(bytes)))
                          ..category = categoryController.text
                          ..progress = addAsProject ? progress : null
                          ..addedTimestamp =
                              DateTime.now().millisecondsSinceEpoch
                          ..length = (lengthController.text != "")
                              ? double.parse(
                                  lengthController.text.replaceAll(',', '.'))
                              : null
                          ..lengthDisplayUnit =
                              SizeUnit.fromString(lengthUnitController.text)
                          ..width = (widthController.text != "")
                              ? double.parse(widthController.text)
                              : null
                          ..widthDisplayUnit =
                              SizeUnit.fromString(widthUnitController.text)
                          ..height = (heightController.text != "")
                              ? double.parse(heightController.text)
                              : null
                          ..heightDisplayUnit =
                              SizeUnit.fromString(heightUnitController.text)
                          ..projectionArea = (areaController.text != "")
                              ? double.parse(areaController.text)
                              : null
                          ..areaDisplayUnit =
                              SizeUnit.fromString(areaUnitController.text)
                          ..consumed =
                              (addAsMaterial && consumedController.text != "")
                                  ? int.parse(consumedController.text)
                                  : null
                          ..available =
                              (addAsMaterial && availableController.text != "")
                                  ? int.parse(availableController.text)
                                  : null
                          //TO DO
                          // ..finishedTimestamp = 1
                          ..madeFrom.addAll(madeFrom)
                          ..usedIn.addAll(usedIn)
                          ..needed =
                              (addAsMaterial && neededController.text != "")
                                  ? int.parse(neededController.text)
                                  : null;
                        db.saveProduct(p);
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text("Zapisz"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
