// lib/core/services/risk_calculator_service.dart
import 'package:carcheckmate/data/models/checklist_item.dart';

class RiskCalculatorService {
  double calculateScore({
    required List<ChecklistItem> items,
    required Map<String, bool> selections,
  }) {
    double score = 100.0;

    for (var item in items) {
      if (selections[item.issue] == false) {
        score -= _calculatePenalty(item);
      }
    }

    return score.clamp(0.0, 100.0);
  }

  double _calculatePenalty(ChecklistItem item) {
    final severityValue = _severityToValue(item.severity);
    final costFactor = item.estimatedCost / 10000;
    return severityValue + costFactor;
  }

  double _severityToValue(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 10.0;
      case 'medium':
        return 5.0;
      case 'low':
        return 2.0;
      default:
        return 0.0;
    }
  }
}