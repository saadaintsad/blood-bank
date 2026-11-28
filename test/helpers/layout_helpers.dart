/// Shared helpers for the layout (screenshot) tests in test/screens/.
library;

import 'dart:io';

import 'package:bloodbank/theme/app_theme.dart';
import 'package:bloodbank/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shows [screen] at [width] dp wide and a tall height, so the whole
/// page is laid out (and can be captured) at once.
Future<void> pumpAt(WidgetTester tester, double width, Widget screen) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 2000);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

/// Saves a PNG of the screen when SCREENSHOT_DIR is set. Normal test runs
/// skip this.
Future<void> capture(WidgetTester tester, String name) async {
  final dir = Platform.environment['SCREENSHOT_DIR'];
  if (dir == null) return;
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(Uri.file('$dir/$name.png')),
  );
}

/// Registers a stand-in for Archivo and the Material icons, so text and
/// icons have realistic sizes instead of the test font's square blocks.
Future<void> loadTestFonts() async {
  final families = <String>{
    for (final style in [
      AppTheme.light.textTheme.bodyLarge,
      AppTheme.light.textTheme.titleMedium,
      AppTheme.light.textTheme.labelLarge,
      AppTheme.light.textTheme.headlineSmall,
      AppTextStyles.bloodGroup,
    ])
      if (style?.fontFamily != null) style!.fontFamily!,
  };
  final stand = File('C:/Windows/Fonts/arial.ttf');
  if (stand.existsSync()) {
    final bytes = stand.readAsBytesSync();
    for (final family in families) {
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  }
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final icons = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  );
  if (flutterRoot != null && icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}
