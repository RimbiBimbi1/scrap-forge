import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/utils/string_multiliner.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';

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
  // List<TextEditingController> madeFromCounts = List.empty();
  List<Product> usedIn = List.empty();
  // List<TextEditingController> usedInCounts = List.empty();

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
        countController.text =
            (product.count != null) ? product.count.toString() : "";
        categoryController.text = product.category ??= "";
        if (product.dimensions != null) {
          lengthController.text = (product.dimensions!.length != null)
              ? product.dimensions!.length.toString()
              : "";
          lengthUnitController.text =
              "${product.dimensions!.lengthDisplayUnit?.abbr}";
          widthController.text = (product.dimensions!.width != null)
              ? product.dimensions!.width.toString()
              : "";
          widthUnitController.text =
              "${product.dimensions!.widthDisplayUnit?.abbr}";
          heightController.text = (product.dimensions!.height != null)
              ? product.dimensions!.height.toString()
              : "";
          heightUnitController.text =
              "${product.dimensions!.heightDisplayUnit?.abbr}";
          areaController.text = (product.dimensions!.projectionArea != null)
              ? product.dimensions!.projectionArea.toString()
              : "";
          areaUnitController.text =
              "${product.dimensions!.areaDisplayUnit?.abbr}";
        }
        progress = product.progress;
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

          photos = product.photos.map((photo) => base64Decode(photo)).toList();

          madeFrom = product.madeFrom.toList();
          // madeFromCounts = List.generate(
          //     product.madeFrom.length, (index) => TextEditingController());
          usedIn = product.usedIn.toList();
          // usedInCounts = List.generate(
          //     product.usedIn.length, (index) => TextEditingController());

          if (product.dimensions != null) {
            lengthUnit =
                product.dimensions!.lengthDisplayUnit ?? SizeUnit.millimeter;
            widthUnit =
                product.dimensions!.widthDisplayUnit ?? SizeUnit.millimeter;
            heightUnit =
                product.dimensions!.heightDisplayUnit ?? SizeUnit.millimeter;
            areaUnit =
                product.dimensions!.areaDisplayUnit ?? SizeUnit.millimeter;
          }
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
      // madeFromCounts =
      //     List.generate(materials.length, (index) => TextEditingController());
    });
    Navigator.pop(context);
  }

  void onProductsMadeWithPicked(products) {
    setState(() {
      usedIn = products;
      // usedInCounts =
      //     List.generate(usedIn.length, (index) => TextEditingController());
    });
    Navigator.pop(context);
  }

  Text label(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white),
        textScaleFactor: 1.2,
      );

  void updateDimensions(List<double> received) {
    List<TextEditingController> dimCtrls =
        List.from([lengthController, widthController, heightController]);
    List<SizeUnit> dimUnits = List.from([lengthUnit, widthUnit, heightUnit]);

    int empty_count = List.from(dimCtrls.map((e) => e.text.isEmpty ? 1 : 0))
        .reduce((value, element) => value + element);

    switch (empty_count) {
      case 3:
        lengthController.text =
            (received[0] / lengthUnit.multiplier).round().toString();
        widthController.text =
            (received[1] / widthUnit.multiplier).round().toString();
        break;
      case 2:
        int updatedCount = 0;
        for (final (index, ctrl) in dimCtrls.indexed) {
          if (ctrl.text.isEmpty) {
            ctrl.text = (received[updatedCount] / dimUnits[index].multiplier)
                .round()
                .toString();
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
                .round()
                .toString();
        break;
      default:
        break;
    }

    if (areaController.text.isEmpty) {
      areaController.text = received[2].round().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
                            ...photos
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8)),
                                          image: DecorationImage(
                                              image: MemoryImage(bytes),
                                              fit: BoxFit.cover),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            List<Uint8List> temp =
                                                List.from(photos);
                                            temp.removeAt(index);
                                            setState(() {
                                              photos = temp;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.close_outlined,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black,
                                                blurRadius: 5,
                                                offset: Offset(1, 2),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .values,
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
                                      child:
                                          const Icon(Icons.add_photo_alternate),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: OutlinedButton(
                                      onPressed: pickImageFromCamera,
                                      child: const Icon(Icons.add_a_photo),
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
                              label: "Ilość:",
                              controller: countController,
                              validator: numberValidator,
                            ),
                            DropdownMenu<ProjectLifeCycle>(
                              width: MediaQuery.of(context).size.width - 20,
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
                                          // Flexible(
                                          //   child: CustomTextField(
                                          //     label: "Ilość:",
                                          //     controller: madeFromCounts[index],
                                          //     validator: addAsProject
                                          //         ? numberValidator
                                          //         : (value) => null,
                                          //     type: TextInputType.number,
                                          //   ),
                                          // ),
                                          Flexible(
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline),
                                              onPressed: () {
                                                List<Product> madeFromCopy =
                                                    List.of(madeFrom);
                                                // List<TextEditingController>
                                                //     madeFromCountsCopy =
                                                //     List.of(madeFromCounts);
                                                madeFromCopy.removeAt(index);
                                                // madeFromCountsCopy
                                                // .removeAt(index);
                                                setState(
                                                  () {
                                                    madeFrom = madeFromCopy;
                                                    // madeFromCounts =
                                                    //     madeFromCountsCopy;
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
                          SizedBox(
                            height: 25,
                            child: TextFormField(
                              maxLines: 1,
                              validator: switchValidator,
                              readOnly: true,

                              // enabled: false,
                            ),
                          ),
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
                                                  ProductFilter.projects(),
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
                                        // Flexible(
                                        //   child: CustomTextField(
                                        //     label: "Ilość:",
                                        //     controller: usedInCounts[index],
                                        //     validator: addAsProject
                                        //         ? numberValidator
                                        //         : (value) => null,
                                        //     type: TextInputType.number,
                                        //   ),
                                        // ),
                                        Flexible(
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            onPressed: () {
                                              List<Product> usedInCopy =
                                                  List.of(usedIn);
                                              // List<TextEditingController>
                                              //     usedInCountsCopy =
                                              //     List.of(usedInCounts);
                                              usedInCopy.removeAt(index);
                                              // usedInCountsCopy.removeAt(index);
                                              setState(() {
                                                usedIn = usedInCopy;
                                                // usedInCounts = usedInCountsCopy;
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
                          ..count = countController.text.isNotEmpty
                              ? int.parse(countController.text)
                              : null
                          ..photos = photos
                              .map((bytes) => base64Encode(bytes))
                              .toList()
                          ..category = categoryController.text
                          ..progress = addAsProject ? progress : null
                          ..addedTimestamp =
                              DateTime.now().millisecondsSinceEpoch
                          ..lastModifiedTimestamp =
                              DateTime.now().millisecondsSinceEpoch
                          //TO DO
                          // ..finishedTimestamp = 1
                          ..dimensions = Dimensions(
                            length: (lengthController.text != "")
                                ? double.parse(
                                    lengthController.text.replaceAll(',', '.'))
                                : null,
                            lengthDisplayUnit:
                                SizeUnit.fromString(lengthUnitController.text),
                            width: (widthController.text != "")
                                ? double.parse(widthController.text)
                                : null,
                            widthDisplayUnit:
                                SizeUnit.fromString(widthUnitController.text),
                            height: (heightController.text != "")
                                ? double.parse(heightController.text)
                                : null,
                            heightDisplayUnit:
                                SizeUnit.fromString(heightUnitController.text),
                            projectionArea: (areaController.text != "")
                                ? double.parse(areaController.text)
                                : null,
                            areaDisplayUnit: SizeUnit.fromString(
                                areaUnitController.text.substring(
                                    0, areaUnitController.text.length - 1)),
                          )
                          ..consumed =
                              (addAsMaterial && consumedController.text != "")
                                  ? int.parse(consumedController.text)
                                  : null
                          ..available =
                              (addAsMaterial && availableController.text != "")
                                  ? int.parse(availableController.text)
                                  : null
                          ..madeFrom.addAll(madeFrom)
                          ..usedIn.addAll(usedIn)
                          ..needed =
                              (addAsMaterial && neededController.text != "")
                                  ? int.parse(neededController.text)
                                  : null;
                        if (edit != null) {
                          p.id = edit!.id;
                          p.addedTimestamp = edit!.addedTimestamp;
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
                  },
                  child: const Text("Zapisz"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
