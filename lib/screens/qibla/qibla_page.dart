import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_provider.dart';
import '../../core.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            AppColors.surface.withAlpha((255 * 0.65).round()),
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Compass Title
              const Text(
                'اتجاه القبة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),

              // Qibla Compass
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.secondary.withAlpha((255 * 0.2).round()),
                      AppColors.surface,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.secondary.withAlpha((255 * 0.8).round()),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withAlpha((255 * 0.5).round()),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass decoration
                    ...List.generate(12, (index) {
                      return Transform.rotate(
                        angle: index * 30 * math.pi / 180,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 2,
                            height: index % 3 == 0 ? 15 : 10,
                            color: AppColors.textSecondary.withAlpha((255 * 0.6).round()),
                          ),
                        ),
                      );
                    }),
                    // Qibla Arrow
                    if (provider.qiblaDirection != null)
                      Transform.rotate(
                        angle: (provider.qiblaDirection! * math.pi / 180) * -1,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: CustomPaint(
                            painter: _QiblaNeedlePainter(),
                          ),
                        ),
                      )
                    else
                      const CircularProgressIndicator(color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Direction Value
              Text(
                provider.qiblaDirection != null
                    ? '${provider.qiblaDirection!.toStringAsFixed(1)}°'
                    : '---',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                provider.qiblaDirection != null ? _getDirectionName(provider.qiblaDirection!) : 'جاري الحساب...',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Info
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'الدقة تعتمد على حساسات الجهاز',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withAlpha((255 * 0.8).round()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDirectionName(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'شمال';
    if (degrees >= 22.5 && degrees < 67.5) return 'شمال شرق';
    if (degrees >= 67.5 && degrees < 112.5) return 'شرق';
    if (degrees >= 112.5 && degrees < 157.5) return 'جنوب شرق';
    if (degrees >= 157.5 && degrees < 202.5) return 'جنوب';
    if (degrees >= 202.5 && degrees < 247.5) return 'جنوب غرب';
    if (degrees >= 247.5 && degrees < 292.5) return 'غرب';
    if (degrees >= 292.5 && degrees < 337.5) return 'شمال غرب';
    return '';
  }
}

class _QiblaNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Upper part (Kaaba direction) - Blue/Cyan
    final upperPath = Path();
    upperPath.moveTo(size.width / 2, 0);
    upperPath.lineTo(size.width, size.height * 0.6);
    upperPath.lineTo(size.width / 2, size.height * 0.4);
    upperPath.lineTo(0, size.height * 0.6);
    upperPath.close();

    paint.color = AppColors.secondary;
    canvas.drawPath(upperPath, paint);

    // Lower part - White/Grey
    final lowerPath = Path();
    lowerPath.moveTo(size.width / 2, size.height * 0.4);
    lowerPath.lineTo(size.width, size.height * 0.6);
    lowerPath.lineTo(size.width / 2, size.height);
    lowerPath.lineTo(0, size.height * 0.6);
    lowerPath.close();

    paint.color = AppColors.textPrimary.withAlpha((255 * 0.6).round());
    canvas.drawPath(lowerPath, paint);

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      8,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
