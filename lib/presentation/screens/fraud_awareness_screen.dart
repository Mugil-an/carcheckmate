import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/common_background.dart';
import '../../app/theme.dart';

// --- Data Model for Content ---
class FraudContent {
  final String title;
  final String briefDescription;
  final String fullDescription;
  final IconData icon;

  const FraudContent({
    required this.title,
    required this.briefDescription,
    required this.fullDescription,
    required this.icon,
  });
}

// --- Stateful Screen to manage selection ---
class FraudAwarenessScreen extends StatefulWidget {
  const FraudAwarenessScreen({super.key});

  @override
  State<FraudAwarenessScreen> createState() => _FraudAwarenessScreenState();
}

class _FraudAwarenessScreenState extends State<FraudAwarenessScreen> {
  // Define the list of all content items
  final List<FraudContent> contents = const [
    FraudContent(
      title: "Odometer Tampering",
      briefDescription: "Misaligned digits, inconsistent service kms, wear not matching the mileage.",
      fullDescription: "This refers to the illegal practice of rolling back a vehicle's odometer to display a lower mileage. Look for misaligned digits on older mechanical odometers, inconsistencies between current mileage and service records, and excessive wear on the steering wheel or pedals that doesn't match the low mileage reading.",
      icon: Icons.shield_outlined,
    ),
    FraudContent(
      title: "Accident/Panel Repaint",
      briefDescription: "Shade differences, overspray near rubber trims, uneven panel gaps.",
      fullDescription: "Inspect the vehicle closely for signs of undisclosed accident repair. Indicators include shade differences between body panels, paint overspray visible on rubber trims or plastic parts, and inconsistent or wide gaps between fenders, doors, and hood/trunk. Use a paint thickness gauge if possible.",
      icon: Icons.shield_outlined,
    ),
    FraudContent(
      title: "Flood Damage",
      briefDescription: "Musty smell, silt under seats, corrosion on seat rails, water lines in boot.",
      fullDescription: "Hidden water damage can lead to electrical failure and extensive rust. Check for a persistent musty smell, silt or mud residue in hard-to-clean areas (like under seats or in the trunk), and corrosion on unexposed metal components like seat mounting rails.",
      icon: Icons.shield_outlined,
    ),
    FraudContent(
      title: "VIN/RC Mismatch",
      briefDescription: "Ensure stamped VIN matches RC and windscreen plate.",
      fullDescription: "The Vehicle Identification Number (VIN) must match across all documents and physical stamps. Verify the VIN on the chassis, the windscreen plate, and the Registration Certificate (RC). A mismatch suggests the car may be stolen or illegally modified.",
      icon: Icons.shield_outlined,
    ),
  ];

  // State variable to hold the index of the currently selected/expanded content
  int? _selectedIndex;

  // Function to handle card tap: toggle the selected index
  void _selectContent(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(
          title: "Fraud Awareness",
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          itemCount: contents.length,
          itemBuilder: (context, index) {
            final content = contents[index];
            return AccordionFraudCard(
              content: content,
              index: index,
              onTap: _selectContent,
              isExpanded: index == _selectedIndex,
            );
          },
        ),
      ),
    );
  }
}

// --- Reusable Accordion Fraud Card Widget ---
class AccordionFraudCard extends StatelessWidget {
  final FraudContent content;
  final int index;
  final ValueSetter<int> onTap;
  final bool isExpanded;

  const AccordionFraudCard({
    super.key,
    required this.content,
    required this.index,
    required this.onTap,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded 
              ? AppColors.accentLightest.withOpacity(0.7)
              : AppColors.textSecondary.withOpacity(0.4),
          width: isExpanded ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.05),
                  AppColors.accentLightest.withOpacity(0.1),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section (Always Visible)
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.accentLightest,
                              AppColors.accent,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        content.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        content.briefDescription,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      contentPadding: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: 16,
                        right: 16,
                      ),
                    ),

                    // Expanded Section (Detailed Description)
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              color: AppColors.accentLightest.withOpacity(0.4),
                              height: 1,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              content.fullDescription,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}