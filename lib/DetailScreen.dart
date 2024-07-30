import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'TakePictureScreen.dart';

class Detailscreen extends StatefulWidget {
  @override
  State<Detailscreen> createState() => _DetailscreenState();
}

class _DetailscreenState extends State<Detailscreen> {
  String selectedItem = '';
  File? pickImage;
  String result = '';
  bool isImageLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedItem = ModalRoute.of(context)!.settings.arguments.toString();
  }

  Future<void> getImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? temStore = await _picker.pickImage(source: ImageSource.gallery);

    if (temStore != null) {
      setState(() {
        pickImage = File(temStore.path);
        isImageLoaded = true;
      });
    }
  }

  Future<void> getImageFromCamera() async {
    final cameras = await availableCameras();
    final CameraDescription camera = cameras.first;
    final imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: camera),
      ),
    );

    if (imagePath != null) {
      setState(() {
        pickImage = File(imagePath);
        isImageLoaded = true;
      });
    }
  }

  Future<void> readTextFromAnImage() async {
    if (pickImage == null) return;
    setState(() {
      result = 'Đang xử lý...';
    });

    try {
      final inputImage = InputImage.fromFilePath(pickImage!.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      setState(() {
        result = '';
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            result += line.text + '\n';
          }
        }
      });
    } catch (e) {
      setState(() {
        result = 'Lỗi khi nhận diện văn bản: $e';
      });
    }
  }

  Future<void> readBarcodeFromAnImage() async {
    if (pickImage == null) return;
    setState(() {
      result = 'Đang xử lý...';
    });

    try {
      final inputImage = InputImage.fromFilePath(pickImage!.path);
      final barcodeScanner = BarcodeScanner();
      final barcodes = await barcodeScanner.processImage(inputImage);
      barcodeScanner.close();

      setState(() {
        result = '';
        for (Barcode barcode in barcodes) {
          result += '${barcode.displayValue}\n';
        }
      });
    } catch (e) {
      setState(() {
        result = 'Lỗi khi nhận diện barcode: $e';
      });
    }
  }

  Future<void> readLabelFromAnImage() async {
    if (pickImage == null) return;
    setState(() {
      result = 'Đang xử lý...';
    });

    try {
      final inputImage = InputImage.fromFilePath(pickImage!.path);
      final imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));
      final labels = await imageLabeler.processImage(inputImage);
      imageLabeler.close();

      setState(() {
        result = '';
        for (ImageLabel label in labels) {
          result += '${label.label} - Độ chính xác: ${(label.confidence * 100).toStringAsFixed(2)}%\n';
        }
      });
    } catch (e) {
      setState(() {
        result = 'Lỗi khi nhận diện nhãn: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedItem = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedItem),
        actions: [
          IconButton(
            icon: Icon(Icons.add_photo_alternate, color: Colors.black),
            onPressed: getImageFromGallery,
          ),
          IconButton(
            icon: Icon(Icons.add_a_photo, color: Colors.black),
            onPressed: getImageFromCamera,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            isImageLoaded
                ? Center(
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(pickImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
                : Container(),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  result,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (selectedItem) {
            case 'Text Scanner':
              readTextFromAnImage();
              break;
            case 'Barcode Scanner':
              readBarcodeFromAnImage();
              break;
            case 'Label Scanner':
              readLabelFromAnImage();
              break;
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
