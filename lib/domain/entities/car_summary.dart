import 'package:equatable/equatable.dart';

class CarSummary extends Equatable {
  final String id;
  final String displayName;
  final String brand;
  final String model;
  final int year;

  const CarSummary({
    required this.id,
    required this.displayName,
    required this.brand,
    required this.model,
    required this.year,
  });

  @override
  List<Object?> get props => [id, displayName, brand, model, year];
}
