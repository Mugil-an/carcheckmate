// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carcheckmate/logic/checklist/checklist_bloc.dart';
import 'package:carcheckmate/logic/auth/auth_bloc.dart';
import 'package:carcheckmate/logic/auth/auth_event.dart';
import '../../widgets/common_background.dart';
class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load cars for potential use in checklist
    context.read<ChecklistBloc>().add(LoadInitialData());
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(
          title: 'CarCheckMate',
        ),
        drawer: _buildDrawer(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 80,
                  child: Image.asset(
                    'assets/images/carcheckmate_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Car CheckMate',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Buy smarter. Verify faster.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'A landing page with your problem, solution, and process—plus links to each feature.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                
                // Action Buttons
                _buildActionButton(
                  context: context,
                  icon: Icons.checklist,
                  title: 'Start Checklist',
                  onTap: () => Navigator.pushNamed(context, '/checklist'),
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  context: context,
                  icon: Icons.upload_file,
                  title: 'Upload Service History (OCR)',
                  onTap: () => Navigator.pushNamed(context, '/ocr'),
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.transparent,
          foregroundColor: isPrimary ? const Color(0xFF2E3A59) : Colors.white,
          elevation: isPrimary ? 2 : 0,
          side: isPrimary ? null : const BorderSide(color: Colors.white, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A2332),
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF2E3A59),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_car, color: Colors.white, size: 40),
                SizedBox(width: 12),
                Text(
                  'Guest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.checklist,
            title: 'Checklist',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/checklist');
            },
          ),
          _buildDrawerItem(
            icon: Icons.upload_file,
            title: 'Upload OCR',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ocr');
            },
          ),
          _buildDrawerItem(
            icon: Icons.assignment,
            title: 'RTO / Lien',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/rto');
            },
          ),
          _buildDrawerItem(
            icon: Icons.security,
            title: 'Fraud Education',
            onTap: () {
              Navigator.pop(context);
              // Navigate to fraud education screen
            },
          ),
          _buildDrawerItem(
            icon: Icons.poll,
            title: 'Survey',
            onTap: () {
              Navigator.pop(context);
              // Navigate to survey screen
            },
          ),
          const Spacer(),
          _buildDrawerItem(
            icon: Icons.exit_to_app,
            title: 'Sign out',
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogout());
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
