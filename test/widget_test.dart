import 'package:fashion_app/core/localization/app_translations.dart';
import 'package:fashion_app/core/localization/locale_controller.dart';
import 'package:fashion_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Get.updateLocale() triggers performReassemble(), which pins the test
  // binding out of SchedulerPhase.idle and breaks pump(). Each locale is
  // tested by booting the app into it instead of toggling at runtime.
  Future<void> launch(WidgetTester tester, {Locale? locale}) async {
    SharedPreferences.setMockInitialValues(
      locale == null
          ? <String, Object>{}
          : <String, Object>{LocaleController.prefsKey: locale.languageCode},
    );

    await tester.pumpWidget(FashionStoreApp(initialLocale: locale));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('app launches, shows splash branding, then routes to login', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const FashionStoreApp());

    expect(find.text('ហាងម៉ូត'), findsOneWidget);
    expect(find.text('FASHION STORE'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('ហាងម៉ូត'), findsNothing);
    expect(find.text('អ៊ីមែល'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('boots into Khmer by default and offers both languages', (
    tester,
  ) async {
    await launch(tester);

    expect(find.text('អ៊ីមែល'), findsOneWidget);
    // The pre-auth language switcher labels itself in each language.
    expect(find.text('ភាសាខ្មែរ'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('renders the English locale when that is the saved language', (
    tester,
  ) async {
    await launch(tester, locale: AppTranslations.en);

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
