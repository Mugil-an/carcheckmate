// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/service_locator.dart' as di;
import 'app/app.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/checklist/checklist_bloc.dart';
import 'logic/vehicle_verification/vehicle_verification_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp();
  await di.configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<ChecklistBloc>(create: (_) => di.sl<ChecklistBloc>()),
        BlocProvider<VehicleVerificationBloc>(create: (_) => di.sl<VehicleVerificationBloc>()),
      ],
      child: const App(),
    );
  }
}