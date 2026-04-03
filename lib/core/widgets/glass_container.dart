import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final bool isDark;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 20;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.glassGradient1, AppColors.glassGradient2]
              : [
                  AppColors.glassGradient1.withAlpha(100),
                  Colors.white.withAlpha(240),
                ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? AppColors.whiteGlass.withAlpha((255 * 0.35).round())
              : Colors.grey.withAlpha((255 * 0.2).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.25).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final bool isPrimary;

  const GlassButton({
    super.key,
    this.onPressed,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 9999;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.accent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isPrimary
              ? null
              : AppColors.cardGlass.withAlpha((255 * 0.85).round()),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : AppColors.whiteGlass.withAlpha((255 * 0.6).round()),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppColors.secondary.withAlpha((255 * 0.4).round())
                  : Colors.black.withAlpha((255 * 0.2).round()),
              blurRadius: isPrimary ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.glassGradient1, AppColors.glassGradient2],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.whiteGlass.withAlpha((255 * 0.28).round()),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.15).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}
