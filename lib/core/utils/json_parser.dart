// lib/core/utils/json_parser.dart
import 'dart:convert';
import 'package:carcheckmate/data/models/car_model.dart';
import 'package:flutter/services.dart';

List<CarModel> parseCarModels(String responseBody) {
  final dynamic data = jsonDecode(responseBody);

  // If top-level is a Map with a list property (defensive), try to locate list
  List<dynamic> listData;
  if (data is List) {
    listData = data;
  } else if (data is Map && data.values.any((v) => v is List)) {
    // prefer first List found
    listData = data.values.firstWhere((v) => v is List) as List<dynamic>;
  } else {
    throw FormatException('Unexpected JSON structure for car models');
  }

  return listData.map<CarModel>((json) => CarModel.fromJson(Map<String, dynamic>.from(json))).toList();
}

Future<List<Map<String, dynamic>>> loadCarsForSelection() async {
  final String response = await rootBundle.loadString('assets/data/Dataset.json');
  final data = await json.decode(response) as List;
  return data.map((car) => {
    'brand': car['Brand'],
    'model': car['Model'],
    'year': car['Year'],
    'display': "${car['Brand']} ${car['Model']} (${car['Year']})"
  }).toList().cast<Map<String, dynamic>>();
}