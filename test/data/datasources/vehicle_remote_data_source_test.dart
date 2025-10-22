import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:carcheckmate/data/datasources/vehicle_remote_data_source.dart';
import 'package:carcheckmate/core/services/http_client.dart';
import 'package:carcheckmate/domain/entities/vehicle_details.dart';

@GenerateMocks([HttpClient])
import 'vehicle_remote_data_source_test.mocks.dart';

void main() {
  late VehicleRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() async {
    // Initialize dotenv for tests
    dotenv.testLoad(fileInput: '''
RAPIDAPI_KEY=test_api_key_12345
RAPIDAPI_HOST=rto-vehicle-information-india.p.rapidapi.com
''');
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = VehicleRemoteDataSourceImpl(httpClient: mockHttpClient);
  });

  group('VehicleRemoteDataSource', () {
    const testVehicleNumber = 'MH12AB1234';
    
    final mockSuccessResponse = {
      'status': true,
      'data': {
        'rc': testVehicleNumber,
        'vin_masked': 'MABCD1234EFGH5678',
        'engine_no_masked': 'ENG123456',
        'maker': 'Maruti',
        'model': 'Swift',
        'fuel_type': 'Petrol',
        'tax_status': 'Paid',
        'rc_valid_till': '2025-12-31',
        'blacklist_status': 'No',
        'fitness_status': 'Valid',
        'fitness_valid_till': '2027-12-31',
        'hypothecation': {
          'status': 'Clear',
          'bank': 'None',
          'active_from': 'N/A',
          'active_to': 'N/A',
        },
      },
    };

    test('should return VehicleDetails when API call is successful', () async {
      // Arrange
      when(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockSuccessResponse);

      // Act
      final result = await dataSource.getVehicleDetails(testVehicleNumber);

      // Assert
      expect(result, isA<VehicleDetails>());
      expect(result.rc, testVehicleNumber.toUpperCase());
      expect(result.makerModel, contains('Maruti'));
      verify(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).called(1);
    });

    test('should format vehicle number to uppercase', () async {
      // Arrange
      when(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockSuccessResponse);

      // Act
      await dataSource.getVehicleDetails('mh12ab1234');

      // Assert
      verify(mockHttpClient.post(
        any,
        body: argThat(
          predicate((Map<String, dynamic> body) => 
            body['vehicle_no'] == 'MH12AB1234'
          ),
          named: 'body',
        ),
      )).called(1);
    });

    test('should throw Exception when API returns error status', () async {
      // Arrange
      final errorResponse = {
        'status': false,
        'message': 'Please check the vehicle no',
      };
      when(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).thenAnswer((_) async => errorResponse);

      // Act & Assert
      expect(
        () => dataSource.getVehicleDetails(testVehicleNumber),
        throwsA(isA<Exception>()),
      );
    });

    test('should retry on timeout error', () async {
      // Arrange - Simulate timeout then success
      var callCount = 0;
      when(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('timeout');
        }
        return mockSuccessResponse;
      });

      // Act
      final result = await dataSource.getVehicleDetails(testVehicleNumber);

      // Assert
      expect(result, isA<VehicleDetails>());
      expect(result.rc, equals(testVehicleNumber));
      
      // Should be called 2 times (initial attempt + 1 retry = 2 total attempts)
      verify(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).called(2);
    });

    test('should not retry on authentication error', () async {
      // Arrange
      when(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).thenThrow(Exception('unauthorized'));

      // Act & Assert
      expect(
        () => dataSource.getVehicleDetails(testVehicleNumber),
        throwsA(isA<Exception>()),
      );
      
      // Should not retry
      verify(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).called(1);
    });

    test('should handle response without data wrapper', () async {
      // Arrange
      final directResponse = {
        'status': true,
        'rc': testVehicleNumber,
        'chassis_no': 'CHASSIS123',
        'maker': 'Honda',
        'model': 'City',
        'fuel_type': 'Diesel',
        'tax_status': 'Pending',
        'rc_valid_till': '2026-06-30',
        'blacklist_status': 'No',
        'fitness_status': 'Valid',
        'fitness_valid_till': '2028-06-30',
      };
      
      when(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).thenAnswer((_) async => directResponse);

      // Act
      final result = await dataSource.getVehicleDetails(testVehicleNumber);

      // Assert
      expect(result, isA<VehicleDetails>());
      expect(result.makerModel, contains('Honda'));
    });

    test('should handle lien status correctly', () async {
      // Arrange
      final responseWithLien = {
        'status': true,
        'data': {
          'rc': testVehicleNumber,
          'vin_masked': 'VIN123',
          'engine_no_masked': 'ENG123',
          'maker': 'Tata',
          'model': 'Nexon',
          'fuel_type': 'Electric',
          'tax_status': 'Paid',
          'rc_valid_till': '2025-12-31',
          'blacklist_status': 'No',
          'fitness_status': 'Valid',
          'fitness_valid_till': '2027-12-31',
          'hypothecation': {
            'status': 'Active',
            'bank': 'HDFC Bank',
            'active_from': '2023-01-01',
            'active_to': '2028-01-01',
          },
        },
      };
      
      when(mockHttpClient.post(
        any,
        body: anyNamed('body'),
      )).thenAnswer((_) async => responseWithLien);

      // Act
      final result = await dataSource.getVehicleDetails(testVehicleNumber);

      // Assert
      expect(result.lienStatus?.status, 'Active');
      expect(result.lienStatus?.bank, 'HDFC Bank');
    });
  });
}
