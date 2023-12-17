import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cts_face_auth_tf/src/helpers/log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class MLController extends GetxController {
  double threshold = 0.5;

  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
    ),
  );

  final imagePicker = ImagePicker();

  List target1 = [];
  List target2 = [];

  final img1 = Rx<Uint8List?>(null);
  final img2 = Rx<Uint8List?>(null);

  late Interpreter interpreter;
  @override
  void onInit() async {
    await initInterpreter();
    super.onInit();
  }

  Future<void> initInterpreter() async {
    try {
      var interpreterOptions = InterpreterOptions()
        ..addDelegate(
          GpuDelegateV2(
            options: GpuDelegateOptionsV2(),
          ),
        );

      interpreter = await Interpreter.fromAsset(
        'assets/mobilefacenet.tflite',
        options: interpreterOptions,
      );

      klog('Interpreter Initialized');
    } catch (e) {
      klog(e);
    }
  }

  void pickImage(bool first) async {
    try {
      final pickedImage =
          await imagePicker.pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        final imgPath = pickedImage.path;
        final facesList =
            await faceDetector.processImage(InputImage.fromFilePath(imgPath));

        if (facesList.length == 1) {
          final imgBytes = File(imgPath).readAsBytesSync();

          switch (first) {
            case true:
              img1.value = imgBytes;
              target2.clear();
              target2 =
                  setImageForML(imgBytes: imgBytes, face: facesList.first);
            case false:
              img2.value = imgBytes;

              target1.clear();
              target1 =
                  setImageForML(imgBytes: imgBytes, face: facesList.first);
          }
        }
      }
    } catch (e) {
      klog(e);
    }
  }

  void authenticate() {
    double minDist = 999;
    double currDist = 0.0;
    // klog(target1);
    // klog('------');
    // klog(target2);

    currDist = euclideanDistance(target1: target1, target2: target2);

    final x = currDist <= threshold && currDist < minDist;
    Get.defaultDialog(
      content: Column(
        children: [
          Text('$currDist $x'),
        ],
      ),
    );
  }

  List preProcess(Uint8List imgData, Face face) {
    final croppedImage = cropFace(
      imgData: imgData,
      boundingBox: face.boundingBox,
    );

    final img = imglib.copyResizeCropSquare(croppedImage, size: 112);
    final imageAsList = imageToByteListFloat32(img);

    return imageAsList;
  }

  imglib.Image cropFace(
      {required Uint8List imgData, required Rect boundingBox}) {
    final int x = boundingBox.left.toInt() + 100;
    final int y = boundingBox.top.toInt() + 100;
    final int width = boundingBox.width.toInt() + 100;
    final int height = boundingBox.height.toInt() + 100;

    final croped = imglib.copyCrop(
      imglib.decodeImage(imgData)!,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    return croped;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < 112; i++) {
      for (int j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - 128) / 128;
        buffer[pixelIndex++] = (pixel.g - 128) / 128;
        buffer[pixelIndex++] = (pixel.b - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  double euclideanDistance({required List target1, required List target2}) {
    double sum = 0.0;
    for (int i = 0; i < target1.length; i++) {
      sum += pow((target1[i] - target2[i]), 2);
    }
    return sqrt(sum);
  }

  List setImageForML({required Uint8List imgBytes, required Face face}) {
    List input = preProcess(imgBytes, face);

    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    interpreter.run(input, output);

    output = output.reshape([192]);

    return List.from(output);
  }
}
