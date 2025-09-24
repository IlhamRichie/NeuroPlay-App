// lib/app/modules/exercise/exercise_view.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/exercise_controller.dart';

class ExerciseView extends GetView<ExerciseController> {
  const ExerciseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesi Latihan'),
      ),
      body:
          // Obx akan otomatis rebuild widget di dalamnya saat
          // nilai isCameraInitialized berubah
          Obx(
        () {
          if (controller.isCameraInitialized.value) {
            // Jika kamera sudah siap, tampilkan preview
            return Stack(
              children: [
                CameraPreview(controller.cameraController),
                // Nanti kita akan tambahkan CustomPainter di sini
                // untuk menggambar overlay AI
              ],
            );
          } else {
            // Jika belum siap, tampilkan loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}