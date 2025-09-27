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
        title: const Text('Game: Bantu Burung Terbang!'),
      ),
      body: Obx(
        () {
          if (!controller.isCameraInitialized.value || controller.cameraController == null || !controller.cameraController!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // ===== LAPISAN PALING BAWAH: BACKGROUND LANGIT =====
              Image.asset(
                'assets/sky_background.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // ===== LAPISAN KEDUA: KAMERA & SKELETON (SEDIKIT TRANSPARAN) =====
              Opacity(
                opacity: 0.5,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: size.width,
                      height: size.width * (controller.cameraController!.value.previewSize!.height / controller.cameraController!.value.previewSize!.width),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(controller.cameraController!),
                          Obx(() => CustomPaint(
                                painter: PosePainter(
                                  keypoints: controller.output.value,
                                  imageSize: controller.cameraController!.value.previewSize!,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ===== LAPISAN KETIGA: ELEMEN GAME =====
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Image.asset('assets/nest.png', width: 100),
                ),
              ),

              Obx(() => AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    bottom: 50 + (size.height * 0.6 * controller.birdFlightProgress.value),
                    left: (size.width / 2) - 35,
                    child: Image.asset('assets/bird.png', width: 70),
                  )),
              
              // ===== LAPISAN KEEMPAT: UI & COUNTDOWN =====
              Obx(() => Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 8,
                        color: controller.isCorrectPose.value ? Colors.greenAccent : Colors.transparent,
                      ),
                    ),
                  )),
              
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
                        const Text("KEKUATAN TERBANG", style: TextStyle(color: Colors.white, fontSize: 18)),
                        Obx(() => Text(
                              '${controller.repetitionCount.value} / ${controller.targetRepetitions}',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
              ),

              // ================== GIF INSTRUKSI DITAMBAHKAN KEMBALI DI SINI ==================
              Positioned(
                bottom: 30,
                right: 20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: ClipRRect( // Menggunakan ClipRRect agar GIF mengikuti border radius
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/elbow_elevation.gif', // Pastikan nama file ini benar
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // =============================================================================

              Obx(() {
                if (controller.isReady.value) {
                  return const SizedBox.shrink();
                } else {
                  return Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Text(
                        controller.countdownValue.value.toString(),
                        style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  );
                }
              }),
            ],
          );
        },
      ),
    );
  }
}