# carcheckmate

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Module Purpose: The "Smart" Inspection 🧐
The Checklist Module is the heart of the CarCheckmate app's hands-on vehicle inspection. Its core purpose is to move beyond a generic, one-size-fits-all checklist and provide a data-driven, model-specific inspection guide.

Think of it as the difference between a general health checkup and a specialist's examination. A generic checklist might ask you to "Check Engine," which is vague. This module, however, knows that a 2013 Maruti Suzuki Celerio is prone to "AMT gear hunting at crawl speeds," while a 2007 BMW X3 is more likely to have "Turbocharger problems."

By tailoring the inspection points to the exact make, model, and year, the module empowers a regular buyer to inspect a car with the insight of an experienced mechanic, focusing on the most critical and costly potential issues for that specific vehicle.

# How It Works: From Selection to Score
The process is designed to be simple and intuitive, translating complex data into a clear, actionable score.

**Car Selection**: The user begins by selecting the car's make, model, and year from a dropdown menu. This action is the trigger that loads the specific set of known issues from the Firestore database.

**Dynamic Checklist Generation**: The app instantly populates a checklist with the top 10-15 common problems for the selected car. Each item displays the issue, its severity level (Low, Medium, High), and the estimated repair cost in INR (₹).

**The "Assumption of Health"**: The app starts with a perfect score of 100. It assumes the car is in excellent condition, and every checklist item is initially checked (marked as "OK"). This represents a baseline of trust.

**User Inspection & Interaction**: The user physically inspects the car. If they find an issue, or if they are unable to verify that a component is in good working order, they uncheck the corresponding item on the list. This action signifies a deviation from the perfect baseline.

**Real-Time Score Calculation**: Every time an item is unchecked, the Overall Score decreases in real-time. The penalty for each unchecked item is calculated using a risk formula:

`Penalty = (Severity Value) + (Estimated Cost / 10,000)`

- **Severity Value**: A predefined number (e.g., High=10, Medium=5, Low=2).
- **Cost Factor**: The repair cost is scaled down to contribute to the penalty.

This ensures that a severe, expensive problem (like a gearbox failure) has a much larger impact on the score than a minor, cheap one (like a paint chip).

# Score Chart Description 📊
The Overall Score is the final output of the checklist, designed to give the user an immediate and easy-to-understand assessment of the vehicle's mechanical risk. The score is displayed prominently in a color-coded card.

### Score: 80 - 100 (Low Risk) 🟢
**Meaning**: This vehicle appears to be in excellent mechanical condition. The user found few to no issues from the list of common problems.

**Interpretation**: The car has likely been well-maintained. Any potential repairs are expected to be minor and inexpensive. This is a "Green Light" vehicle that you can proceed to purchase with high confidence, pending the results of the service history and RTO checks.

### Score: 50 - 79 (Medium Risk) 🟠
**Meaning**: This vehicle has some potential issues. The user identified several minor problems or at least one significant, moderate-cost problem.

**Interpretation**: This is a "Yellow Light" vehicle. It's not a definite "no," but it requires caution. You should budget for potential near-future repairs. The score helps you negotiate the price down, using the specific unchecked items and their estimated costs as leverage (e.g., "The car needs a ₹20,000 suspension repair, so I'd like to adjust the price accordingly.").

### Score: 0 - 49 (High Risk) 🔴
**Meaning**: This vehicle shows signs of major mechanical problems or significant neglect. The user identified several high-severity/high-cost issues.

**Interpretation**: This is a "Red Light" vehicle. It has a high probability of needing expensive and immediate repairs. Unless you are a mechanic or are getting the car for an extremely low price and are prepared for the costs, it is strongly recommended to walk away from this purchase. The risk of it becoming a "money pit" is very high.