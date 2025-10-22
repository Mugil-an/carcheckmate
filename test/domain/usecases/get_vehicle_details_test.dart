import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:carcheckmate/domain/usecases/get_vehicle_details.dart';
import 'package:carcheckmate/domain/repositories/vehicle_repository.dart';
import 'package:carcheckmate/domain/entities/vehicle_details.dart';
import 'package:carcheckmate/core/error/failures.dart';

@GenerateMocks([VehicleRepository])
import 'get_vehicle_details_test.mocks.dart';

void main() {
  late GetVehicleDetailsUseCase useCase;
  late MockVehicleRepository mockRepository;

  setUp(() {
    mockRepository = MockVehicleRepository();
    useCase = GetVehicleDetailsUseCase(mockRepository);
  });

  group('GetVehicleDetailsUseCase', () {
    const testVehicleNumber = 'KA01AB1234';
    
    final testVehicleDetails = VehicleDetails(
      rc: testVehicleNumber,
      vinMasked: 'VIN123456789',
      engineNoMasked: 'ENG987654',
      makerModel: 'Toyota Fortuner',
      fuel: 'Diesel',
      taxStatus: 'Paid',
      rcValidTill: '2027-05-20',
      blacklist: 'No',
      fitnessStatus: const FitnessStatus(
        status: 'Valid',
        fitnessValidTill: '2029-05-20',
        rcValidTill: '2027-05-20',
      ),
      lienStatus: const LienStatus(
        status: 'Clear',
        bank: 'None',
        activeFrom: 'N/A',
        activeTo: 'N/A',
      ),
    );

    test('should get vehicle details from repository', () async {
      // Arrange
      when(mockRepository.getVehicleDetails(testVehicleNumber))
          .thenAnswer((_) async => testVehicleDetails);

      // Act
      final result = await useCase(testVehicleNumber);

      // Assert
      expect(result, equals(testVehicleDetails));
      verify(mockRepository.getVehicleDetails(testVehicleNumber)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate ServerFailure from repository', () async {
      // Arrange
      when(mockRepository.getVehicleDetails(testVehicleNumber))
          .thenThrow(const ServerFailure('Repository error'));

      // Act & Assert
      expect(
        () => useCase(testVehicleNumber),
        throwsA(isA<ServerFailure>()),
      );
      verify(mockRepository.getVehicleDetails(testVehicleNumber)).called(1);
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      when(mockRepository.getVehicleDetails(any))
          .thenAnswer((_) async => testVehicleDetails);

      // Act
      await useCase(testVehicleNumber);

      // Assert
      verify(mockRepository.getVehicleDetails(testVehicleNumber)).called(1);
    });
  });
}
