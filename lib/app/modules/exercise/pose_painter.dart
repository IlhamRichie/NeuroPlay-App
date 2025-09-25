// lib/app/modules/exercise/pose_painter.dart

import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<List<double>> keypoints;
  final Size imageSize;

  PosePainter({required this.keypoints, required this.imageSize});

  @override
  @override
  void paint(Canvas canvas, Size size) {
    // ================== TAMBAHKAN PENJAGA DI SINI ==================
    if (keypoints.isEmpty || keypoints.length < 17) {
      return; // Jangan lakukan apa-apa jika data keypoints belum lengkap
    }
    // ===============================================================

    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Daftar koneksi antar titik untuk membentuk skeleton
    final connections = [
      // Torso
      [5, 6], [5, 11], [6, 12], [11, 12],
      // Lengan
      [5, 7], [7, 9], [6, 8], [8, 10],
      // Kaki
      [11, 13], [13, 15], [12, 14], [14, 16],
    ];

    // Gambar semua titik keypoints
    for (var point in keypoints) {
      if (point[0] != -1.0) {
        // Balik koordinat X untuk efek cermin
        final double x = (1.0 - point[1]) * size.width; 
        final double y = point[0] * size.height;
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }

    // Gambar garis koneksi (skeleton)
    final linePaint = Paint()
      ..color = Colors.lightBlueAccent // Warna garis
      ..strokeWidth = 2;

    for (var connection in connections) {
      final startPoint = keypoints[connection[0]];
      final endPoint = keypoints[connection[1]];

      if (startPoint[0] != -1.0 && endPoint[0] != -1.0) {
        // Balik juga koordinat X di sini
        final double startX = (1.0 - startPoint[1]) * size.width;
        final double startY = startPoint[0] * size.height;
        final double endX = (1.0 - endPoint[1]) * size.width;
        final double endY = endPoint[0] * size.height;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Selalu repaint agar animasi mulus
  }
}