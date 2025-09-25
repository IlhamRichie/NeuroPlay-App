// lib/app/modules/exercise/exercise_view.dart

import 'package:camera/camera.dart';

import '../controllers/exercise_controller.dart';
import '../pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExerciseView extends GetView<ExerciseController> {
  const ExerciseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesi Latihan'),
      ),
      body: Obx(
        () {
          if (controller.isCameraInitialized.value && controller.cameraController != null && controller.cameraController!.value.isInitialized) {
            
            final cameraSize = controller.cameraController!.value.previewSize!;
            // Hitung aspect ratio kamera untuk layout yang benar
            final cameraAspectRatio = cameraSize.height / cameraSize.width;

            return Center(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: size.width,
                  height: size.width * cameraAspectRatio,
                  child: Stack(
                    fit: StackFit.expand, // Pastikan Stack mengisi SizedBox
                    children: [
                      // Layer 1: Preview Kamera
                      CameraPreview(controller.cameraController!),
                      
                      // Layer 2: Overlay AI (PosePainter)
                      Obx(() => CustomPaint(
                            painter: PosePainter(
                              keypoints: controller.output.value,
                              imageSize: cameraSize,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}