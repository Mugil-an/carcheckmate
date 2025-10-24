# CarCheckMate 🚗

> **Your Complete Used Car Inspection & Verification Companion**

CarCheckMate is a comprehensive Flutter mobile application designed to empower used car buyers in India with professional-grade inspection tools, automated vehicle verification, and data-driven risk assessment. Make informed decisions and avoid costly mistakes when purchasing a used vehicle.

[![Flutter](https://img.shields.io/badge/Flutter-3.5%2B-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5%2B-blue)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📱 Features

### 🔍 **RTO Vehicle Verification**
- Fetch complete vehicle registration details using RC number
- Verify VIN, Engine Number, and chassis details
- Check tax status, fitness certification, and validity dates
- Detect blacklist status and lien/hypothecation information
- Integrated with RapidAPI RTO Vehicle Information India

### 📋 **Smart Inspection Checklist**
- **Model-Specific Checklists**: Tailored inspection points for each make, model, and year
- **Known Issues Database**: Pre-loaded common problems from Firestore
- **Real-Time Risk Scoring**: Dynamic calculation based on severity and repair costs
- **Color-Coded Assessment**: Instant visual feedback (Green/Yellow/Red)
- **Repair Cost Estimation**: Know what issues might cost before buying

### 📄 **Document Management & OCR**
- Upload and store vehicle documents (RC, Insurance, Service History)
- AI-powered OCR text extraction from documents
- Automatic data parsing (dates, amounts, service records)
- Document type detection (Invoice, RC, Insurance)
- Service history analysis and validation

### 🔒 **Lien & Hypothecation Check**
- Real-time finance/loan status verification
- Bank and financer information
- Active lien period tracking
- Clear vs. Financed status indication

### 📊 **Risk Assessment Engine**
**Weighted Scoring Algorithm**: Higher score = More issues found

**Score Interpretation:**
- 🟢 **0-49 (Low Risk)**: Excellent condition - Few or no issues found, safe to buy
- 🟠 **50-79 (Medium Risk)**: Some issues - Negotiate price based on findings
- 🔴 **80-100 (High Risk)**: Major problems - Multiple severe issues, walk away

### 🎨 **Modern UI/UX**
- Clean, intuitive interface
- Gradient-based design with primary colors
- Responsive layouts for all screen sizes
- Real-time feedback and animations
- Firebase authentication integration

## 🏗️ Architecture

CarCheckMate follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                      # Core functionality
│   ├── config/               # API configuration, constants
│   ├── error/                # Error handling (Failures)
│   ├── exceptions/           # Custom exceptions (RTO, Network)
│   └── services/             # Shared services (HTTP, OCR)
├── data/                      # Data layer
│   ├── datasources/          # Remote/local data sources
│   ├── models/               # Data models with JSON serialization
│   └── repositories/         # Repository implementations
├── domain/                    # Business logic layer
│   ├── entities/             # Business entities
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Business use cases
├── logic/                     # State management (BLoC)
│   └── vehicle_verification/ # Vehicle verification BLoC
├── presentation/              # UI layer
│   ├── screens/              # App screens
│   └── widgets/              # Reusable widgets
└── utilities/                 # Helper functions
```

### Key Design Patterns
- **Repository Pattern**: Abstract data sources
- **BLoC Pattern**: State management with flutter_bloc
- **Dependency Injection**: Loose coupling between layers
- **Single Responsibility**: Each class has one clear purpose

## 🚀 Getting Started

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (3.0 or higher) - Included with Flutter
- **Android Studio** or **VS Code** - [Download](https://developer.android.com/studio)
- **Git** - [Download](https://git-scm.com/)
- **Firebase Account** - [Get Started](https://firebase.google.com/)
- **RapidAPI Account** (for vehicle verification) - [Sign up](https://rapidapi.com/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mugil-an/carcheckmate.git
   cd carcheckmate
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the project root:
   ```env
   # RapidAPI Configuration
   RAPIDAPI_KEY=your_rapidapi_key_here
   RAPIDAPI_HOST=rto-vehicle-information-india.p.rapidapi.com
   
   # Admin Configuration
   ADMIN_EMAIL=your_email@example.com
   ```

4. **Set up Firebase**
   
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Download `google-services.json` (Android) and place it in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`
   - Enable Authentication and Firestore Database in Firebase Console

5. **Get RapidAPI Key**
   
   - Sign up at [RapidAPI](https://rapidapi.com/)
   - Subscribe to [RTO Vehicle Information India API](https://rapidapi.com/hub)
   - Copy your API key to `.env` file

6. **Run the app**
   ```bash
   # Check for issues
   flutter doctor
   
   # Run on connected device/emulator
   flutter run
   
   # Build release APK
   flutter build apk --release
   ```

### Quick Start Guide

1. **Launch the app** and sign in with Google/Email
2. **Navigate to RTO Verification** screen
3. **Enter vehicle registration number** (e.g., MH12AB1234)
4. **View vehicle details**, tax status, and lien information
5. **Go to Inspection Checklist** screen
6. **Select vehicle make, model, and year**
7. **Follow the checklist** and uncheck any issues found
8. **Get instant risk score** and recommendations

## 📖 How It Works

### Module Purpose: The "Smart" Inspection 🧐

The Checklist Module is the heart of CarCheckMate's hands-on vehicle inspection. Its core purpose is to move beyond generic, one-size-fits-all checklists and provide **data-driven, model-specific inspection guides**.

Think of it as the difference between a general health checkup and a specialist's examination. A generic checklist might ask you to "Check Engine," which is vague. This module knows that:
- A **2013 Maruti Suzuki Celerio** is prone to "AMT gear hunting at crawl speeds"
- A **2007 BMW X3** is more likely to have "Turbocharger problems"
- A **2015 Honda City** may face "CVT transmission issues"

By tailoring inspection points to the exact make, model, and year, the module empowers regular buyers to inspect cars with the insight of experienced mechanics.

### Inspection Workflow: From Selection to Score

**Step 1: Car Selection**
- User selects make, model, and year from dropdown menus
- App loads model-specific known issues from Firestore database

**Step 2: Dynamic Checklist Generation**
- App populates checklist with 10-15 common problems for that specific vehicle
- Each item shows:
  - Issue description
  - Severity level (Low/Medium/High)
  - Estimated repair cost (₹)

**Step 3: The "Assumption of Health"**
- App starts with a base risk score of 0 (no issues found)
- All checklist items initially unchecked (no problems detected)
- Represents baseline assumption of good condition

**Step 4: User Inspection & Interaction**
- User physically inspects the vehicle
- **Checks items if issues are found** during inspection
- Real-time score updates with each change
- Score increases as more problems are identified

**Step 5: Risk Score Calculation**

The app uses a **weighted scoring algorithm** where each checked issue adds to the risk score:

```
Weight = (Severity Value) + (Repair Cost / 10,000)

Where:
- Severity Value: High=10, Medium=5, Low=2
- Cost Factor: Repair cost scaled down (e.g., ₹20,000 / 10,000 = 2)

Final Score = (Σ Checked Item Weights / Σ Total Weights) × 100
```

**Example:**
- Gearbox failure (High severity, ₹80,000 cost) = 10 + 8 = **18 weight**
- Paint chip (Low severity, ₹2,000 cost) = 2 + 0.2 = **2.2 weight**

If 2 out of 5 items are checked (20 weight out of 50 total):
- **Risk Score** = (20 / 50) × 100 = **40%** (Low Risk)

### Score Interpretation 📊

#### 🟢 Score: 0 - 49 (Low Risk)
**Meaning**: This vehicle appears to be in excellent mechanical condition. The user found few to no issues from the list of common problems.

**Interpretation**: 
- The car has likely been well-maintained
- Any potential repairs are expected to be minor and inexpensive
- This is a **"Green Light"** vehicle that you can proceed to purchase with high confidence, pending the results of the service history and RTO checks

**Action**: Negotiate final price, verify all documents, proceed with confidence

---

#### 🟠 Score: 50 - 79 (Medium Risk)
**Meaning**: This vehicle has some potential issues. The user identified several minor problems or at least one significant, moderate-cost problem.

**Interpretation**:
- This is a **"Yellow Light"** vehicle
- It's not a definite "no," but it requires caution
- You should budget for potential near-future repairs
- The score helps you negotiate the price down, using the specific unchecked items and their estimated costs as leverage (e.g., "The car needs a ₹20,000 suspension repair, so I'd like to adjust the price accordingly")

**Action**: Get professional mechanic inspection, negotiate price reduction, factor in repair costs before deciding

---

#### 🔴 Score: 80 - 100 (High Risk)
**Meaning**: This vehicle shows signs of major mechanical problems or significant neglect. The user identified several high-severity/high-cost issues.

**Interpretation**:
- **"Red Light"** - High probability of expensive, immediate repairs needed
- Serious risk of becoming a "money pit"
- Repair costs may exceed vehicle's market value
- Unless you're a mechanic or getting extreme discount, strongly avoid
- May require ₹50,000+ in repairs immediately

**Action**: Walk away from this purchase unless vehicle is priced at scrap value AND you can perform repairs yourself

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Material Design** - UI components

### State Management
- **flutter_bloc** - Business Logic Component pattern
- **equatable** - Value equality

### Backend & Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database for vehicle data
- **RapidAPI** - Vehicle registration verification
- **Google ML Kit** - OCR text recognition

### Networking & Data
- **http** - HTTP client
- **flutter_dotenv** - Environment variable management
- **json_annotation** - JSON serialization

### UI/UX Libraries
- **google_fonts** - Custom typography
- **image_picker** - Image selection
- **file_picker** - File selection
- **cached_network_image** - Image caching

## 🧪 Testing

CarCheckMate has comprehensive test coverage across all layers:

### Run All Tests
```bash
flutter test
```

### Run Specific Test Suites
```bash
# HTTP Client Tests (10 tests)
flutter test test/core/services/http_client_test.dart

# Vehicle Data Source Tests (8 tests)
flutter test test/data/datasources/vehicle_remote_data_source_test.dart

# Repository Tests (8 tests)
flutter test test/data/repositories/vehicle_repository_impl_test.dart

# Use Case Tests (3 tests)
flutter test test/domain/usecases/get_vehicle_details_test.dart

# OCR Service Tests
flutter test test/ocr_service_test.dart
```

### Test Coverage
```bash
# Generate coverage report
flutter test --coverage

# View coverage in browser (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Results ✅
- **Total Tests**: 31 passing
- **HTTP Client**: 10/10 ✅
- **Data Source**: 8/8 ✅
- **Repository**: 8/8 ✅
- **Use Cases**: 3/3 ✅
- **Other**: 2/2 ✅

## 📁 Project Structure
## 📁 Project Structure

```
carcheckmate/
├── android/                    # Android native code
├── ios/                        # iOS native code
├── assets/                     # Static assets
│   ├── images/                # App images and icons
│   └── data/                  # Local data files
├── lib/
│   ├── main.dart              # App entry point
│   ├── firebase_options.dart  # Firebase configuration
│   │
│   ├── app/                   # App-level configuration
│   │   └── app.dart          # Main app widget
│   │
│   ├── core/                  # Core functionality
│   │   ├── config/           
│   │   │   ├── api_config.dart      # API endpoints & settings
│   │   │   └── api_keys.dart        # API key management
│   │   ├── error/
│   │   │   └── failures.dart        # Failure classes
│   │   ├── exceptions/
│   │   │   ├── network_exceptions.dart
│   │   │   └── rto_exceptions.dart
│   │   └── services/
│   │       ├── http_client.dart     # HTTP service
│   │       └── ocr_service.dart     # OCR service
│   │
│   ├── data/                  # Data layer
│   │   ├── datasources/
│   │   │   └── vehicle_remote_data_source.dart
│   │   └── repositories/
│   │       └── vehicle_repository_impl.dart
│   │
│   ├── domain/                # Business logic layer
│   │   ├── entities/
│   │   │   └── vehicle_details.dart
│   │   ├── repositories/
│   │   │   └── vehicle_repository.dart
│   │   └── usecases/
│   │       └── get_vehicle_details.dart
│   │
│   ├── logic/                 # State management
│   │   └── vehicle_verification/
│   │       ├── vehicle_verification_bloc.dart
│   │       ├── vehicle_verification_event.dart
│   │       └── vehicle_verification_state.dart
│   │
│   ├── presentation/          # UI layer
│   │   ├── screens/
│   │   │   ├── home/         # Home screen
│   │   │   ├── rto/          # RTO verification screen
│   │   │   └── checklist/    # Inspection checklist screen
│   │   └── widgets/          # Reusable widgets
│   │
│   └── utilities/             # Helper functions
│
├── test/                      # Unit & widget tests
│   ├── core/
│   ├── data/
│   ├── domain/
│   └── logic/
│
├── docs/                      # Documentation
│   ├── API_STATUS.md         # API status & alternatives
│   ├── CAR_REGISTRATION_API.md
│   └── INTEGRATION_COMPLETE.md
│
├── scripts/                   # Utility scripts
│   ├── upload_data.dart      # Data upload script
│   └── test_car_registration_api.dart
│
├── .env                       # Environment variables
├── pubspec.yaml              # Dependencies
├── analysis_options.yaml     # Linter rules
└── README.md                 # This file
```

## 🔧 Configuration

### API Configuration

The app uses RapidAPI for vehicle verification. Configure in `.env`:

```env
RAPIDAPI_KEY=your_key_here
RAPIDAPI_HOST=rto-vehicle-information-india.p.rapidapi.com
```

API configuration is managed in:
- `lib/core/config/api_config.dart` - Base URLs, endpoints, timeouts
- `lib/core/config/api_keys.dart` - API key loading and headers

### Firebase Configuration

1. **Android**: Place `google-services.json` in `android/app/`
2. **iOS**: Place `GoogleService-Info.plist` in `ios/Runner/`
3. **Web**: Configure in `web/index.html`

Firebase options generated at: `lib/firebase_options.dart`

### Environment Variables

All sensitive configuration in `.env`:

```env
# RapidAPI (Required)
RAPIDAPI_KEY=your_rapidapi_key
RAPIDAPI_HOST=rto-vehicle-information-india.p.rapidapi.com

# Vahan API (Optional)
VAHAN_JWT_TOKEN=your_jwt_token
VAHAN_SUBID=your_subscription_id

# Admin
ADMIN_EMAIL=your_email@example.com
```

## 🎯 Key Features Explained

### 1. RTO Vehicle Verification

**How it works:**
1. User enters vehicle registration number (e.g., MH12AB1234)
2. App validates format (2 letters + 2 digits + 1-2 letters + 4 digits)
3. Makes API request to RapidAPI RTO service
4. Displays comprehensive vehicle information

**Data Retrieved:**
- Registration Number (RC)
- VIN/Chassis Number (masked)
- Engine Number (masked)
- Maker & Model
- Fuel Type
- Tax Status & Validity
- RC Valid Till
- Fitness Status & Validity
- Blacklist Status
- Lien/Hypothecation Details
  - Status (Active/Clear)
  - Bank/Financer name
  - Active period

**Error Handling:**
- Invalid format detection
- Vehicle not found
- Network errors with retry mechanism
- Rate limit handling
- User-friendly error messages

### 2. Smart Inspection Checklist

**Database Structure (Firestore):**
```
vehicles/
  └── {makeModelYear}/
      └── knownIssues/
          └── {issueId}/
              ├── issue: string
              ├── severity: "Low" | "Medium" | "High"
              ├── estimatedCost: number
              └── category: string
```

**Checklist Flow:**
1. User selects: Make (e.g., "Maruti") → Model (e.g., "Swift") → Year (e.g., "2015")
2. App queries Firestore for matching vehicle
3. Loads 10-15 known issues specific to that variant
4. Displays interactive checklist with checkboxes (initially all unchecked)
5. User **checks items if issues are found** during inspection
6. Real-time score calculation on each toggle
7. Color-coded risk assessment (0-49 Green, 50-79 Yellow, 80-100 Red)

**Scoring Algorithm:**
```dart
double calculateScore({
  required List<ChecklistItem> items,
  required Map<String, bool> selections,
}) {
  double totalWeight = 0.0;
  double checkedWeight = 0.0;

  for (var item in items) {
    final weight = calculateWeight(item);
    totalWeight += weight;
    
    if (selections[item.issue] == true) { // Issue found/checked
      checkedWeight += weight;
    }
  }

  // Calculate percentage based on weighted severity
  final weightedScore = (checkedWeight / totalWeight) * 100;
  return weightedScore.clamp(0.0, 100.0);
}

double calculateWeight(ChecklistItem item) {
  double severityWeight;
  switch (item.severity) {
    case 'High':   severityWeight = 10.0; break;
    case 'Medium': severityWeight = 5.0;  break;
    case 'Low':    severityWeight = 2.0;  break;
  }
  return severityWeight + (item.estimatedCost / 10000);
}
```

### 3. OCR Document Processing

**Supported Documents:**
- Service Invoices
- Registration Certificates (RC)
- Insurance Documents
- Pollution Certificates
- Service History

**OCR Capabilities:**
- Text extraction using Google ML Kit
- Date detection and parsing
- Amount/cost extraction
- Vehicle plate number detection
- Odometer reading extraction
- Document type classification
- Confidence scoring

**Usage:**
```dart
final ocrService = OCRService();
final image = await ImagePicker().pickImage(source: ImageSource.camera);
final extractedText = await ocrService.extractTextFromImage(image!.path);
final structuredData = ocrService.extractStructuredData(extractedText);
```

## 🚨 Error Handling

CarCheckMate implements comprehensive error handling across all layers:

### Exception Hierarchy

```
Exception
├── RTOException (base for all RTO errors)
│   ├── InvalidVehicleNumberException
│   ├── VehicleNumberNotFoundException
│   ├── VehicleNumberFormatException
│   ├── RTOAPIException
│   ├── RTOAPITimeoutException
│   ├── RTOAPIRateLimitException
│   ├── RTODataNotFoundException
│   └── GenericRTOException
│
└── NetworkException
    ├── NoInternetConnectionException
    ├── ConnectionTimeoutException
    └── ConnectionRefusedException
```

### Failure Classes

```
Failure (abstract)
├── ServerFailure
├── NetworkFailure
└── ValidationFailure
```

### Error Messages

All exceptions provide user-friendly messages:
- ✅ "Invalid vehicle registration number format. Please check and try again."
- ✅ "Vehicle registration number not found in RTO database."
- ✅ "RTO service is currently unavailable. Please try again later."
- ✅ "No internet connection. Please check your network."

## 📊 Performance Optimization

### Network Layer
- ✅ Request retry with exponential backoff (max 2 retries)
- ✅ 15-second connection timeout
- ✅ Proper error handling and user feedback
- ✅ Request/response logging for debugging

### UI/UX
- ✅ Loading states for all async operations
- ✅ Skeleton screens during data fetch
- ✅ Debouncing for search inputs
- ✅ Lazy loading for lists
- ✅ Cached network images

### Database
- ✅ Firestore indexes for fast queries
- ✅ Pagination for large datasets
- ✅ Offline persistence enabled

## 🔐 Security

### API Keys
- ✅ Environment variables (`.env`) for sensitive data
- ✅ `.gitignore` configured to exclude `.env`
- ✅ API keys never hardcoded in source

### Firebase
- ✅ Firebase Security Rules configured
- ✅ Authentication required for database access
- ✅ User-specific data isolation

### Data Privacy
- ✅ No sensitive vehicle data stored locally
- ✅ Temporary caching with automatic cleanup
- ✅ User consent for data processing

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Run `flutter analyze` before committing
- Maintain test coverage above 70%
- Write clear commit messages

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Mugilan**
- Email: mugilanmugil29@gmail.com
- GitHub: [@Mugil-an](https://github.com/Mugil-an)

## � Acknowledgments

- **RapidAPI** - Vehicle verification API
- **Firebase** - Backend infrastructure
- **Google ML Kit** - OCR capabilities
- **Flutter Team** - Amazing framework
- **Open Source Community** - Various packages used

## 📞 Support

For support, email mugilanmugil29@gmail.com or create an issue on GitHub.

## 🗺️ Roadmap

### Planned Features

- [ ] **Challan/Fine History** - Check traffic violations
- [ ] **Insurance Verification** - Validate policy status
- [ ] **Price Recommendation** - ML-based price suggestions
- [ ] **Comparison Tool** - Compare multiple vehicles
- [ ] **Saved Inspections** - History of inspected vehicles
- [ ] **PDF Report Generation** - Export inspection reports
- [ ] **Push Notifications** - RC expiry alerts
- [ ] **Multi-language Support** - Hindi, Tamil, Telugu
- [ ] **Offline Mode** - Work without internet
- [ ] **Dark Mode** - Eye-friendly theme

### Future Enhancements

- Integration with more vehicle data APIs
- Advanced ML for image-based damage detection
- Marketplace integration for buying/selling
- Mechanic network for professional inspections
- Blockchain-based vehicle history

---

<div align="center">

**Made with ❤️ in India for car buyers**

[Report Bug](https://github.com/Mugil-an/carcheckmate/issues) · [Request Feature](https://github.com/Mugil-an/carcheckmate/issues) · [Documentation](https://github.com/Mugil-an/carcheckmate/wiki)

</div>
