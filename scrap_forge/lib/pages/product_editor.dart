import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/db_entities/product_dto.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';

class ProductEditor extends StatefulWidget {
  Product? edit;

  ProductEditor({super.key, this.edit});

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  IsarService db = IsarService();

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final areaController = TextEditingController();
  bool addAsProject = true;
  ProjectLifeCycle progress = ProjectLifeCycle.inProgress;

  bool addAsMaterial = false;
  final consumedController = TextEditingController();
  final availableController = TextEditingController();
  final neededController = TextEditingController();

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

  List<Uint8List> photos = List.empty();

  Future<Uint8List> fromXFile(XFile file) async {
    return await file.readAsBytes();
  }

  Future<void> pickImagesFromGallery() async {
    List<XFile> images = await ImagePicker().pickMultiImage();
    // final images = await ImagePicker().pickImage(source: ImageSource.gallery);
    List<Uint8List> bytes =
        await Future.wait(images.map((img) => img.readAsBytes()));

    if (bytes.isNotEmpty) {
      // ProductDTO copy = ProductDTO.copy(edited);
      // copy.photos.addAll(bytes);

      setState(() {
        this.photos = List.from([...this.photos, ...bytes]);
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    // final images = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      // ProductDTO copy = ProductDTO.copy(edited);

      // copy.photos.add(bytes);
      setState(() {
        this.photos = List.from([...this.photos, bytes]);
      });
    }
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
        title: Text(widget.edit == null
            ? "Dodaj nowy produkt"
            : "Edytuj \"${widget.edit?.name}\""),
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
                                      onPressed: () {
                                        pickImagesFromGallery();
                                      },
                                      child: Icon(
                                        IconData(0xe057,
                                            fontFamily: 'MaterialIcons'),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        pickImageFromCamera();
                                      },
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: CustomTextField(
                            label: "Długość:",
                            controller: lengthController,
                            validator: numberValidator,
                            type: TextInputType.number,
                          ),
                        ),
                        Flexible(
                          child: CustomTextField(
                            label: "Szerokość:",
                            controller: widthController,
                            validator: numberValidator,
                            type: TextInputType.number,
                          ),
                        ),
                        Flexible(
                          child: CustomTextField(
                            label: "Wysokość:",
                            controller: heightController,
                            validator: numberValidator,
                            type: TextInputType.number,
                          ),
                        )
                      ],
                    ),
                    CustomTextField(
                      label: "Powierzchnia rzutu w cm2:",
                      controller: areaController,
                      validator: numberValidator,
                      type: TextInputType.number,
                    ),
                  ],
                ),
                CustomTextField(
                  label: "Wykonany z:",
                  controller: TextEditingController(),
                  validator: (value) {
                    return null;
                  },
                  type: TextInputType.number,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormField(
                      initialValue: addAsProject,
                      builder: (FormFieldState<bool> field) {
                        return SwitchListTile(
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
                      firstChild: DropdownMenu<ProjectLifeCycle>(
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
                        initialSelection: ProjectLifeCycle.inProgress,
                        onSelected: (value) {
                          if (value != null) {
                            setState(() {
                              progress = value;
                            });
                          }
                        },
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
                      firstChild: Row(
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
                        Product p = ProductDTO(
                          name: nameController.text,
                          description: descriptionController.text,
                          category: categoryController.text,
                          photos: photos,
                          length: lengthController.text,
                          width: widthController.text,
                          height: heightController.text,
                          projectionArea: areaController.text,
                          progress: addAsProject ? progress : null,
                          consumed:
                              addAsMaterial ? consumedController.text : "",
                          available:
                              addAsMaterial ? availableController.text : "",
                          needed: addAsMaterial ? neededController.text : "",
                          madeFromIds: List.empty(),
                          usedInIds: List.empty(),
                          addedTimestamp: DateTime.now().millisecondsSinceEpoch,
                          finishedTimestamp:
                              DateTime.now().millisecondsSinceEpoch,
                        ).toProduct();

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
