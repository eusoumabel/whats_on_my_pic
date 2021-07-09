import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_labeling/components/empty_image_state.dart';
import 'package:image_labeling/components/photo_item.dart';
import 'package:image_labeling/components/result_item.dart';
import 'package:image_labeling/utils/constants.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  late ImagePicker imagePicker;
  File? _image;
  late ImageLabeler imageLabeler;
  List<String> result = [];

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    imageLabeler = GoogleMlKit.vision.imageLabeler();
  }

  @override
  void dispose() {
    super.dispose();
    imageLabeler.close();
  }

  _captureImageFromCamera() async {
    PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);

    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : _image;
    });
    doImageLabeling();
  }

  _chooseImageFromGallery() async {
    PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : _image;
    });
    doImageLabeling();
  }

  doImageLabeling() async {
    final inputImage = InputImage.fromFile(_image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    result.clear();
    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence * 100;

      setState(() {
        result.add("$text - ${confidence.toStringAsFixed(2)}%");
      });
    }
  }

  showCameraOptionsDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Galeria or Câmera?",
          style: TextStyle(color: Constants.textColor),
        ),
        backgroundColor: Constants.dialogColor,
        content: Text(
          "Você quer escolher uma imagem da sua galeria ou tirar uma foto?",
          style: TextStyle(color: Constants.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Fechar",
              style: TextStyle(color: Colors.red[300]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _captureImageFromCamera();
            },
            child: Text(
              "Câmera",
              style: TextStyle(color: Colors.blue[300]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _chooseImageFromGallery();
            },
            child: Text(
              "Galeria",
              style: TextStyle(color: Colors.blue[300]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Constants.backgroundColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showCameraOptionsDialog();
          },
          child: Icon(Icons.camera_alt),
          backgroundColor: Constants.accentColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What's on my pic?",
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Constants.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  child: Center(
                    child: _image != null
                        ? GestureDetector(
                            onTap: showCameraOptionsDialog,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: PhotoItem(image: _image),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: EmptyImageState(),
                          ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: ResultItem(
                          index: index,
                          text: result[index],
                        ),
                      );
                    },
                    itemCount: result.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
