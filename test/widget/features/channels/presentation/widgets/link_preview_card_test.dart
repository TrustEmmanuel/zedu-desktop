import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  tearDown(() {
    linkPreviewFetcher = _fetchDefault;
  });

  testWidgets('renders the OpenGraph title, description and image', (
    tester,
  ) async {
    linkPreviewFetcher = (url) async => const LinkPreviewData(
      title: 'Zedu | Team Messaging',
      description: 'Chat with your team.',
      imageUrl: 'https://zedu.chat/logo.png',
      url: '',
    );

    await tester.pumpWidget(
      buildTestMaterialApp(
        Scaffold(
          body: LinkPreviewCard(url: 'https://zedu.chat'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zedu | Team Messaging'), findsOneWidget);
    expect(find.text('Chat with your team.'), findsOneWidget);
    expect(find.text('zedu.chat'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('renders nothing when the page has no metadata', (tester) async {
    linkPreviewFetcher = (url) async => const LinkPreviewData(
      title: '',
      description: '',
      imageUrl: '',
      url: '',
    );

    await tester.pumpWidget(
      buildTestMaterialApp(
        Scaffold(
          body: LinkPreviewCard(url: 'https://zedu.chat'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Container), findsNothing);
  });

  testWidgets('renders nothing while the preview loads', (tester) async {
    linkPreviewFetcher = (url) => Future<LinkPreviewData>.delayed(
      const Duration(milliseconds: 50),
      () => const LinkPreviewData(
        title: 'Later',
        description: '',
        imageUrl: '',
        url: '',
      ),
    );

    await tester.pumpWidget(
      buildTestMaterialApp(
        Scaffold(
          body: LinkPreviewCard(url: 'https://zedu.chat'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Later'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Later'), findsOneWidget);
  });
}

// The real fetcher, restored after each test.
Future<LinkPreviewData> _fetchDefault(String url) async =>
    const LinkPreviewData(title: '', description: '', imageUrl: '', url: '');
