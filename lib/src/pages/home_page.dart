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
        onPressed: () {
          mlController.authenticate();
        },
        child: Icon(
          Icons.face_4_rounded,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Obx(
            () => Column(
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
                        mlController.pickImage(true);
                      },
                      icon: Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () {
                        mlController.pickImage(false);
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
                if (mlController.img1.value != null)
                  Container(
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        22,
                      ),
                      child: Image.memory(mlController.img1.value!),
                    ),
                  ),
                SizedBox(
                  height: 12,
                ),
                if (mlController.img2.value != null)
                  Container(
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        22,
                      ),
                      child: Image.memory(mlController.img2.value!),
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
