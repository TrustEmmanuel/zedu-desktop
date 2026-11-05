import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

const _catalog = [
  SystemPermission(
    key: 'can_view_channels',
    name: 'View Channels',
    category: 'channels',
    description: 'View organisation channels',
  ),
  SystemPermission(
    key: 'can_create_channels',
    name: 'Create Channels',
    category: 'channels',
    description: 'Create new channels',
  ),
  SystemPermission(
    key: 'can_invite_members',
    name: 'Invite Members',
    category: 'members',
    description: 'Invite new members',
  ),
];

void main() {
  testWidgets('uses the approved roles and permissions subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestMaterialApp(
        RolesAndPermissionsSection(
          roles: const [],
          onLoadPermissions: () async => _catalog,
          onCreateRole: ({required name, required description, required permissions}) async => true,
        ),
      ),
    );

    expect(find.text('Roles & permissions'), findsOneWidget);
    expect(
      find.text(
        'Define and manage roles, then assign their associated permissions.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Define and manage roles and their associated permissions.'),
      findsNothing,
    );
    expect(find.text('Create Role'), findsOneWidget);
  });

  testWidgets('Create Role dialog posts the entered name and toggles', (
    tester,
  ) async {
    String? sentName;
    String? sentDescription;
    Map<String, bool>? sentPermissions;

    await tester.pumpWidget(
      buildTestMaterialApp(
        RolesAndPermissionsSection(
          roles: const [],
          onLoadPermissions: () async => _catalog,
          onCreateRole: ({required name, required description, required permissions}) async {
            sentName = name;
            sentDescription = description;
            sentPermissions = permissions;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Create Role'));
    await tester.pumpAndSettle();

    expect(find.text('Role name'), findsOneWidget);
    expect(find.text('Invite Members'), findsOneWidget);

    // The Create button stays disabled until the role has a name.
    final createButton = find.byKey(const Key('create-role-submit'));
    expect(tester.widget<FilledButton>(createButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Moderator');
    await tester.enterText(
      find.byType(TextField).last,
      'Keeps channels tidy',
    );
    await tester.pump();

    await tester.tap(find.text('Create Channels'));
    await tester.pump();

    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(sentName, 'Moderator');
    expect(sentDescription, 'Keeps channels tidy');
    expect(sentPermissions, {
      'can_view_channels': false,
      'can_create_channels': true,
      'can_invite_members': false,
    });
    // The dialog closes after a successful create.
    expect(find.text('Role name'), findsNothing);
  });

  testWidgets('Create Role dialog stays open when the create fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestMaterialApp(
        RolesAndPermissionsSection(
          roles: const [],
          onLoadPermissions: () async => _catalog,
          onCreateRole: ({required name, required description, required permissions}) async => false,
        ),
      ),
    );

    await tester.tap(find.text('Create Role'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Moderator');
    await tester.pump();

    await tester.tap(find.byKey(const Key('create-role-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Role name'), findsOneWidget);
  });
}
