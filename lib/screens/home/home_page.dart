import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_provider.dart';
import '../../core.dart';
import 'widgets/surah_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentFilter = 'all';
  String _searchQuery = '';

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
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(child: _buildAppBar()),
            // Last Read Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildLastReadCard(),
              ),
            ),
            // Search and Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSearchInput(),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                  ],
                ),
              ),
            ),
            // Surah List
            if (provider.surahs.isNotEmpty)
              _buildSurahList(provider)
            else
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withAlpha((255 * 0.8).round()),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha((255 * 0.5).round()),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
              color: AppColors.surface.withAlpha((255 * 0.9).round()),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Title and Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.04,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.whiteGlass.withAlpha(
                          (255 * 0.45).round(),
                        ),
                        width: 1,
                      ),
                      color: AppColors.surface.withAlpha((255 * 0.85).round()),
                    ),
                    child: const Text(
                      'PRO • v1.9.2',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'تلاوة، تفسير، أذكار، راديو، بث مباشر',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          // Actions
          Row(
            children: [
              _buildIconButton(Icons.bookmark_outline),
              const SizedBox(width: 8),
              _buildIconButton(Icons.settings_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: AppColors.whiteGlass.withAlpha((255 * 0.6).round()),
          width: 1,
        ),
        color: AppColors.surface.withAlpha((255 * 0.8).round()),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 18),
    );
  }

  Widget _buildLastReadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withAlpha((255 * 0.12).round()),
            AppColors.primary.withAlpha((255 * 0.04).round()),
            AppColors.surface.withAlpha((255 * 0.9).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondary.withAlpha((255 * 0.65).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.9).round()),
            blurRadius: 45,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'آخر قراءة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'الفاتحة - الآية 1',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  color: AppColors.primary.withAlpha((255 * 0.2).round()),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.play_arrow, color: AppColors.primary, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'متابعة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.whiteGlass.withAlpha((255 * 0.2).round()),
            AppColors.surface.withAlpha((255 * 0.95).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: AppColors.whiteGlass.withAlpha((255 * 0.6).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.75).round()),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'ابحث في السور...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(180)),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'الكل', 'color': AppColors.success},
      {'key': 'makki', 'label': 'مكية', 'color': AppColors.secondary},
      {'key': 'madani', 'label': 'مدنية', 'color': AppColors.accent},
      {'key': 'bookmarked', 'label': 'المفضلة', 'color': AppColors.warning},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = _currentFilter == filter['key'];
          final color = filter['color'] as Color;

          return Padding(
            padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _currentFilter = filter['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            color.withAlpha((255 * 0.35).round()),
                            AppColors.secondary.withAlpha((255 * 0.05).round()),
                          ],
                        )
                      : null,
                  color: isActive
                      ? null
                      : AppColors.surface.withAlpha((255 * 0.75).round()),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: isActive
                        ? color
                        : AppColors.whiteGlass.withAlpha((255 * 0.75).round()),
                    width: 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: color.withAlpha((255 * 0.55).round()),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withAlpha((255 * 0.8).round()),
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha((255 * 0.8).round()),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurahList(AppProvider provider) {
    var filteredSurahs = provider.surahs.where((surah) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!surah.name.toLowerCase().contains(query) &&
            !surah.englishName.toLowerCase().contains(query) &&
            !surah.number.toString().contains(query)) {
          return false;
        }
      }

      // Apply category filter
      switch (_currentFilter) {
        case 'makki':
          return surah.revelationType == 'Meccan';
        case 'madani':
          return surah.revelationType == 'Medinan';
        case 'bookmarked':
          return surah.isBookmarked;
        default:
          return true;
      }
    }).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'السور',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    '${filteredSurahs.length} / ${provider.surahs.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final surah = filteredSurahs[index - 1];
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: SurahListTile(
              number: surah.number,
              name: surah.name,
              englishName: surah.englishName,
              revelationType: surah.revelationType,
              versesCount: surah.versesCount,
              isBookmarked: surah.isBookmarked,
            ),
          );
        }, childCount: filteredSurahs.length + 1),
      ),
    );
  }
}
