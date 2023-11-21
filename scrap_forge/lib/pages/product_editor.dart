import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/db_entities/product_dto.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';

class ProductEditor extends StatefulWidget {
  Product? edit;

  ProductEditor({super.key, this.edit});

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  final _formKey = GlobalKey<FormState>();

  ProductDTO edited = ProductDTO(
    photos: List.empty(growable: true),
    madeFromIds: List.empty(growable: true),
    usedInIds: List.empty(growable: true),
  );

  Future<Uint8List> fromXFile(XFile file) async {
    return await file.readAsBytes();
  }

  Future<void> pickImagesFromGallery() async {
    List<XFile> images = await ImagePicker().pickMultiImage();
    // final images = await ImagePicker().pickImage(source: ImageSource.gallery);
    List<Uint8List> bytes =
        await Future.wait(images.map((img) => img.readAsBytes()));

    if (images.isNotEmpty) {
      ProductDTO copy = ProductDTO.copy(edited);
      copy.photos.addAll(bytes);
      setState(() {
        this.edited = copy;
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    // final images = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      ProductDTO copy = ProductDTO.copy(edited);

      copy.photos.add(bytes);
      setState(() {
        this.edited = copy;
      });
    }
  }

  @override
  void initState() {
    if (widget.edit != null) {
      Product p = widget.edit!;
      setState(() async {
        this.edited = await ProductDTO.fromProduct(p);
      });
    }
    super.initState();
  }

  Text label(String text) => Text(
        text,
        style: TextStyle(color: Colors.white),
        textScaleFactor: 1.2,
      );

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
              // shrinkWrap: true,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: "Nazwa:",
                  initialValue: edited.name,
                  onSaved: (value) {
                    ProductDTO copy = ProductDTO.copy(edited);
                    copy.name = value;
                    setState(() {
                      this.edited = copy;
                    });
                  },
                ),
                CustomTextField(
                  label: "Kategoria:",
                  initialValue: edited.category,
                  onSaved: (value) {
                    ProductDTO copy = ProductDTO.copy(edited);
                    copy.category = value;
                    setState(() {
                      this.edited = copy;
                    });
                  },
                ),
                CustomTextField(
                  label: "Opis:",
                  initialValue: edited.description,
                  onSaved: (value) {
                    ProductDTO copy = ProductDTO.copy(edited);
                    copy.description = value;
                    setState(() {
                      this.edited = copy;
                    });
                  },
                  type: TextInputType.multiline,
                  maxLines: null,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Zdjęcia:",
                      textScaleFactor: 1.2,
                      style: TextStyle(color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                        Spacer(
                          flex: 1,
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
                      height: (edited.photos.isNotEmpty) ? 200 : 0,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...edited.photos.map(
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

                          // child: Image(image: MemoryImage(bytes))))
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Wymiary (w mm):",
                      textScaleFactor: 1.2,
                      style: TextStyle(color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: CustomTextField(
                            label: "Długość:",
                            initialValue: edited.length,
                            onSaved: (value) {
                              ProductDTO copy = ProductDTO.copy(edited);
                              copy.length = value;
                              setState(() {
                                this.edited = copy;
                              });
                            },
                            type: TextInputType.number,
                          ),
                        ),
                        Flexible(
                          child: CustomTextField(
                            label: "Szerokość:",
                            initialValue: edited.width,
                            onSaved: (value) {
                              ProductDTO copy = ProductDTO.copy(edited);
                              copy.width = value;
                              setState(() {
                                this.edited = copy;
                              });
                            },
                            type: TextInputType.number,
                          ),
                        ),
                        Flexible(
                          child: CustomTextField(
                            label: "Wysokość:",
                            initialValue: edited.height,
                            onSaved: (value) {
                              ProductDTO copy = ProductDTO.copy(edited);
                              copy.height = value;
                              setState(() {
                                this.edited = copy;
                              });
                            },
                            type: TextInputType.number,
                          ),
                        )
                      ],
                    ),
                    CustomTextField(
                      label: "Powierzchnia rzutu:",
                      initialValue: edited.projectionArea,
                      onSaved: (value) {
                        ProductDTO copy = ProductDTO.copy(edited);
                        copy.projectionArea = value;
                        setState(() {
                          this.edited = copy;
                        });
                      },
                      type: TextInputType.number,
                    ),
                  ],
                ),
                CustomTextField(
                  label: "Wykonany z:",
                  onSaved: (value) {},
                  // onSaved: (value) {
                  //   setState(() {
                  //     madeFrom = value;
                  //   });
                  // },
                  type: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState != null) {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
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
