// lib/data/datasources/local_checklist_datasource.dart
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:carcheckmate/core/utils/json_parser.dart';
import 'package:carcheckmate/data/models/car_model.dart';

abstract class LocalChecklistDataSource {
  Future<List<CarModel>> loadCarModels();
}

class LocalChecklistDataSourceImpl implements LocalChecklistDataSource {
  @override
  Future<List<CarModel>> loadCarModels() async {
    final String response = await rootBundle.loadString('assets/data/Dataset.json');
    final List<CarModel> carModels = await compute(parseCarModels, response);
    return carModels;
  }
}
