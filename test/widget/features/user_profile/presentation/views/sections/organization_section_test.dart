import 'package:zedu/features/features.dart';

import '../../../../../../helpers/helpers.dart';

void main() {
  testWidgets(
    'sign out and delete wrap instead of overflowing a narrow panel',
    (tester) async {
      tester.view.physicalSize = const Size(560, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: OrganizationSection(
              organization: OrganizationProfile(
                id: 'org-1',
                name: 'Zedu',
                natureOfBusiness: 'Software',
                country: 'Nigeria',
              ),
              isSaving: false,
              onSave: _noopSave,
              onDelete: _noop,
              onLeave: _noop,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Sign out of workspace'), findsOneWidget);
      expect(find.text('Delete organization'), findsOneWidget);

      final signOut = tester.getRect(find.text('Sign out of workspace'));
      final deleteOrg = tester.getRect(find.text('Delete organization'));
      expect(deleteOrg.top, greaterThan(signOut.bottom));
    },
  );
}

void _noopSave(OrganizationProfile _) {}

Future<void> _noop() async {}
