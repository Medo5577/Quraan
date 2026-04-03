import 'package:flutter/material.dart';

class AyahListItem extends StatelessWidget {
  final String ayah;
  final int ayahNumber;
  final int surahNumber;
  final VoidCallback onLongPress;
  final bool isHighlighted;
  final bool isPlaying;
  final VoidCallback? onTap;

  const AyahListItem({
    super.key,
    required this.ayah,
    required this.ayahNumber,
    required this.surahNumber,
    required this.onLongPress,
    this.isHighlighted = false,
    this.isPlaying = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isHighlighted
              ? Colors.blue.withAlpha(50)
              : isPlaying
              ? Colors.green.withAlpha(50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isPlaying
                  ? Colors.green
                  : isHighlighted
                  ? Colors.blue
                  : Colors.white.withAlpha(25),
              child: Text(
                ayahNumber.toString(),
                style: TextStyle(
                  color: isPlaying || isHighlighted
                      ? Colors.white
                      : Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                ayah,
                style: TextStyle(
                  fontSize: 20,
                  color: isPlaying ? Colors.green : Colors.white,
                  height: 1.8,
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
