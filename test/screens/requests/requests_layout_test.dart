import 'dart:io';

import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/models/new_blood_request.dart';
import 'package:bloodbank/models/user.dart';
import 'package:bloodbank/providers/my_requests_provider.dart';
import 'package:bloodbank/providers/post_request_provider.dart';
import 'package:bloodbank/screens/requests/my_requests_screen.dart';
import 'package:bloodbank/screens/requests/post_request_screen.dart';
import 'package:bloodbank/theme/app_theme.dart';
import 'package:bloodbank/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Layout checks for Post Request and My Requests on small phones.
///
/// Flutter reports a "RenderFlex overflowed" error when something doesn't
/// fit, and the test fails on any such error. We check the two widths from
/// CLAUDE.md: 360 dp (small Android) and 390 dp.
///
/// Widget tests can't download fonts, so Archivo is swapped for a font of
/// similar width when one is available on the machine.
void main() {
  const widths = [360.0, 390.0];
  final today = DateTime(2026, 11, 28);
  const requester = AppUser(
    id: 'user-3',
    name: 'Sample Requester',
    phone: '01700000003',
  );

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadTestFonts();
  });

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

  /// A store whose Sample Requester has [openRequests] open requests.
  Future<MockRequestRepository> repositoryWith(int openRequests) async {
    final store = MockStore(today: today);
    final repository = MockRequestRepository(store, delay: Duration.zero);
    // The sample data already gives them one.
    for (var i = 1; i < openRequests; i++) {
      await repository.createRequest(
        NewBloodRequest(
          ownerId: requester.id,
          patientName: 'Sample Patient ${i + 1}',
          bloodGroup: i.isEven ? 'AB-' : 'O+',
          unitsNeeded: i + 1,
          hospital: 'Sample General Hospital',
          district: 'Chattogram',
          requiredDate: DateTime(2026, 11, 30),
          contactPhone: requester.phone,
          notes: 'Sample note: please call before coming.',
        ),
      );
    }
    return repository;
  }

  for (final width in widths) {
    final label = width.toInt();

    testWidgets('Post Request form fits at $label dp', (tester) async {
      final repository = await tester.runAsync(() => repositoryWith(1));
      await pumpAt(
        tester,
        width,
        ChangeNotifierProvider(
          create: (_) => PostRequestProvider(
            repository!,
            owner: requester,
            clock: () => today,
          )..load(),
          child: const PostRequestScreen(),
        ),
      );
      // Press Post Request empty, so the error messages show too.
      final postButton = find.widgetWithText(FilledButton, 'Post Request');
      await tester.ensureVisible(postButton);
      await tester.tap(postButton);
      await tester.pumpAndSettle();

      expect(find.text("Choose the patient's blood group"), findsOneWidget);
      await _capture(tester, 'post_request_$label');
    });

    testWidgets('Post Request limit panel fits at $label dp', (tester) async {
      final repository = await tester.runAsync(() => repositoryWith(3));
      await pumpAt(
        tester,
        width,
        ChangeNotifierProvider(
          create: (_) => PostRequestProvider(
            repository!,
            owner: requester,
            clock: () => today,
          )..load(),
          child: const PostRequestScreen(),
        ),
      );

      expect(find.text('You have 3 open requests'), findsOneWidget);
      await _capture(tester, 'limit_panel_$label');
    });

    testWidgets('My Requests fits at $label dp', (tester) async {
      final repository = await tester.runAsync(() async {
        final repository = await repositoryWith(3);
        // One closed request too, to show a closed card.
        await repository.closeRequest(
          'request-100',
          userId: requester.id,
          status: RequestStatus.fulfilled,
        );
        return repository;
      });
      await pumpAt(
        tester,
        width,
        ChangeNotifierProvider(
          create: (_) => MyRequestsProvider(
            repository!,
            userId: requester.id,
            clock: () => today,
          )..load(),
          child: const MyRequestsScreen(),
        ),
      );

      expect(find.text('Mark Fulfilled'), findsNWidgets(2));
      await _capture(tester, 'my_requests_$label');
    });
  }
}

/// Saves a PNG of the screen when SCREENSHOT_DIR is set. Normal test runs
/// skip this.
Future<void> _capture(WidgetTester tester, String name) async {
  final dir = Platform.environment['SCREENSHOT_DIR'];
  if (dir == null) return;
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(Uri.file('$dir/$name.png')),
  );
}

/// Registers a stand-in for Archivo and the Material icons, so text and
/// icons have realistic sizes instead of the test font's square blocks.
Future<void> _loadTestFonts() async {
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
