import 'package:zedu/features/features.dart';

import '../../../../../../helpers/helpers.dart';

void main() {
  testWidgets('the page title matches the "Roles & permissions" menu item', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestMaterialApp(
        const Scaffold(body: RolesAndPermissionsSection(roles: [])),
      ),
    );

    expect(find.text('Roles & permissions'), findsOneWidget);
    expect(find.text('Roles & Permissions'), findsNothing);
  });

  testWidgets('tapping a role card opens its permissions list', (tester) async {
    const role = RolePermission(
      role: 'Admin',
      description: 'Full control over the workspace.',
      permissions: ['manage_members', 'manage_roles', 'manage_billing'],
    );
    await tester.pumpWidget(
      buildTestMaterialApp(
        const Scaffold(body: RolesAndPermissionsSection(roles: [role])),
      ),
    );

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('manage_members'), findsOneWidget);
    expect(find.text('manage_roles'), findsOneWidget);
    expect(find.text('manage_billing'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('manage_members'), findsNothing);
  });

  testWidgets('a role without permissions says so in its dialog', (
    tester,
  ) async {
    const role = RolePermission(
      role: 'Viewer',
      description: '',
      permissions: [],
    );
    await tester.pumpWidget(
      buildTestMaterialApp(
        const Scaffold(body: RolesAndPermissionsSection(roles: [role])),
      ),
    );

    await tester.tap(find.text('Viewer'));
    await tester.pumpAndSettle();

    expect(find.text('This role has no permissions yet.'), findsOneWidget);
  });
}
