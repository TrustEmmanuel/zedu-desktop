import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class MockDmRepository extends Mock implements DmRepository {}

void main() {
  late MockDmRepository repository;
  late Map<String, dynamic>? tapped;

  setUp(() {
    repository = MockDmRepository();
    tapped = null;
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    Future<List<Map<String, dynamic>>> Function()? load,
  }) async {
    if (load != null) {
      when(
        () => repository.getPinnedMessages('ch-1'),
      ).thenAnswer((_) => load());
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dmRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light.copyWith(splashFactory: NoSplash.splashFactory),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  tapped = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (_) => const PinnedMessagesDialog(
                      channelId: 'ch-1',
                      conversationName: 'Ada',
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the pinned records with sender, time and content', (
    tester,
  ) async {
    final sentAt = DateTime.now().subtract(const Duration(minutes: 5));
    await pumpDialog(
      tester,
      load: () async => [
        {
          'thread_id': 't-1',
          'message': '<p>pinned hello</p>',
          'type': 'thread',
          'full_name': 'Ada Lovelace',
          'created_at': sentAt.toIso8601String(),
        },
      ],
    );

    expect(find.text('Pinned messages'), findsOneWidget);
    expect(find.text('Pinned in Ada'), findsOneWidget);
    expect(find.textContaining('Ada Lovelace'), findsOneWidget);
    expect(find.text('pinned hello'), findsOneWidget);
  });

  testWidgets('shows an empty state when nothing is pinned', (tester) async {
    await pumpDialog(tester, load: () async => []);

    expect(
      find.text('No pinned messages in this conversation.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an error with a working retry', (tester) async {
    var calls = 0;
    await pumpDialog(
      tester,
      load: () async {
        calls++;
        if (calls == 1) throw Exception('network down');
        return [
          {
            'thread_id': 't-1',
            'message': 'back online',
            'type': 'thread',
            'username': 'ada',
          },
        ];
      },
    );

    expect(find.text("Couldn't load pinned messages."), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('back online'), findsOneWidget);
  });

  testWidgets('tapping a pinned message closes the dialog with the record', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      load: () async => [
        {
          'thread_id': 't-1',
          'message': 'jump here',
          'type': 'thread',
          'username': 'ada',
        },
      ],
    );

    await tester.tap(find.text('jump here'));
    await tester.pumpAndSettle();

    expect(find.byType(PinnedMessagesDialog), findsNothing);
    expect(tapped, isNotNull);
    expect(tapped!['thread_id'], 't-1');
  });

  testWidgets('strips HTML tags from the preview', (tester) async {
    await pumpDialog(
      tester,
      load: () async => [
        {
          'thread_id': 't-1',
          'message': '<p>plain <b>text</b> &amp; more</p>',
          'type': 'thread',
          'username': 'ada',
        },
      ],
    );

    expect(find.text('plain text & more'), findsOneWidget);
  });
}
