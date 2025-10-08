// lib/core/services/risk_calculator_service.dart
import 'package:carcheckmate/data/models/checklist_item.dart';

class RiskCalculatorService {
  double calculateScore({
    required List<ChecklistItem> items,
    required Map<String, bool> selections,
  }) {
    if (items.isEmpty) return 0.0;
    
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
  }

  double _calculateWeight(ChecklistItem item) {
    final severityWeight = _severityToWeight(item.severity);
    final costWeight = (item.estimatedCost / 100000).clamp(0.1, 2.0); // Normalize cost impact
    return severityWeight * (1.0 + costWeight); // Combine severity and cost
  }

  double _severityToWeight(String severity) {
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
  }
}