import 'package:flutter/material.dart';
import '../../../core.dart';

class SurahListTile extends StatelessWidget {
  final int number;
  final String name;
  final String englishName;
  final String revelationType;
  final int versesCount;
  final VoidCallback onTap;

  const SurahListTile({
    super.key,
    required this.number,
    required this.name,
    required this.englishName,
    required this.revelationType,
    required this.versesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(number.toString(), style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('$englishName | $versesCount verses', style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const Spacer(),
            Text(revelationType, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
