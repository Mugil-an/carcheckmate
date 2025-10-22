import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:carcheckmate/core/services/http_client.dart';
import 'package:carcheckmate/core/exceptions/network_exceptions.dart';
import 'package:carcheckmate/core/error/failures.dart';

@GenerateMocks([http.Client])
import 'http_client_test.mocks.dart';

void main() {
  late HttpClient httpClient;
  late MockClient mockHttpClient;

  setUpAll(() async {
    // Initialize dotenv for tests
    dotenv.testLoad(fileInput: '''
RAPIDAPI_KEY=test_api_key_12345
RAPIDAPI_HOST=rto-vehicle-information-india.p.rapidapi.com
''');
  });

  setUp(() {
    mockHttpClient = MockClient();
    httpClient = HttpClient(client: mockHttpClient);
  });

  group('HttpClient GET', () {
    const testEndpoint = '/test';
    
    test('returns decoded JSON when response is successful', () async {
      // Arrange
      final responseBody = {'status': true, 'data': 'test'};
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode(responseBody),
                200,
              ));

      // Act
      final result = await httpClient.get(testEndpoint);

      // Assert
      expect(result, equals(responseBody));
    });

    test('throws ConnectionTimeoutException on timeout', () async {
      // Arrange
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 20));
        return http.Response('', 200);
      });

      // Act & Assert
      expect(
        () => httpClient.get(testEndpoint),
        throwsA(isA<ConnectionTimeoutException>()),
      );
    });

    test('throws ValidationFailure on 400 status code', () async {
      // Arrange
      final errorBody = {'error': 'Bad request'};
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode(errorBody),
                400,
              ));

      // Act & Assert
      expect(
        () => httpClient.get(testEndpoint),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('throws ServerFailure on 404 status code', () async {
      // Arrange
      final errorBody = {'error': 'Not found'};
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode(errorBody),
                404,
              ));

      // Act & Assert
      expect(
        () => httpClient.get(testEndpoint),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('throws ServerFailure on 500 status code', () async {
      // Arrange
      final errorBody = {'error': 'Server error'};
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode(errorBody),
                500,
              ));

      // Act & Assert
      expect(
        () => httpClient.get(testEndpoint),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('HttpClient POST', () {
    const testEndpoint = '/test';
    final testBody = {'vehicle_no': 'MH12AB1234'};

    test('returns decoded JSON when POST is successful', () async {
      // Arrange
      final responseBody = {'status': true, 'data': 'success'};
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode(responseBody),
            200,
          ));

      // Act
      final result = await httpClient.post(testEndpoint, body: testBody);

      // Assert
      expect(result, equals(responseBody));
      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: jsonEncode(testBody),
      )).called(1);
    });

    test('sends correct headers with POST request', () async {
      // Arrange
      final responseBody = {'status': true};
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode(responseBody),
            200,
          ));

      // Act
      await httpClient.post(testEndpoint, body: testBody);

      // Assert
      verify(mockHttpClient.post(
        any,
        headers: argThat(
          allOf(
            containsPair('Content-Type', 'application/json'),
            containsPair('Accept', 'application/json'),
          ),
          named: 'headers',
        ),
        body: anyNamed('body'),
      )).called(1);
    });

    test('handles empty response body', () async {
      // Arrange
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 200));

      // Act & Assert
      expect(
        () => httpClient.post(testEndpoint, body: testBody),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('handles malformed JSON response', () async {
      // Arrange
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Invalid JSON', 200));

      // Act & Assert
      expect(
        () => httpClient.post(testEndpoint, body: testBody),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('throws correct exception for 429 rate limit', () async {
      // Arrange
      final errorBody = {'error': 'Rate limit exceeded'};
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode(errorBody),
            429,
          ));

      // Act & Assert
      expect(
        () => httpClient.post(testEndpoint, body: testBody),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
