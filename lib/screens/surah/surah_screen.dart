import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import '../../app_provider.dart';
import '../../core.dart';
import '../../models.dart';
import 'widgets/ayah_list_item.dart';

class SurahScreen extends StatefulWidget {
  final Surah surah;
  final int? startFromAyah;

  const SurahScreen({super.key, required this.surah, this.startFromAyah});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late final ScrollController _scrollController;
  int? _highlightedAyah;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.loadSurah(
        widget.surah.number,
        startFromAyah: widget.startFromAyah,
      );
      if (widget.startFromAyah != null && widget.startFromAyah! > 1) {
        _scrollToAyah(widget.startFromAyah!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToAyah(int ayahNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final itemHeight = 120.0;
        final offset = (ayahNumber - 1) * itemHeight;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.surah.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showReciterDialog(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio Controls
          _buildAudioControls(provider),
          // Verses List
          Expanded(
            child: provider.isSurahLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    itemCount: widget.surah.versesCount,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) {
                      final ayahNumber = i + 1;
                      final fullVerse = quran.getVerse(
                        widget.surah.number,
                        ayahNumber,
                        verseEndSymbol: true,
                      );
                      final isHighlighted = _highlightedAyah == ayahNumber;
                      final isPlaying =
                          provider.audioPlayingVerse == ayahNumber &&
                          provider.currentAudioType == AudioType.surah &&
                          provider.audioIsPlaying;

                      return AyahListItem(
                        ayah: fullVerse,
                        ayahNumber: ayahNumber,
                        surahNumber: widget.surah.number,
                        isHighlighted: isHighlighted,
                        isPlaying: isPlaying,
                        onLongPress: () => _showAyahOptions(
                          context,
                          provider,
                          ayahNumber,
                          fullVerse,
                        ),
                        onTap: () {
                          if (provider.audioIsPlaying) {
                            provider.seekToVerse(ayahNumber);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControls(AppProvider provider) {
    final isCurrentSurah =
        provider.currentAudioSourceInfo?.id == widget.surah.number;
    final isPlaying = provider.audioIsPlaying && isCurrentSurah;
    final isLoading = provider.isAudioLoading && isCurrentSurah;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Column(
        children: [
          // Progress Bar
          if (isCurrentSurah && provider.audioDuration > 0)
            Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.grey.shade700,
                    thumbColor: AppColors.primary,
                  ),
                  child: Slider(
                    value: provider.audioCurrentTime.clamp(
                      0,
                      provider.audioDuration,
                    ),
                    min: 0,
                    max: provider.audioDuration,
                    onChanged: (value) {
                      provider.seekTo(value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(
                          Duration(seconds: provider.audioCurrentTime.toInt()),
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(
                          Duration(seconds: provider.audioDuration.toInt()),
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous Verse
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 32),
                onPressed: isCurrentSurah && provider.audioPlayingVerse > 1
                    ? () => provider.seekToVerse(provider.audioPlayingVerse - 1)
                    : null,
                color: AppColors.primary,
              ),
              // Play/Pause
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                          color: Colors.white,
                        ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (isCurrentSurah) {
                            provider.togglePlayPause();
                          } else {
                            provider.playSurah(widget.surah.number);
                          }
                        },
                ),
              ),
              // Next Verse
              IconButton(
                icon: const Icon(Icons.skip_next, size: 32),
                onPressed:
                    isCurrentSurah &&
                        provider.audioPlayingVerse < widget.surah.versesCount
                    ? () => provider.seekToVerse(provider.audioPlayingVerse + 1)
                    : null,
                color: AppColors.primary,
              ),
              // Repeat Mode
              IconButton(
                icon: Icon(
                  provider.audioRepeatMode == AudioRepeatMode.surah
                      ? Icons.repeat_one
                      : provider.audioRepeatMode == AudioRepeatMode.autoAdvance
                      ? Icons.playlist_play
                      : Icons.repeat,
                  size: 28,
                ),
                onPressed: () => _showRepeatModeDialog(context, provider),
                color: provider.audioRepeatMode != AudioRepeatMode.none
                    ? AppColors.primary
                    : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  void _showReciterDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Select Reciter',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.availableReciters.length,
            itemBuilder: (context, index) {
              final reciter = provider.availableReciters[index];
              final isSelected = provider.settings.reciterId == reciter.id;
              return ListTile(
                title: Text(
                  reciter.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  provider.updateReciter(reciter.id);
                  Navigator.pop(context);
                  if (provider.audioIsPlaying) {
                    provider.playSurah(widget.surah.number);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRepeatModeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Repeat Mode', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRepeatOption(
              context,
              provider,
              AudioRepeatMode.none,
              'No Repeat',
              Icons.repeat,
            ),
            _buildRepeatOption(
              context,
              provider,
              AudioRepeatMode.surah,
              'Repeat Surah',
              Icons.repeat_one,
            ),
            _buildRepeatOption(
              context,
              provider,
              AudioRepeatMode.autoAdvance,
              'Auto Advance',
              Icons.playlist_play,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOption(
    BuildContext context,
    AppProvider provider,
    AudioRepeatMode mode,
    String title,
    IconData icon,
  ) {
    final isSelected = provider.audioRepeatMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? AppColors.primary : Colors.white),
      ),
      onTap: () {
        provider.setAudioRepeatMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showAyahOptions(
    BuildContext context,
    AppProvider provider,
    int ayahNumber,
    String ayahText,
  ) {
    final isBookmarked = provider.isBookmarked(widget.surah.number, ayahNumber);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: AppColors.primary),
              title: const Text(
                'Play from this verse',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                provider.playSurah(widget.surah.number, startVerse: ayahNumber);
              },
            ),
            ListTile(
              leading: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.primary,
              ),
              title: Text(
                isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                provider.toggleBookmark(widget.surah.number, ayahNumber);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.primary),
              title: const Text(
                'Copy Ayah',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Copy to clipboard
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primary),
              title: const Text(
                'Share Ayah',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Share functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
