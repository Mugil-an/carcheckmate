import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:carcheckmate/data/repositories/vehicle_repository_impl.dart';
import 'package:carcheckmate/data/datasources/vehicle_remote_data_source.dart';
import 'package:carcheckmate/domain/entities/vehicle_details.dart';
import 'package:carcheckmate/core/exceptions/rto_exceptions.dart';

@GenerateMocks([VehicleRemoteDataSource])
import 'vehicle_repository_impl_test.mocks.dart';

void main() {
  late VehicleRepositoryImpl repository;
  late MockVehicleRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockVehicleRemoteDataSource();
    repository = VehicleRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('VehicleRepositoryImpl', () {
    const testVehicleNumber = 'DL1CAB1234';
    
    final testVehicleDetails = VehicleDetails(
      rc: testVehicleNumber,
      vinMasked: 'VIN123',
      engineNoMasked: 'ENG123',
      makerModel: 'Hyundai Creta',
      fuel: 'Diesel',
      taxStatus: 'Paid',
      rcValidTill: '2026-03-15',
      blacklist: 'No',
      fitnessStatus: const FitnessStatus(
        status: 'Valid',
        fitnessValidTill: '2028-03-15',
        rcValidTill: '2026-03-15',
      ),
    );

    test('should return VehicleDetails from data source', () async {
      // Arrange
      when(mockDataSource.getVehicleDetails(testVehicleNumber))
          .thenAnswer((_) async => testVehicleDetails);

      // Act
      final result = await repository.getVehicleDetails(testVehicleNumber);

      // Assert
      expect(result, equals(testVehicleDetails));
      verify(mockDataSource.getVehicleDetails(testVehicleNumber)).called(1);
    });

    test('should throw RTOException when data source throws Exception', () async {
      // Arrange
      when(mockDataSource.getVehicleDetails(testVehicleNumber))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.getVehicleDetails(testVehicleNumber),
        throwsA(isA<RTOException>()),
      );
    });

    test('should throw RTOException with appropriate message for vehicle not found', () async {
      // Arrange
      when(mockDataSource.getVehicleDetails(testVehicleNumber))
          .thenThrow(Exception('Vehicle not found'));

      // Act & Assert
      try {
        await repository.getVehicleDetails(testVehicleNumber);
        fail('Should have thrown RTOException');
      } catch (e) {
        expect(e, isA<RTOException>());
        expect((e as RTOException).message, contains('vehicle'));
      }
    });

    test('should handle empty vehicle number gracefully', () async {
      // Arrange
      const emptyVehicleNumber = '';

      // Act & Assert
      expect(
        () => repository.getVehicleDetails(emptyVehicleNumber),
        throwsA(isA<RTOException>()),
      );
    });
  });
}
