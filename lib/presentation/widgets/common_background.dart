import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Common background widget for consistent theming across all screens
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool hasAppBar;

  const AppBackground({
    super.key,
    required this.child,
    this.hasAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Container(
        decoration: BoxDecoration(
          // Add subtle noise/texture overlay for professional look
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.02),
              Colors.transparent,
              Colors.black.withOpacity(0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Common app bar for consistent styling
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool hasBackButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.hasBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      actions: actions,
      automaticallyImplyLeading: hasBackButton,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}