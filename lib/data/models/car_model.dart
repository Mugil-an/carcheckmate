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

  /// Factory constructor for creating CarModel from Firestore document
  factory CarModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    final brand = data['brand'] as String? ?? '';
    final model = data['model'] as String? ?? '';
    final year = data['year'] as int? ?? 0;

    return CarModel(
      id: documentId,
      displayName: data['displayName'] as String? ?? '$brand $model ($year)',
      brand: brand,
      model: model,
      year: year,
      issues: List<String>.from(data['issues'] as List? ?? []),
      severities: List<String>.from(data['severities'] as List? ?? []),
      estimatedCostsINR: List<int>.from(data['estimatedCostsINR'] as List? ?? []),
    );
  }

  /// Convert CarModel to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'displayName': displayName,
      'issues': issues,
      'severities': severities,
      'estimatedCostsINR': estimatedCostsINR,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  List<Object> get props => [id, displayName, brand, model, year, issues, severities, estimatedCostsINR];
}
