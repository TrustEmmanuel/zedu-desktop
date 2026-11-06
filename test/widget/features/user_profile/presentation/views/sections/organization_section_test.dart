import 'package:zedu/features/features.dart';

import '../../../../../../helpers/helpers.dart';

void main() {
  testWidgets('organisation settings show the country name, not the code', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      buildTestMaterialApp(
        Scaffold(
          body: OrganizationSection(
            organization: OrganizationProfile(
              id: 'org-1',
              name: 'Zedu',
              natureOfBusiness: 'Software',
              country: 'Za',
            ),
            isSaving: false,
            onSave: _noopSave,
            onDelete: _noop,
            onLeave: _noop,
          ),
        ),
      ),
    );

    expect(find.text('South Africa'), findsOneWidget);
    expect(find.text('Za'), findsNothing);
  });
}

void _noopSave(OrganizationProfile _) {}

Future<void> _noop() async {}
