import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_labeling/components/empty_image_state.dart';
import 'package:image_labeling/components/empty_live_state.dart';
import 'package:image_labeling/components/photo_item.dart';
import 'package:image_labeling/components/result_item.dart';
import 'package:image_labeling/utils/constants.dart';

class LivePage extends StatefulWidget {
  final CameraDescription camera;
  const LivePage({Key? key, required this.camera}) : super(key: key);

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  late CameraController controller;
  late CameraImage _image;
  late ImageLabeler labeler;
  bool isBusy = false;
  List<String> result = [];

  @override
  void initState() {
    super.initState();
    labeler = GoogleMlKit.vision.imageLabeler();
    initializeCamera();
  }

  initializeCamera() async {
    controller = CameraController(widget.camera, ResolutionPreset.max);
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) {
        if (!isBusy) {
          isBusy = true;
          _image = image;
          doImageLabeling();
        }
      });
    });
  }

  doImageLabeling() async {
    result.clear();
    InputImage inputImage = getInputImage();
    final List<ImageLabel> labels = await labeler.processImage(inputImage);
    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      result.add("$text - ${confidence.toStringAsFixed(2)}%");
    }
    setState(() {
      isBusy = false;
    });
  }

  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in _image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(_image.width.toDouble(), _image.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(
                widget.camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(_image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = _image.planes.map(
      (var plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    return inputImage;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !controller.value.isInitialized
        ? EmptyLiveState()
        : SafeArea(
            child: Scaffold(
              backgroundColor: Constants.backgroundColor,
              appBar: AppBar(
                title: Text('Live Feed'),
                centerTitle: true,
                backgroundColor: Constants.accentColor,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
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
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Container(
                              height: 200,
                              child: AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: CameraPreview(controller),
                              ),
                            ),
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
