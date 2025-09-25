// lib/app/modules/exercise/exercise_controller.dart

import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ExerciseController extends GetxController {
  final isCameraInitialized = false.obs;
  var isProcessing = false;
  
  CameraController? cameraController;
  late CameraDescription frontCamera;

  Interpreter? interpreter;
  final RxList<List<double>> output = RxList<List<double>>([]);

  final int inputSize = 192;

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
      interpreter = await Interpreter.fromAsset('assets/movenet_lightning.tflite');
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
      isProcessing = false;
  }
  
  // ================== PERUBAHAN UTAMA DI SINI ==================
  img.Image? preprocessImage(CameraImage cameraImage) {
    // ... (kode konversi YUV ke RGB tetap sama)
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
        
        if (yIndex >= yPlane.length || uvIndex >= uPlane.length || uvIndex >= vPlane.length) continue;
        
        final yValue = yPlane[yIndex];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];

        final r = yValue + 1.13983 * (vValue - 128);
        final g = yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128);
        final b = yValue + 2.03211 * (uValue - 128);
        
        image.setPixelRgb(x, y, r.toInt().clamp(0, 255), g.toInt().clamp(0, 255), b.toInt().clamp(0, 255));
      }
    }
    
    // **TAMBAHAN: LAKUKAN ROTASI GAMBAR DI SINI**
    // Karena kamera depan, kita putar -90 derajat (berlawanan arah jarum jam)
    final rotatedImage = img.copyRotate(image, angle: -90);
    
    // Resize gambar yang SUDAH DIPUTAR
    return img.copyResize(rotatedImage, width: inputSize, height: inputSize);
  }
  // ===============================================================
}