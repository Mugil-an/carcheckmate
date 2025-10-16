// lib/data/datasources/firebase_checklist_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carcheckmate/data/models/car_model.dart';
import '../../core/exceptions/checklist_exceptions.dart';

abstract class FirebaseChecklistDataSource {
  Future<List<CarModel>> loadCarModels();
  Future<CarModel?> getCarByModelDetails(String brand, String model, int year);
  Future<CarModel?> getCarById(String carId);
  Future<void> saveCarModel(CarModel carModel);
}

class FirebaseChecklistDataSourceImpl implements FirebaseChecklistDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'car_checklists';

  FirebaseChecklistDataSourceImpl(this._firestore);

  @override
  Future<List<CarModel>> loadCarModels() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .get();

      // Return empty list if no documents found - this is not an error condition
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return CarModel.fromFirestore(data, doc.id);
      }).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const ChecklistPermissionException();
      } else if (e.code == 'unavailable') {
        throw const ChecklistNetworkException();
      }
      throw ChecklistLoadFailedException(errorCode: e.code);
    } catch (e) {
      if (e is ChecklistException) rethrow;
      throw const ChecklistLoadFailedException();
    }
  }

  @override
  Future<CarModel?> getCarById(String carId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(carId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }

      return CarModel.fromFirestore(data, docSnapshot.id);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const ChecklistPermissionException();
      } else if (e.code == 'unavailable') {
        throw const ChecklistNetworkException();
      }
      throw CarDataNotFoundException(errorCode: e.code);
    } catch (e) {
      if (e is ChecklistException) rethrow;
      throw const CarDataNotFoundException();
    }
  }

  @override
  Future<CarModel?> getCarByModelDetails(String brand, String model, int year) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('brand', isEqualTo: brand)
          .where('model', isEqualTo: model)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      return CarModel.fromFirestore(data, doc.id);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const ChecklistPermissionException();
      } else if (e.code == 'unavailable') {
        throw const ChecklistNetworkException();
      }
      throw CarDataNotFoundException(errorCode: e.code);
    } catch (e) {
      if (e is ChecklistException) rethrow;
      throw const CarDataNotFoundException();
    }
  }

  @override
  Future<void> saveCarModel(CarModel carModel) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(carModel.id)
          .set(carModel.toFirestore());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const ChecklistPermissionException();
      } else if (e.code == 'unavailable') {
        throw const ChecklistNetworkException();
      }
      throw ChecklistLoadFailedException(errorCode: e.code);
    } catch (e) {
      throw const ChecklistLoadFailedException();
    }
  }
}