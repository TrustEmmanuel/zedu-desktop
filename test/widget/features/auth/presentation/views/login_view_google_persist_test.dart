import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class FakeAuthNotifier extends AuthNotifier {
  int googleCalls = 0;
  bool? lastGooglePersist;

  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);

  @override
  Future<void> loginWithGoogle({bool persist = true}) async {
    googleCalls++;
    lastGooglePersist = persist;
    state = const AuthState(status: AuthStatus.authenticated);
  }
}

Widget buildLoginViewUnderTest(FakeAuthNotifier notifier) {
  final router = GoRouter(
    initialLocation: AppRouter.login,
    routes: [
      GoRoute(path: AppRouter.login, builder: (_, _) => const LoginView()),
      GoRoute(
        path: AppRouter.home,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('HOME-STUB'))),
      ),
    ],
  );
  return ProviderScope(
    overrides: [authNotifierProvider.overrideWith(() => notifier)],
    child: MaterialApp.router(routerConfig: router),
  );
}

Finder get googleButton => find.byWidgetPredicate(
  (widget) =>
      widget is SocialAuthButton && widget.label == 'Sign in with Google',
);

void main() {
  group('LoginView Google sign-in persist', () {
    Future<FakeAuthNotifier> pumpLogin(
      WidgetTester tester, {
      bool toggleRememberMe = false,
    }) async {
      await tester.binding.setSurfaceSize(const Size(1440, 1024));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final notifier = FakeAuthNotifier();
      await tester.pumpWidget(buildLoginViewUnderTest(notifier));
      await tester.pump();
      if (toggleRememberMe) {
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
      }
      await tester.ensureVisible(googleButton);
      await tester.tap(googleButton);
      await tester.pumpAndSettle();
      // Let the success toast's auto-dismiss timer fire so none is pending.
      await tester.pump(const Duration(seconds: 4));
      return notifier;
    }

    testWidgets('does not persist the session when Remember me is unticked', (
      tester,
    ) async {
      final notifier = await pumpLogin(tester);

      expect(notifier.googleCalls, 1);
      expect(notifier.lastGooglePersist, isFalse);
    });

    testWidgets('persists the session when Remember me is ticked', (
      tester,
    ) async {
      final notifier = await pumpLogin(tester, toggleRememberMe: true);

      expect(notifier.googleCalls, 1);
      expect(notifier.lastGooglePersist, isTrue);
    });
  });
}
