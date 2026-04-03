import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SurahListTile extends StatelessWidget {
  final int number;
  final String name;
  final String englishName;
  final String revelationType;
  final int versesCount;
  final bool isBookmarked;

  const SurahListTile({
    super.key,
    required this.number,
    required this.name,
    required this.englishName,
    required this.revelationType,
    required this.versesCount,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          // Number Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppColors.success,
                  AppColors.secondary,
                  AppColors.info,
                  AppColors.accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.85).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isBookmarked) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.bookmark,
                        color: AppColors.accent,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  englishName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Verses Count and Type
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$versesCount آية',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                style: TextStyle(
                  fontSize: 10,
                  color: revelationType == 'Meccan'
                      ? AppColors.secondary
                      : AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
