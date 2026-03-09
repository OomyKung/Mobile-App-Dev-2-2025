// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/main.dart';

void main() {
  testWidgets('Login page renders demo users', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('เข้าสู่ระบบจัดการครุภัณฑ์'), findsOneWidget);
    expect(find.text('บัญชีตัวอย่าง'), findsOneWidget);
    expect(find.text('admin / admin123'), findsOneWidget);
    expect(find.text('staff / staff123'), findsOneWidget);
    expect(
      find.text('เลือกเข้าสู่ระบบด้วยผู้ใช้ตัวอย่าง 2 บัญชี'),
      findsOneWidget,
    );
  });
}
