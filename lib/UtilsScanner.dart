import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class UtilsScanner {
  UtilsScanner._();

  static Future<CameraDescription> getCamera(CameraLensDirection cameraLensDirection) async {
    return await availableCameras().then(
          (List<CameraDescription> cameras) => cameras.firstWhere(
            (CameraDescription cameraDescription) => cameraDescription.lensDirection == cameraLensDirection,
      ),
    );
  }

  static Future<Uint8List> concatenatePlanes(List<Plane> planes) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  static InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        throw Exception('Invalid rotation value');
    }
  }

  static Future<InputImage> buildInputImage(CameraImage image, int rotation) async {
    final bytes = await concatenatePlanes(image.planes);
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final imageRotation = rotationIntToImageRotation(rotation);

    final metadata = InputImageMetadata(
      size: size,
      rotation: imageRotation,
      format: InputImageFormat.yuv420,
      bytesPerRow: image.planes.isNotEmpty ? image.planes[0].bytesPerRow : 0,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  static Future<dynamic> detect({
    required CameraImage image,
    required Future<dynamic> Function(InputImage image) detectInImage,
    required int imageRotation,
  }) async {
    final inputImage = await buildInputImage(image, imageRotation);
    return detectInImage(inputImage);
  }
}
