import 'package:flutter/material.dart';
import '../../core.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                  SizedBox(width: 16),
                  Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
