import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_provider.dart';
import '../../core.dart';
import '../surah/surah_screen.dart';
import 'widgets/surah_list_tile.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AppProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<AppProvider>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quran'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Surah'),
            Tab(text: 'Juz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSurahList(),
          _buildJuzList(),
        ],
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      itemCount: _provider.filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _provider.filteredSurahs[index];
        return SurahListTile(
          number: surah.number,
          name: surah.name,
          englishName: surah.englishName,
          revelationType: surah.revelationType,
          versesCount: surah.versesCount,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SurahScreen(surah: surah)),
            );
          },
        );
      },
    );
  }

  Widget _buildJuzList() {
    return const Center(
      child: Text('Juz list is not implemented yet.', style: TextStyle(color: Colors.white)),
    );
  }
}
