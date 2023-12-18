import 'dart:typed_data';
import 'package:image/image.dart' as imglib;

import 'package:cts_face_auth_tf/src/helpers/log.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_v2/tflite_v2.dart';

class MLController extends GetxController {
  // double threshold = 0.5;

  // final faceDetector = FaceDetector(
  //   options: FaceDetectorOptions(
  //     enableLandmarks: true,
  //   ),
  // );

  final imagePicker = ImagePicker();

  // List target1 = [];
  // List target2 = [];

  final img = Rx<Uint8List?>(null);
  final imgPath = RxString('');
  // final img2 = Rx<Uint8List?>(null);

  late Interpreter interpreter;
  @override
  void onInit() async {
    await initInterpreter();
    super.onInit();
  }

  Future<void> initInterpreter() async {
    try {
      final res = await Tflite.loadModel(
          model: "assets/model_unquant.tflite",
          labels: "assets/labels.txt",
          numThreads: 1, // defaults to 1
          isAsset:
              true, // defaults to true, set to false to load resources outside assets
          useGpuDelegate:
              false // defaults to false, set to true to use GPU delegate
          );

      klog(res);

      // var interpreterOptions = InterpreterOptions()
      //   ..addDelegate(
      //     GpuDelegateV2(
      //       options: GpuDelegateOptionsV2(),
      //     ),
      //   );

      // interpreter = await Interpreter.fromAsset(
      //   'assets/fire_model.tflite',
      //   options: interpreterOptions,
      // );

      klog('Interpreter Initialized');
    } catch (e) {
      klog(e);
    }
  }

  void pickImage() async {
    final pickedImg = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImg != null) {
      img.value = await pickedImg.readAsBytes();
      imgPath.value = await pickedImg.path;
    }
  }

  Future<void> runInference() async {
    try {
      var recognitions = await Tflite.runModelOnImage(
          path: imgPath.value, // required
          imageMean: 0.0, // defaults to 117.0
          imageStd: 255.0, // defaults to 1.0
          numResults: 2, // defaults to 5
          threshold: 0.2, // defaults to 0.1
          asynch: true // defaults to true
          );

      klog(recognitions);
      // final Float32List processedImg = preProcess(img.value!);
      // final Float32List output = Float32List(1);

      // interpreter.run(processedImg, output);

      // klog(output);

      // // Process the output to determine if fire is detected
      // // final isFireDetected = output[0] > 0.5;
    } catch (e) {
      klog('Error in runInference: $e');
    }
  }

  Float32List preProcess(Uint8List imgData) {
    final img = imglib.decodeJpg(imgData);
    final imageAsList = imageToByteListFloat32(img!);

    return imageAsList;
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

  // Float32List imageToByteListFloat32(imglib.Image image) {
  //   var convertedBytes = Float32List(1 * 112 * 112 * 3);
  //   var buffer = Float32List.view(convertedBytes.buffer);
  //   int pixelIndex = 0;

  //   for (int i = 0; i < 112; i++) {
  //     for (int j = 0; j < 112; j++) {
  //       var pixel = image.getPixel(j, i);
  //       buffer[pixelIndex++] = (pixel.r - 128) / 128;
  //       buffer[pixelIndex++] = (pixel.g - 128) / 128;
  //       buffer[pixelIndex++] = (pixel.b - 128) / 128;
  //     }
  //   }
  //   return convertedBytes.buffer.asFloat32List();
  // }
}
