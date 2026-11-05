import 'package:zedu/features/features.dart';

import '../../../../../../helpers/helpers.dart';

const _noOpPermissions = <SystemPermission>[];
Future<bool> _noOpCreate({
  required String name,
  required String description,
  required Map<String, bool> permissions,
}) async {
  return true;
}

void main() {
  testWidgets('the page title matches the "Roles & permissions" menu item', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestMaterialApp(
        Scaffold(
          body: RolesAndPermissionsSection(
            roles: const [],
            onLoadPermissions: () async => _noOpPermissions,
            onCreateRole: _noOpCreate,
          ),
        ),
      ),
    );

    expect(find.text('Roles & permissions'), findsOneWidget);
    expect(find.text('Roles & Permissions'), findsNothing);
  });

  testWidgets('tapping a role card shows and hides its permissions', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestMaterialApp(
        Scaffold(
          body: RolesAndPermissionsSection(
            roles: const [
              RolePermission(
                role: 'Admin',
                description: 'Manages the workspace.',
                permissions: ['Manage members', 'Create channels'],
              ),
              RolePermission(
                role: 'Guest',
                description: 'Limited access.',
                permissions: [],
              ),
            ],
            onLoadPermissions: () async => _noOpPermissions,
            onCreateRole: _noOpCreate,
          ),
        ),
      ),
    );

    expect(find.text('Manage members'), findsNothing);

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    expect(find.text('Manage members'), findsOneWidget);
    expect(find.text('Create channels'), findsOneWidget);

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    expect(find.text('Manage members'), findsNothing);

    await tester.tap(find.text('Guest'));
    await tester.pumpAndSettle();
    expect(find.text('No permissions listed for this role.'), findsOneWidget);
  });
}
