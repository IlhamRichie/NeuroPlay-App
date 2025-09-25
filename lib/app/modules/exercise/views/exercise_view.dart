// lib/app/modules/exercise/exercise_view.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/exercise_controller.dart';
import '../pose_painter.dart';

class ExerciseView extends GetView<ExerciseController> {
  const ExerciseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan: Elevasi Siku'),
      ),
      body: Obx(
        () {
          if (controller.isCameraInitialized.value && controller.cameraController != null && controller.cameraController!.value.isInitialized) {
            
            final cameraSize = controller.cameraController!.value.previewSize!;
            final cameraAspectRatio = cameraSize.height / cameraSize.width;

            return Stack(
              children: [
                // Layer 1: Kamera dan Painter (sudah ada)
                Center(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: size.width,
                      height: size.width * cameraAspectRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(controller.cameraController!),
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
                ),

                // ================== LAYER 2: UI FEEDBACK ==================
                // Border feedback
                Obx(() => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 8,
                          color: controller.isCorrectPose.value ? Colors.greenAccent : Colors.transparent,
                        ),
                      ),
                    )),
                
                // Tampilan Repetisi dan Instruksi
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "REPETISI",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Obx(() => Text(
                              controller.repetitionCount.value.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                ),
                // =========================================================
              ],
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