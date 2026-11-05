import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

class MockApiBaseService extends Mock implements ApiBaseService {}

void main() {
  late MockApiBaseService api;
  late CreditsRemoteDataSourceImpl datasource;

  CreditsRemoteDataSourceImpl createDatasource() => CreditsRemoteDataSourceImpl(
    config: const AppConfig(
      apiBaseUrl: 'https://example.invalid',
      usesMockData: true,
    ),
    apiBaseService: api,
  );

  setUp(() {
    api = MockApiBaseService();
    datasource = createDatasource();
  });

  test(
    'mock verification updates readable usage without an API request',
    () async {
      await datasource.verifyPayment(sessionId: 'mock-session');

      final usage = await datasource.getUsage('org');
      expect(usage.balance, 1010);
      expect(usage.totalPurchased, 1010);
      expect(usage.totalConsumed, 0);
      verifyZeroInteractions(api);
    },
  );

  test('subsequent mock verifications update existing usage', () async {
    await datasource.verifyPayment(sessionId: 'first-session');
    await datasource.verifyPayment(sessionId: 'second-session');

    final usage = await datasource.getUsage('org');
    expect(usage.balance, 2010);
    expect(usage.totalPurchased, 2010);
    expect(usage.totalConsumed, 0);
  });

  test('mock usage is isolated between datasource instances', () async {
    final other = createDatasource();
    await datasource.verifyPayment(sessionId: 'mock-session');

    final usage = await other.getUsage('org');
    expect(usage.balance, 10);
    expect(usage.totalPurchased, 10);
    expect(usage.totalConsumed, 0);
  });

  test(
    'live verification sends the session to the existing endpoint',
    () async {
      final live = CreditsRemoteDataSourceImpl(
        config: const AppConfig(
          apiBaseUrl: 'https://example.invalid',
          usesMockData: false,
        ),
        apiBaseService: api,
      );
      when(
        () => api.post<Map<String, dynamic>>(
          path: '/credits/verify-payment',
          data: {'session_id': 'live-session'},
        ),
      ).thenAnswer(
        (_) async =>
            const ApiResponseModel(data: <String, dynamic>{}, statusCode: 200),
      );

      await live.verifyPayment(sessionId: 'live-session');

      verify(
        () => api.post<Map<String, dynamic>>(
          path: '/credits/verify-payment',
          data: {'session_id': 'live-session'},
        ),
      ).called(1);
      verifyNoMoreInteractions(api);
    },
  );

  test(
    'live getUsage falls back to the usage report when usage returns a list',
    () async {
      final live = CreditsRemoteDataSourceImpl(
        config: const AppConfig(
          apiBaseUrl: 'https://example.invalid',
          usesMockData: false,
        ),
        apiBaseService: api,
      );
      when(
        () => api.get<Map<String, dynamic>>(path: '/credits/usage/org-1'),
      ).thenAnswer(
        (_) async => ApiResponseModel(
          data: <String, dynamic>{'data': <Map<String, dynamic>>[]},
          statusCode: 200,
        ),
      );
      when(
        () => api.get<Map<String, dynamic>>(
          path: '/credits/usage-report/org-1',
        ),
      ).thenAnswer(
        (_) async => ApiResponseModel(
          data: <String, dynamic>{
            'data': <String, dynamic>{
              'balance': 120,
              'total_credited': 500,
              'total_used': 380,
            },
          },
          statusCode: 200,
        ),
      );

      final usage = await live.getUsage('org-1');

      expect(usage.balance, 120);
      expect(usage.totalPurchased, 500);
      expect(usage.totalConsumed, 380);
    },
  );

  test(
    'live getUsage still reads a map-shaped usage response directly',
    () async {
      final live = CreditsRemoteDataSourceImpl(
        config: const AppConfig(
          apiBaseUrl: 'https://example.invalid',
          usesMockData: false,
        ),
        apiBaseService: api,
      );
      when(
        () => api.get<Map<String, dynamic>>(path: '/credits/usage/org-1'),
      ).thenAnswer(
        (_) async => ApiResponseModel(
          data: <String, dynamic>{
            'data': <String, dynamic>{
              'balance': 30,
              'total_purchased': 90,
              'total_consumed': 60,
            },
          },
          statusCode: 200,
        ),
      );

      final usage = await live.getUsage('org-1');

      expect(usage.balance, 30);
      expect(usage.totalPurchased, 90);
      expect(usage.totalConsumed, 60);
    },
  );

  test('CreditUsageModel parses the usage-report JSON shape', () {
    final model = CreditUsageModel.fromJson({
      'balance': 75,
      'total_credited': 200,
      'total_used': 125,
    });

    expect(model.balance, 75);
    expect(model.totalPurchased, 200);
    expect(model.totalConsumed, 125);
  });
}
