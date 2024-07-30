import 'package:camera/camera.dart';
import 'package:cuoikigame4/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cuoikigame4/FaceDetection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test FaceDetectorScreen functionality', (WidgetTester tester) async {
    // Khởi động ứng dụng và điều hướng đến FaceDetectorScreen
    await tester.pumpWidget(MaterialApp(
      home: MyApp(),
    ));
    await tester.pumpAndSettle();

    // Kiểm tra xem FaceDetectorScreen có được hiển thị hay không
    expect(find.byType(FaceDetectorScreen), findsOneWidget);

    // Kiểm tra nếu camera đã được khởi tạo
    expect(find.byType(CameraPreview), findsOneWidget);

    // Nhấn vào nút chuyển đổi camera
    await tester.tap(find.byIcon(Icons.cached));
    await tester.pumpAndSettle();

    // Kiểm tra nếu camera đã được chuyển đổi
    // (Bạn có thể thêm kiểm tra cụ thể hơn nếu cần)

    // Kiểm tra nếu hình chữ nhật được vẽ để đánh dấu khuôn mặt
    // (Bạn cần đảm bảo rằng một số khuôn mặt đã được phát hiện trong khung hình)
    // Lưu ý: Phần này có thể khó kiểm tra trong môi trường test vì yêu cầu hình ảnh thực tế từ camera

    // Mô phỏng việc phát hiện khuôn mặt
    // Bạn có thể cần phải sử dụng mock hoặc một cách nào đó để kiểm tra phần này
  });
}
