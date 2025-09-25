import 'package:flutter/material.dart';

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
    // --- RESTORING ORIGINAL COLORS ---
    const Color appBarBgColor = Color.fromARGB(255, 105, 208, 255);
    final Color? scaffoldBgColor = Colors.lightBlue[50];
    final Color? cardBgColor = Colors.lightBlue[100];
    const Color accentColor = Color.fromARGB(255, 27, 117, 165); // Dark Blue Accent
    const Color darkText = Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: const Text("Fraud Awareness"),
        backgroundColor: appBarBgColor,
        foregroundColor: const Color.fromARGB(255, 32, 74, 97),
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          final content = contents[index];
          return AccordionFraudCard(
            content: content,
            index: index, // Pass the index here
            onTap: _selectContent,
            isExpanded: index == _selectedIndex,
            accentColor: accentColor,
            cardColor: cardBgColor,
            darkText: darkText,
          );
        },
      ),
    );
  }
}

// --- Reusable Accordion Fraud Card Widget ---
class AccordionFraudCard extends StatelessWidget {
  final FraudContent content;
  final int index; // Now receiving the index
  final ValueSetter<int> onTap;
  final bool isExpanded;
  final Color accentColor;
  final Color? cardColor;
  final Color darkText;

  const AccordionFraudCard({
    super.key,
    required this.content,
    required this.index,
    required this.onTap,
    required this.isExpanded,
    required this.accentColor,
    required this.cardColor,
    required this.darkText,
  });

  @override
  Widget build(BuildContext context) {
    // A slightly darker light blue for the badge background
    final Color badgeBgColor = Colors.lightBlue.shade300; 

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
      elevation: 3,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpanded 
            ? BorderSide(color: accentColor, width: 2.0)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Always Visible)
            ListTile(
              leading: Container( // Circular Badge Container
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  // *** CHANGE HERE: Replaced Icon with Text for Number ***
                  child: Text(
                    (index + 1).toString(), // Display index + 1 (1, 2, 3, 4)
                    style: const TextStyle(
                      color: Colors.white, // White number for contrast
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              title: Text(
                content.title,
                style: TextStyle(fontWeight: FontWeight.bold, color: darkText),
              ),
              subtitle: Text(
                content.briefDescription,
                style: TextStyle(color: darkText), 
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: accentColor,
              ),
              contentPadding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
            ),
            
            // Expanded Section (Detailed Description)
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: accentColor.withOpacity(0.5), height: 1),
                    const SizedBox(height: 10),
                    Text(
                      content.fullDescription,
                      style: TextStyle(
                        color: darkText,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}