// lib/app/modules/exercise/exercise_controller.dart

import 'dart:developer';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../routes/app_pages.dart';

// Enum untuk melacak status latihan
enum ExerciseStage { down, up }

class ExerciseController extends GetxController {
  final isCameraInitialized = false.obs;
  var isProcessing = false;
  CameraController? cameraController;
  late CameraDescription frontCamera;
  Interpreter? interpreter;
  final RxList<List<double>> output = RxList<List<double>>([]);
  final int inputSize = 192;

  // Variabel baru untuk game
  final RxInt repetitionCount = 0.obs;
  final Rx<ExerciseStage> stage = ExerciseStage.down.obs;
  final RxBool isCorrectPose = false.obs;

  final int targetRepetitions = 5;

  @override
  void onInit() {
    super.onInit();
    loadModel().then((success) {
      if (success) {
        initializeCamera();
      } else {
        log("GAGAL MEMUAT MODEL: Kamera tidak akan diinisialisasi.");
        Get.snackbar(
          "Initialization Error",
          "Gagal memuat model AI. Pastikan file model ada.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }

  @override
  void onClose() {
    if (cameraController != null && cameraController!.value.isInitialized) {
      cameraController!.stopImageStream();
      cameraController!.dispose();
    }
    interpreter?.close();
    super.onClose();
  }

  Future<bool> loadModel() async {
    try {
      interpreter =
          await Interpreter.fromAsset('assets/movenet_lightning.tflite');
      log('Model loaded successfully');
      return true;
    } catch (e) {
      log('=== ERROR SAAT LOAD MODEL ===');
      log('Error: $e');
      log('=============================');
      return false;
    }
  }

  Future<void> initializeCamera() async {
    if (await Permission.camera.request().isGranted) {
      final cameras = await availableCameras();
      frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

      cameraController!.startImageStream((image) {
        if (!isProcessing) {
          isProcessing = true;
          runModelOnFrame(image);
        }
      });
    } else {
      Get.snackbar("Error", "Izin kamera diperlukan.");
    }
  }

  // Fungsi baru untuk menghitung sudut antara 3 titik
  double calculateAngle(List<double> p1, List<double> p2, List<double> p3) {
    if (p1[0] == -1.0 || p2[0] == -1.0 || p3[0] == -1.0) return 0.0;

    final y1 = p1[0], x1 = p1[1];
    final y2 = p2[0], x2 = p2[1];
    final y3 = p3[0], x3 = p3[1];

    // UBAH DI SINI: gunakan math.atan2 dan math.pi
    double angle =
        (math.atan2(y3 - y2, x3 - x2) - math.atan2(y1 - y2, x1 - x2)) *
            (180 / math.pi);

    if (angle < 0) {
      angle += 360;
    }

    return angle > 180 ? 360 - angle : angle;
  }

  void runModelOnFrame(CameraImage image) {
    if (interpreter == null) return;

    var processedImage = preprocessImage(image);
    if (processedImage == null) {
      isProcessing = false;
      return;
    }

    var imageBytes = processedImage.getBytes(order: img.ChannelOrder.rgb);
    var inputTensor = imageBytes.buffer.asUint8List();
    var reshapedInput = inputTensor.reshape([1, inputSize, inputSize, 3]);

    var outputBuffer = List.filled(1 * 1 * 17 * 3, 0.0).reshape([1, 1, 17, 3]);
    interpreter!.run(reshapedInput, outputBuffer);

    List<List<double>> keypoints = [];
    for (int i = 0; i < 17; i++) {
      double score = outputBuffer[0][0][i][2];
      if (score > 0.3) {
        double y = outputBuffer[0][0][i][0];
        double x = outputBuffer[0][0][i][1];
        keypoints.add([y, x]);
      } else {
        keypoints.add([-1.0, -1.0]);
      }
    }

    output.value = keypoints;

    if (keypoints.length >= 17) {
      final rightShoulder = keypoints[6];
      final rightElbow = keypoints[8];
      final rightWrist = keypoints[10];

      double elbowAngle = calculateAngle(rightShoulder, rightElbow, rightWrist);

      if (elbowAngle > 160) {
        if (stage.value == ExerciseStage.down) {
          repetitionCount.value++;
          stage.value = ExerciseStage.up;

          // ================== LOGIKA NAVIGASI ==================
          // Cek apakah target sudah tercapai
          if (repetitionCount.value >= targetRepetitions) {
            // Hentikan image stream agar tidak memproses di background
            cameraController?.stopImageStream();
            // Pindah ke halaman hasil
            Get.offNamed(Routes.RESULT, arguments: repetitionCount.value);
          }
          // =======================================================
        }
      } else if (elbowAngle < 30) {
        isCorrectPose.value = true;
        stage.value = ExerciseStage.down;
      } else {
        isCorrectPose.value = false;
      }
    }

    isProcessing = false;
  }

  // ================== PERUBAHAN UTAMA DI SINI ==================
  img.Image? preprocessImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final yuv420 = cameraImage.planes;
    if (yuv420.length < 3) return null;

    final yPlane = yuv420[0].bytes;
    final uPlane = yuv420[1].bytes;
    final vPlane = yuv420[2].bytes;
    final yStride = yuv420[0].bytesPerRow;
    final uvStride = yuv420[1].bytesPerRow;
    final uvPixelStride = yuv420[1].bytesPerPixel ?? 1;

    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yStride + x;
        final uvIndex = (y ~/ 2) * uvStride + (x ~/ 2) * uvPixelStride;

        if (yIndex >= yPlane.length ||
            uvIndex >= uPlane.length ||
            uvIndex >= vPlane.length) continue;

        final yValue = yPlane[yIndex];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];

        final r = yValue + 1.13983 * (vValue - 128);
        final g = yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128);
        final b = yValue + 2.03211 * (uValue - 128);

        image.setPixelRgb(x, y, r.toInt().clamp(0, 255),
            g.toInt().clamp(0, 255), b.toInt().clamp(0, 255));
      }
    }

    final rotatedImage = img.copyRotate(image, angle: -90);

    return img.copyResize(rotatedImage, width: inputSize, height: inputSize);
  }
  // ===============================================================
}
