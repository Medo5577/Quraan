import 'package:flutter/material.dart';
import '../../../core.dart';

class LastReadCard extends StatelessWidget {
  const LastReadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Read', style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 4),
              Text('Al-Fatiha', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54),
        ],
      ),
    );
  }
}
