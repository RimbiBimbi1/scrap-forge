import 'dart:typed_data';

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
                  // onSaved: (value) {
                  //   ProductDTO copy = ProductDTO.copy(edited);
                  //   copy.name = value;
                  //   setState(() {
                  //     this.edited = copy;
                  //   });
                  // },
                ),
                CustomTextField(
                  label: "Kategoria:",
                  // initialValue: edited.category,
                  controller: categoryController,
                  // onSaved: (value) {
                  //   ProductDTO copy = ProductDTO.copy(edited);
                  //   copy.category = value;
                  //   setState(() {
                  //     this.edited = copy;
                  //   });
                  // },
                ),
                CustomTextField(
                  label: "Opis:",
                  // initialValue: edited.description,
                  controller: descriptionController,
                  // onSaved: (value) {
                  //   ProductDTO copy = ProductDTO.copy(edited);
                  //   copy.description = value;
                  //   setState(() {
                  //     this.edited = copy;
                  //   });
                  // },
                  type: TextInputType.multiline,
                  maxLines: null,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Zdjęcia:",
                          textScaleFactor: 1.2,
                          style: TextStyle(color: Colors.white),
                        ),
                        Spacer(
                          flex: 15,
                        ),
                        Flexible(
                          flex: 10,
                          child: OutlinedButton(
                            onPressed: () {
                              pickImagesFromGallery();
                            },
                            child: Icon(
                                IconData(0xe057, fontFamily: 'MaterialIcons')),
                          ),
                        ),
                        Flexible(
                          flex: 10,
                          child: OutlinedButton(
                            onPressed: () {
                              pickImageFromCamera();
                            },
                            child: Icon(
                                IconData(0xe048, fontFamily: 'MaterialIcons')),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: (photos.isNotEmpty) ? 200 : 0,
                      child: ListView(
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
                        ],
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
                                IconData(0xe048, fontFamily: 'MaterialIcons')),
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
                            // initialValue: edited.length,
                            controller: lengthController,
                            // onSaved: (value) {
                            //   ProductDTO copy = ProductDTO.copy(edited);
                            //   copy.length = value;
                            //   setState(() {
                            //     this.edited = copy;
                            //   });
                            // },
                            type: TextInputType.number,
                          ),
                        ),
                        Flexible(
                          child: CustomTextField(
                            label: "Szerokość:",
                            // initialValue: edited.width,
                            controller: widthController,
                            // onSaved: (value) {
                            //   ProductDTO copy = ProductDTO.copy(edited);
                            //   copy.width = value;
                            //   setState(() {
                            //     this.edited = copy;
                            //   });
                            // },
                            type: TextInputType.number,
                          ),
                        ),
                        Flexible(
                          child: CustomTextField(
                            label: "Wysokość:",
                            // initialValue: edited.height,
                            controller: heightController,
                            // onSaved: (value) {
                            //   ProductDTO copy = ProductDTO.copy(edited);
                            //   copy.height = value;
                            //   setState(() {
                            //     this.edited = copy;
                            //   });
                            // },
                            type: TextInputType.number,
                          ),
                        )
                      ],
                    ),
                    CustomTextField(
                      label: "Powierzchnia rzutu w cm2:",
                      // initialValue: edited.projectionArea,
                      controller: areaController,
                      // onSaved: (value) {
                      //   ProductDTO copy = ProductDTO.copy(edited);
                      //   copy.projectionArea = value;
                      //   setState(() {
                      //     this.edited = copy;
                      //   });
                      // },
                      type: TextInputType.number,
                    ),
                  ],
                ),
                CustomTextField(
                  label: "Wykonany z:",
                  controller: TextEditingController(),
                  // onSaved: (value) {},
                  // // onSaved: (value) {
                  // //   setState(() {
                  // //     madeFrom = value;
                  // //   });
                  // // },
                  type: TextInputType.number,
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
                          madeFromIds: List.empty(),
                          usedInIds: List.empty(),
                        ).toProduct();

                        db.saveProduct(p);
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
