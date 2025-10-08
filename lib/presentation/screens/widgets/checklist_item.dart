import 'package:carcheckmate/app/theme.dart';
import 'package:flutter/material.dart';


class ChecklistItem extends StatelessWidget {
  final String title;
  final String severity;
  final String estimatedCost;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const ChecklistItem({
    super.key,
    required this.title,
    required this.severity,
    required this.estimatedCost,
    required this.isChecked,
    required this.onChanged,
  });

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "high":
        return Colors.red.shade400;
      case "medium":
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color activeColor = AppColors.accent;

    void handleTap() {
      onChanged(!isChecked);
    }

    return InkWell(
      onTap: handleTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: isChecked ? 6 : 2,
        shadowColor: isChecked ? activeColor.withAlpha(128) : Colors.black.withAlpha(51),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isChecked ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isChecked ? activeColor : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(severity),
                          backgroundColor: _severityColor(severity),
                          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Est. Cost: $estimatedCost',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AbsorbPointer(
                child: Checkbox(
                  value: isChecked,
                  onChanged: (_) {},
                  activeColor: activeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}