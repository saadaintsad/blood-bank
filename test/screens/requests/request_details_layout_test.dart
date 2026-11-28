import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_interest_repository.dart';
import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/models/user.dart';
import 'package:bloodbank/providers/open_requests_provider.dart';
import 'package:bloodbank/providers/request_details_provider.dart';
import 'package:bloodbank/screens/requests/open_requests_screen.dart';
import 'package:bloodbank/screens/requests/request_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../helpers/layout_helpers.dart';

/// Layout checks for Request details (seeker and donor views) and Open
/// Requests at 360 dp and 390 dp. Any overflow fails the test. Set
/// SCREENSHOT_DIR to also save a PNG of each.
void main() {
  const widths = [360.0, 390.0];
  final today = DateTime(2026, 11, 28);
  // 3 PM, so the sample responses read "Interested at 10:00 AM / 11:00 AM".
  final afternoon = DateTime(2026, 11, 28, 15);

  const requester = AppUser(
    id: 'user-3',
    name: 'Sample Requester',
    phone: '01700000003',
  );
  const donor = AppUser(
    id: 'user-2',
    name: 'Sample Donor',
    phone: '01700000002',
    isDonor: true,
  );

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadTestFonts();
  });

  /// Request details for [viewer], on a store prepared by [prepare].
  Widget detailsScreen(
    MockStore store,
    AppUser viewer, {
    String requestId = 'request-1',
  }) {
    return ChangeNotifierProvider(
      create: (_) => RequestDetailsProvider(
        MockRequestRepository(store, delay: Duration.zero),
        MockInterestRepository(store, delay: Duration.zero),
        MockDonorRepository(store, delay: Duration.zero),
        requestId: requestId,
        viewer: viewer,
        clock: () => store.now,
      )..load(),
      child: const RequestDetailsScreen(),
    );
  }

  for (final width in widths) {
    final label = width.toInt();

    testWidgets('seeker view fits at $label dp', (tester) async {
      final store = MockStore(today: today, now: afternoon);
      await pumpAt(tester, width, detailsScreen(store, requester));

      expect(find.text('Interested donors (2)'), findsOneWidget);
      expect(find.text('Emergency Alert'), findsOneWidget);
      await capture(tester, 'details_seeker_$label');
    });

    testWidgets('seeker view after an alert fits at $label dp', (tester) async {
      final store = MockStore(today: today, now: afternoon);
      store.lastEmergencyAlertByUserId[requester.id] = DateTime(2026, 11, 21);
      await pumpAt(tester, width, detailsScreen(store, requester));

      expect(find.text('Available again in 8 days'), findsOneWidget);
      await capture(tester, 'details_seeker_alert_used_$label');
    });

    testWidgets('donor view fits at $label dp', (tester) async {
      final store = MockStore(today: today, now: afternoon);
      await pumpAt(tester, width, detailsScreen(store, donor));

      expect(find.text("I'm Interested"), findsOneWidget);
      expect(find.text('01700000003'), findsOneWidget);
      await capture(tester, 'details_donor_$label');
    });

    testWidgets('donor view after tapping fits at $label dp', (tester) async {
      final store = MockStore(today: today, now: afternoon);
      await pumpAt(tester, width, detailsScreen(store, donor));

      final button = find.text("I'm Interested");
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text("You're interested in this request"), findsOneWidget);
      expect(find.textContaining('until 6:00 PM'), findsOneWidget);
      await capture(tester, 'details_donor_responded_$label');
    });

    testWidgets('blocked donor view fits at $label dp', (tester) async {
      final store = MockStore(today: today, now: afternoon);
      await pumpAt(
        tester,
        width,
        detailsScreen(store, donor, requestId: 'request-2'),
      );

      expect(find.textContaining("can't be given"), findsOneWidget);
      await capture(tester, 'details_donor_blocked_$label');
    });

    testWidgets('Open Requests fits at $label dp', (tester) async {
      final store = MockStore(today: today, now: afternoon);
      await pumpAt(
        tester,
        width,
        ChangeNotifierProvider(
          create: (_) => OpenRequestsProvider(
            MockRequestRepository(store, delay: Duration.zero),
            MockDonorRepository(store, delay: Duration.zero),
            viewerId: donor.id,
          )..load(),
          child: const OpenRequestsScreen(),
        ),
      );

      expect(find.text('You can give'), findsOneWidget);
      await capture(tester, 'open_requests_$label');
    });
  }
}
