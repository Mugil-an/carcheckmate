import 'package:equatable/equatable.dart';

class CarModel extends Equatable {
  final String id;
  final String displayName;
  final String brand;
  final String model;
  final int year;
  final List<String> issues;
  final List<String> severities;
  final List<int> estimatedCostsINR;

  const CarModel({
    required this.id,
    required this.displayName,
    required this.brand,
    required this.model,
    required this.year,
    required this.issues,
    required this.severities,
    required this.estimatedCostsINR,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    final brand = json['Brand'] as String;
    final model = json['Model'] as String;
    final year = json['Year'] as int;

    List<String> parseStringToList(String toParse) {
        return toParse.replaceAll(RegExp(r"[\[\]']"), '').split(', ');
    }

    List<int> parseIntList(String toParse) {
        return toParse.replaceAll(RegExp(r"[\[\]]"), '').split(', ').map(int.parse).toList();
    }

    return CarModel(
      id: '$brand-$model-$year',
      displayName: '$brand $model ($year)',
      brand: brand,
      model: model,
      year: year,
      issues: parseStringToList(json['Issues']),
      severities: parseStringToList(json['Severities']),
      estimatedCostsINR: parseIntList(json['EstimatedCostsINR']),
    );
  }

  @override
  List<Object> get props => [id, displayName, brand, model, year, issues, severities, estimatedCostsINR];
}
