// lib/core/services/risk_calculator_service.dart
import 'package:carcheckmate/data/models/checklist_item.dart';
import '../exceptions/checklist_exceptions.dart';

class RiskCalculatorService {
  double calculateScore({
    required List<ChecklistItem> items,
    required Map<String, bool> selections,
  }) {
    try {
      // Validate inputs
      if (items.isEmpty) {
        throw const InvalidRiskDataException();
      }
      
      if (selections.isEmpty) {
        throw const InvalidRiskDataException();
      }

      // Validate that all items have corresponding selections
      for (var item in items) {
        if (!selections.containsKey(item.issue)) {
          throw const InvalidRiskDataException();
        }
      }
      
      int checkedItems = 0;
      double totalWeight = 0.0;
      double checkedWeight = 0.0;

      for (var item in items) {
        final weight = _calculateWeight(item);
        totalWeight += weight;
        
        if (selections[item.issue] == true) { // If item is checked (problem exists)
          checkedItems++;
          checkedWeight += weight;
        }
      }

      // Calculate percentage based on weighted severity
      final weightedScore = totalWeight > 0 ? (checkedWeight / totalWeight) * 100 : 0.0;
      
      // Ensure minimum progression: each checked item adds at least some risk
      final baseScore = (checkedItems.toDouble() / items.length) * 100;
      
      // Use the higher of weighted score or base score for better progression
      final finalScore = weightedScore > baseScore ? weightedScore : baseScore;
      
      return finalScore.clamp(0.0, 100.0);
    } catch (e) {
      if (e is ChecklistException) rethrow;
      throw const RiskCalculationFailedException();
    }
  }

  double _calculateWeight(ChecklistItem item) {
    try {
      final severityWeight = _severityToWeight(item.severity);
      final costWeight = (item.estimatedCost / 100000).clamp(0.1, 2.0); // Normalize cost impact
      return severityWeight * (1.0 + costWeight); // Combine severity and cost
    } catch (e) {
      throw const RiskCalculationFailedException();
    }
  }

  double _severityToWeight(String severity) {
    try {
      switch (severity.toLowerCase()) {
        case 'high':
          return 3.0; // High severity items have more weight
        case 'medium':
          return 2.0;
        case 'low':
          return 1.0;
        default:
          return 1.0;
      }
    } catch (e) {
      throw const InvalidRiskDataException();
    }
  }
}