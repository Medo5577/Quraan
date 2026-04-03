import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'home/home_page.dart';
import 'quran/quran_page.dart';
import 'adhkar/adhkar_page.dart';
import 'radio/radio_page.dart';
import 'video/video_page.dart';
import 'prayers/prayers_page.dart';
import 'more/more_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const QuranPage(),
    const AdhkarPage(),
    const RadioPage(),
    const VideoPage(),
    const PrayersPage(),
    const MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      extendBody: true,
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cardGlass.withAlpha((255 * 0.98).round()),
            AppColors.cardGlass.withAlpha((255 * 0.96).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.whiteGlass.withAlpha((255 * 0.55).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.9).round()),
            blurRadius: 45,
            offset: const Offset(0, -18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SizedBox(
            height: 64,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  activeIcon: Icon(Icons.book),
                  label: 'القرآن',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.spa_outlined),
                  activeIcon: Icon(Icons.spa),
                  label: 'الأذكار',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.radio_outlined),
                  activeIcon: Icon(Icons.radio),
                  label: 'الراديو',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library_outlined),
                  activeIcon: Icon(Icons.video_library),
                  label: 'الفيديو',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.mosque_outlined),
                  activeIcon: Icon(Icons.mosque),
                  label: 'الصلاة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz_outlined),
                  activeIcon: Icon(Icons.more_horiz),
                  label: 'المزيد',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
