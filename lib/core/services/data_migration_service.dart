// lib/core/services/data_migration_service.dart
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carcheckmate/data/models/car_model.dart';
import 'package:carcheckmate/core/utils/json_parser.dart';


class DataMigrationService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'car_checklists';

  DataMigrationService(this._firestore);

  /// Migrate data from local JSON to Firebase Firestore
  /// This should be called once to set up your Firebase database
  Future<void> migrateLocalDataToFirebase() async {
    try {
      // Load data from local assets
      final String response = await rootBundle.loadString('assets/data/Dataset.json');
      final List<CarModel> carModels = parseCarModels(response);

      print('Starting migration of ${carModels.length} car models to Firebase...');

      // Batch write to Firestore for better performance
      WriteBatch batch = _firestore.batch();
      int batchCount = 0;

      for (final carModel in carModels) {
        final docRef = _firestore.collection(_collection).doc(carModel.id);
        batch.set(docRef, carModel.toFirestore());
        batchCount++;

        // Firestore batch has a limit of 500 operations
        if (batchCount >= 500) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
          print('Migrated batch of 500 records...');
        }
      }

      // Commit remaining records
      if (batchCount > 0) {
        await batch.commit();
        print('Migrated final batch of $batchCount records');
      }

      print('✅ Successfully migrated ${carModels.length} car models to Firebase!');
    } catch (e) {
      print('❌ Migration failed: $e');
      rethrow;
    }
  }

  /// Check if Firebase already has data
  Future<bool> hasExistingData() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing data: $e');
      return false;
    }
  }

  /// Get count of documents in Firebase
  Future<int> getFirebaseDataCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting data count: $e');
      return 0;
    }
  }

  /// Clear all data from Firebase (use with caution!)
  Future<void> clearFirebaseData() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .get();

      WriteBatch batch = _firestore.batch();
      int batchCount = 0;

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        batchCount++;

        if (batchCount >= 500) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      print('✅ Cleared all Firebase data');
    } catch (e) {
      print('❌ Failed to clear Firebase data: $e');
      rethrow;
    }
  }
}