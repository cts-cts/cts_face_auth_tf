import 'package:cts_face_auth_tf/src/controllers/ml_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  final mlController = Get.put(MLController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await mlController.runInference();
        },
        child: Icon(
          Icons.face_4_rounded,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      mlController.pickImage();
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              Obx(
                () => mlController.img.value != null
                    ? Image.memory(mlController.img.value!)
                    : Icon(
                        Icons.person,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
