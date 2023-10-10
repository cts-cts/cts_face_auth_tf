import 'package:cts_face_auth_tf/src/helpers/log.dart';
import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MLController extends GetxController {
  late Interpreter interpreter;
  @override
  void onInit() async {
    await initInterpreter();
    super.onInit();
  }

  Future<void> initInterpreter() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      klog('Interpreter Initialized');
    } catch (e) {
      klog(e);
    }
  }
}
