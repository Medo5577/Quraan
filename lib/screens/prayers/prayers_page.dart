import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_provider.dart';
import '../../core.dart';

class PrayersPage extends StatefulWidget {
  const PrayersPage({super.key});

  @override
  State<PrayersPage> createState() => _PrayersPageState();
}

class _PrayersPageState extends State<PrayersPage> {
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
            AppColors.background,
          ],
          stops: const [0.0, 0.48, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'أوقات الصلاة والقبلة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Location Card
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.secondary.withAlpha(
                          (255 * 0.2).round(),
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.currentCityName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'موقعك الحالي',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => provider.fetchLocation(),
                      icon: const Icon(
                        Icons.sync,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Prayer Times
              if (provider.prayerTimes != null) ...[
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPrayerTime(
                        'الفجر',
                        provider.prayerTimes!.fajr.format(context),
                        Icons.wb_twilight,
                        AppColors.info,
                        isNext: _isNextPrayer('Fajr', provider),
                      ),
                      _buildPrayerTime(
                        'الشروق',
                        provider.prayerTimes!.sunrise.format(context),
                        Icons.wb_sunny,
                        AppColors.warning,
                        isNext: _isNextPrayer('Sunrise', provider),
                      ),
                      _buildPrayerTime(
                        'الظهر',
                        provider.prayerTimes!.dhuhr.format(context),
                        Icons.wb_sunny_outlined,
                        AppColors.primary,
                        isNext: _isNextPrayer('Dhuhr', provider),
                      ),
                      _buildPrayerTime(
                        'العصر',
                        provider.prayerTimes!.asr.format(context),
                        Icons.wb_twilight,
                        AppColors.accent,
                        isNext: _isNextPrayer('Asr', provider),
                      ),
                      _buildPrayerTime(
                        'المغرب',
                        provider.prayerTimes!.maghrib.format(context),
                        Icons.nights_stay,
                        AppColors.secondary,
                        isNext: _isNextPrayer('Maghrib', provider),
                      ),
                      _buildPrayerTime(
                        'العشاء',
                        provider.prayerTimes!.isha.format(context),
                        Icons.nightlight_round,
                        AppColors.info,
                        isNext: _isNextPrayer('Isha', provider),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                GlassContainer(
                  padding: const EdgeInsets.all(32),
                  child: const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل الأوقات...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Qibla Direction
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.explore,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'اتجاه القبلة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Compass
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Compass Circle
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.whiteGlass.withAlpha(
                                    (255 * 0.6).round(),
                                  ),
                                  width: 2,
                                ),
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.surface.withAlpha(
                                      (255 * 0.3).round(),
                                    ),
                                    AppColors.background,
                                  ],
                                ),
                              ),
                            ),
                            // Direction Arrow
                            if (provider.qiblaDirection != null)
                              Transform.rotate(
                                angle:
                                    (provider.qiblaDirection! * math.pi / 180) *
                                    -1,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: CustomPaint(
                                    painter: QiblaArrowPainter(),
                                  ),
                                ),
                              )
                            else
                              const CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.qiblaDirection != null
                          ? '${provider.qiblaDirection!.toStringAsFixed(1)}°'
                          : '---',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '(الدقة تعتمد على حساسات الجهاز)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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

  Widget _buildPrayerTime(
    String name,
    String time,
    IconData icon,
    Color color, {
    bool isNext = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isNext
            ? color.withAlpha((255 * 0.15).round())
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext
              ? color
              : AppColors.whiteGlass.withAlpha((255 * 0.1).round()),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withAlpha((255 * 0.2).round()),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                color: isNext ? color : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isNext ? color : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  bool _isNextPrayer(String prayerName, AppProvider provider) {
    if (provider.prayerTimes == null) return false;
    final next = provider.prayerTimes!.nextPrayer();
    return next.toString().toLowerCase() == prayerName.toLowerCase();
  }
}

class QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height * 0.7);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension TimeExtension on DateTime {
  String format(BuildContext context) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
