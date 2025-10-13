// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carcheckmate/logic/checklist/checklist_bloc.dart';
import 'package:carcheckmate/logic/auth/auth_bloc.dart';
import 'package:carcheckmate/logic/auth/auth_event.dart';
import 'package:carcheckmate/logic/auth/auth_state.dart';
import '../../widgets/common_background.dart';
import '../../../app/theme.dart';
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
                  height: 120,
                  child: Image.asset(
                    'assets/images/carcheckmate_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car,
                      size: 120,
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
          backgroundColor: isPrimary ? Colors.white.withOpacity(0.95) : Colors.transparent,
          foregroundColor: isPrimary ? AppColors.primaryDark : Colors.white,
          elevation: isPrimary ? 4 : 0,
          shadowColor: isPrimary ? Colors.black26 : null,
          side: isPrimary ? null : BorderSide(color: AppColors.accentLightest, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryMedium,
      child: Column(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String username = 'Guest';
              String email = '';
              
              if (state is Authenticated) {
                username = state.user.displayName ?? 
                          state.user.email?.split('@').first ?? 
                          'User';
                email = state.user.email ?? '';
              }
              
              return DrawerHeader(
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state is Authenticated ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
              Navigator.pushNamed(context, '/fraud-awareness');
            },
          ),
          _buildDrawerItem(
            icon: Icons.poll,
            title: 'Survey & Feedback',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/survey');
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
