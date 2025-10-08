import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Professional card widget with consistent styling
class ProfessionalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ProfessionalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevated = true,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: backgroundColor != null 
            ? null 
            : AppColors.cardGradient,
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: elevated ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: cardContent,
    );
  }
}

/// Professional action button with gradient background
class ProfessionalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final Size? minimumSize;

  const ProfessionalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                  ),
                )
              : icon != null 
                  ? Icon(icon) 
                  : const SizedBox.shrink(),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: minimumSize ?? const Size(double.infinity, 56),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              )
            : icon != null 
                ? Icon(icon) 
                : const SizedBox.shrink(),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          minimumSize: minimumSize ?? const Size(double.infinity, 56),
        ),
      );
    }
  }
}

/// Professional text field with enhanced styling
class ProfessionalTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const ProfessionalTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText ?? labelText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null 
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconTap,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// Professional info card with icon and content
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.accent).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
        ],
      ),
    );
  }
}