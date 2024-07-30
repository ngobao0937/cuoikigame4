import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'UtilsScanner.dart';

class FaceDetectorScreen extends StatefulWidget {
  const FaceDetectorScreen({super.key});

  @override
  State<FaceDetectorScreen> createState() => _FaceDetectorScreenState();
}

class _FaceDetectorScreenState extends State<FaceDetectorScreen> {
  bool isWorking = false;
  CameraController? cameraController;
  FaceDetector? faceDetector;
  Size? size;
  List<Face>? facesList;
  CameraDescription? description;
  CameraLensDirection? cameraLensDirection = CameraLensDirection.front;
  initCamera()async{
    description = await UtilsScanner.getCamera(cameraLensDirection!);
    cameraController = CameraController(description!, ResolutionPreset.medium);
    faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true, // Enable landmarks if needed
        minFaceSize: 0.1,
      ),
    );
    await cameraController!.initialize().then((value){
      if(!mounted){
        return;
      }
      cameraController!.startImageStream((imageFromStream) => {
        if(!isWorking){
          isWorking = true,
          performDetectionOnStreamFrames(imageFromStream),
        }
      });
    });
  }
  dynamic scanResults;
  performDetectionOnStreamFrames(CameraImage cameraImage)async{
    UtilsScanner.detect(image: cameraImage, detectInImage: faceDetector!.processImage, imageRotation: description!.sensorOrientation,).then((dynamic results){
      setState(() {
        scanResults = results;
      });
    }).whenComplete((){
      isWorking = false;
    });
  }
  @override
  void initState(){
    super.initState();
    initCamera();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController?.dispose();
    faceDetector!.close();
  }
  Widget buildResult(){
    if(scanResults == null || cameraController == null || !cameraController!.value.isInitialized){
      return const Text("");
    }
    final Size imageSize = Size(cameraController!.value.previewSize!.height, cameraController!.value.previewSize!.width);
    CustomPainter customPainter = FaceDetectorPainter(imageSize, scanResults, cameraLensDirection!);
    return CustomPaint(painter: customPainter);
  }
  toggleCameraToFrontOrBack() async{
    if(cameraLensDirection == CameraLensDirection.back){
      cameraLensDirection = CameraLensDirection.front;
    }else{
      cameraLensDirection = CameraLensDirection.back;
    }
    await cameraController!.stopImageStream();
    await cameraController!.dispose();

    setState(() {
      cameraController = null;
    });
    initCamera();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> stackWidgetChildren = [];
    size = MediaQuery.of(context).size;
    if(cameraController != null){
      stackWidgetChildren.add(
          Positioned(
            top: 0,
            left: 0,
            width: size!.width,
            height: size!.height - 250,
            child: Container(
              child: (cameraController!.value.isInitialized) ? AspectRatio(aspectRatio: cameraController!.value.aspectRatio, child: CameraPreview(cameraController!),) : Container(),
            ),
          )
      );
    }
    stackWidgetChildren.add(
        Positioned(
          top: 0,
          left: 0,
          width: size!.width,
          height: size!.height - 250,
          child: buildResult(),
        )
    );
    stackWidgetChildren.add(
        Positioned(
          top: size!.height - 250,
          left: 0,
          width: size!.width,
          height: 250,
          child: Container(
            margin: const EdgeInsets.only(bottom: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: (){
                    toggleCameraToFrontOrBack();
                  },
                  icon: Icon(Icons.cached, color: Colors.white,), iconSize: 40, color: Colors.black,)
              ],
            ),
          ),
        )
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(
          children: stackWidgetChildren,
        ),
      ),
    );
  }
}
class FaceDetectorPainter extends CustomPainter{
  FaceDetectorPainter(this.absoluteImageSize, this.faces, this.cameraLensDirection);
  final Size absoluteImageSize;
  final List<Face> faces;
  CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final double scaleX = size.width/absoluteImageSize.width;
    final double scaleY = size.height/absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for(Face face in faces){
      canvas.drawRect(
          Rect.fromLTRB(
            cameraLensDirection == CameraLensDirection.front?(absoluteImageSize.width - face.boundingBox.right) * scaleX:face.boundingBox.left * scaleX,
            face.boundingBox.top * scaleY,
            cameraLensDirection == CameraLensDirection.front?(absoluteImageSize.width - face.boundingBox.left) * scaleX:face.boundingBox.right * scaleX,
            face.boundingBox.bottom * scaleY,
          ),
          paint
      );
    }
  }
  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate.absoluteImageSize != absoluteImageSize || oldDelegate.faces != faces;
  }
}
