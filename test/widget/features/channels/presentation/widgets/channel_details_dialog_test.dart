import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

Channel _channel({
  String description = '',
  String? topic,
  bool isPrivate = false,
}) => Channel(
  id: 'channel-general',
  name: 'general',
  description: description,
  topic: topic,
  isPrivate: isPrivate,
  organisationId: 'org-1',
  ownerId: 'user-1',
);

class _MembersRepository extends Mock implements ChannelRepository {
  @override
  Future<Result<List<DmParticipant>>> fetchChannelMembers(String id) async =>
      Success([
        DmParticipant(userId: 'u1', username: 'ada', email: 'ada@zedu.chat'),
        DmParticipant(userId: 'u2', username: 'ben', email: 'ben@zedu.chat'),
      ]);
}

class _NoMembersRepository extends Mock implements ChannelRepository {
  @override
  Future<Result<List<DmParticipant>>> fetchChannelMembers(String id) async =>
      const Success([]);
}

void main() {
  Future<void> pumpDialog(
    WidgetTester tester,
    Channel channel,
    ChannelRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          channelRepositoryProvider.overrideWithValue(repository),
        ],
        child: buildTestMaterialApp(
          Scaffold(body: ChannelDetailsDialog(channel: channel)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the channel name, description, topic and members', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      _channel(description: 'Team-wide chat.', topic: 'Daily standups'),
      _MembersRepository(),
    );

    expect(find.text('# general'), findsOneWidget);
    expect(find.text('Team-wide chat.'), findsOneWidget);
    expect(find.text('Daily standups'), findsOneWidget);
    expect(find.text('ada'), findsOneWidget);
    expect(find.text('ben'), findsOneWidget);
  });

  testWidgets('empty description and topic fall back to friendly notes', (
    tester,
  ) async {
    await pumpDialog(tester, _channel(), _NoMembersRepository());

    expect(find.text('No description yet.'), findsOneWidget);
    expect(find.text('Daily standups'), findsNothing);
    expect(find.text('No members yet.'), findsOneWidget);
  });

  testWidgets('private channels show the lock icon', (tester) async {
    await pumpDialog(tester, _channel(isPrivate: true), _NoMembersRepository());

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.tag), findsNothing);
  });
}
