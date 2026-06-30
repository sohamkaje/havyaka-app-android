import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:havyaka_app_android/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HAAConventionApp());
    expect(find.text('HAA Convention 2026'), findsOneWidget);
  });
}
