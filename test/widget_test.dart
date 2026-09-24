import 'package:fashion_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app launches, shows splash branding, then routes to login', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FashionStoreApp());

    expect(find.text('ហាងម៉ូត'), findsOneWidget);
    expect(find.text('FASHION STORE'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('ហាងម៉ូត'), findsNothing);
    expect(find.text('អ៊ីមែល'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}