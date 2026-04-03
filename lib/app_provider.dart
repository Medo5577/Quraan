import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models.dart';

class AppProvider with ChangeNotifier {
  // Loading states
  bool isLoading = false;
  bool isSurahLoading = false;
  bool isAudioLoading = false;
  bool isOffline = false;

  // Surah data
  List<Surah> surahs = [];
  List<Surah> filteredSurahs = [];
  Surah? currentSurah;
  List<Ayah> currentSurahVerses = [];

  // Adhkar data
  List<AdhkarCategory> adhkarCategories = [];
  AdhkarCategory? currentAdhkarCategory;

  // Radio & Video data
  List<RadioStation> radios = [];
  List<LiveTvStation> liveTvStations = [];
  List<VideoItem> videos = [];
  List<VideoType> videoTypes = [];
  String currentVideoFilter = 'all';

  // Prayer & Location
  PrayerTimes? prayerTimes;
  Placemark? placemark;
  double? qiblaDirection;
  Position? currentPosition;
  String currentCityName = 'Your Location';

  // Audio System
  final AudioPlayer audioPlayer = AudioPlayer();
  AudioType currentAudioType = AudioType.none;
  AudioSourceInfo? currentAudioSourceInfo;
  bool audioIsPlaying = false;
  int audioPlayingVerse = 1;
  List<VerseTiming> audioVerseTimings = [];
  AudioRepeatMode audioRepeatMode = AudioRepeatMode.autoAdvance;

  // Bookmarks
  List<Bookmark> bookmarks = [];

  // Last Read
  LastRead? lastRead;
  LastReadMarker? lastReadMarker;

  // Khatmah Goal
  KhatmahGoal? khatmahGoal;

  // Settings
  AppSettings settings = AppSettings();

  // Available editions
  List<Edition> availableTranslations = [];
  List<Edition> availableTafsirs = [];
  List<Reciter> availableReciters = [];

  // Language
  String currentLang = 'ar';

  // Offline Mode
  OfflineStatus offlineStatus = OfflineStatus();
  double offlineDbSize = 0;
  double audioDbSize = 0;
  DownloadProgress downloadProgress = DownloadProgress();
  // Connectivity
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  // Timers
  Timer? prayerTimesTimer;

  AppProvider() {
    init();
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await _loadSettings();
    await _loadBookmarks();
    await _loadLastRead();
    await _loadLastReadMarker();
    await _loadKhatmahGoal();
    await _loadOfflineStatus();
    await _initConnectivity();
    await _loadSurahs();
    await loadAdhkar();
    await _loadRadios();
    await _loadReciters();
    await _loadEditions();
    await fetchLocation();

    isLoading = false;
    notifyListeners();
  }

  // ==================== SETTINGS ====================
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      try {
        settings = AppSettings.fromJson(json.decode(settingsJson));
        currentLang = settings.language;
      } catch (e) {
        if (kDebugMode) print('Error loading settings: $e');
      }
    }
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', json.encode(settings.toJson()));
    notifyListeners();
  }

  void updateTheme(String theme) {
    settings = settings.copyWith(theme: theme);
    saveSettings();
  }

  void updateFontSize(double size) {
    settings = settings.copyWith(fontSize: size);
    saveSettings();
  }

  void updateArabicFont(String font) {
    settings = settings.copyWith(arabicFont: font);
    saveSettings();
  }

  void updateLanguage(String lang) {
    currentLang = lang;
    settings = settings.copyWith(language: lang);
    saveSettings();
    notifyListeners();
  }

  void updateDisplayMode(String mode) {
    settings = settings.copyWith(displayMode: mode);
    saveSettings();
  }

  void updateShowTranslation(bool show) {
    settings = settings.copyWith(showTranslation: show);
    saveSettings();
  }

  void updateShowTafsir(bool show) {
    settings = settings.copyWith(showTafsir: show);
    saveSettings();
  }

  void updateSelectedTranslations(List<String> translations) {
    settings = settings.copyWith(selectedTranslations: translations);
    saveSettings();
  }

  void updateSelectedTafsirs(List<String> tafsirs) {
    settings = settings.copyWith(selectedTafsirs: tafsirs);
    saveSettings();
  }

  void updateReciter(String reciterId) {
    settings = settings.copyWith(reciterId: reciterId);
    saveSettings();
    notifyListeners();
  }

  // ==================== SURAH ====================
  Future<void> _loadSurahs() async {
    for (var i = 1; i <= 114; i++) {
      surahs.add(
        Surah(
          number: i,
          name: quran.getSurahNameArabic(i),
          englishName: quran.getSurahNameEnglish(i),
          revelationType: quran.getPlaceOfRevelation(i),
          versesCount: quran.getVerseCount(i),
          isBookmarked: bookmarks.any((b) => b.surah == i),
        ),
      );
    }
    filteredSurahs = surahs;
  }

  void searchSurahs(String query) {
    if (query.isEmpty) {
      filteredSurahs = surahs;
    } else {
      filteredSurahs = surahs.where((s) {
        final q = query.toLowerCase();
        return s.name.toLowerCase().contains(q) ||
            s.englishName.toLowerCase().contains(q) ||
            s.number.toString().contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void filterSurahs(String filter) {
    switch (filter) {
      case 'makki':
        filteredSurahs = surahs
            .where((s) => s.revelationType == 'Meccan')
            .toList();
        break;
      case 'madani':
        filteredSurahs = surahs
            .where((s) => s.revelationType == 'Medinan')
            .toList();
        break;
      case 'bookmarked':
        filteredSurahs = surahs.where((s) => s.isBookmarked).toList();
        break;
      default:
        filteredSurahs = surahs;
    }
    notifyListeners();
  }

  Future<void> loadSurah(int surahNumber, {int? startFromAyah}) async {
    isSurahLoading = true;
    currentSurah = surahs.firstWhere((s) => s.number == surahNumber);
    notifyListeners();

    try {
      currentSurahVerses = [];
      for (var i = 1; i <= currentSurah!.versesCount; i++) {
        final text = quran.getVerse(surahNumber, i, verseEndSymbol: true);
        currentSurahVerses.add(
          Ayah(numberInSurah: i, text: text, translations: {}, tafsirs: {}),
        );
      }

      // Load translations if enabled
      if (settings.showTranslation &&
          settings.selectedTranslations.isNotEmpty) {
        await _loadTranslations(surahNumber);
      }

      // Load tafsirs if enabled
      if (settings.showTafsir && settings.selectedTafsirs.isNotEmpty) {
        await _loadTafsirs(surahNumber);
      }

      saveLastRead(surahNumber, startFromAyah ?? 1);
    } catch (e) {
      if (kDebugMode) print('Error loading surah: $e');
    }

    isSurahLoading = false;
    notifyListeners();
  }

  Future<void> _loadTranslations(int surahNumber) async {
    for (final translationId in settings.selectedTranslations) {
      try {
        final url =
            'https://api.alquran.cloud/v1/surah/$surahNumber/$translationId';
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final ayahs = data['data']['ayahs'] as List;
          for (
            var i = 0;
            i < ayahs.length && i < currentSurahVerses.length;
            i++
          ) {
            currentSurahVerses[i].translations[translationId] =
                ayahs[i]['text'];
          }
        }
      } catch (e) {
        if (kDebugMode) print('Error loading translation $translationId: $e');
      }
    }
  }

  Future<void> _loadTafsirs(int surahNumber) async {
    for (final tafsirId in settings.selectedTafsirs) {
      try {
        final url = 'https://api.alquran.cloud/v1/surah/$surahNumber/$tafsirId';
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final ayahs = data['data']['ayahs'] as List;
          for (
            var i = 0;
            i < ayahs.length && i < currentSurahVerses.length;
            i++
          ) {
            currentSurahVerses[i].tafsirs[tafsirId] = ayahs[i]['text'];
          }
        }
      } catch (e) {
        if (kDebugMode) print('Error loading tafsir $tafsirId: $e');
      }
    }
  }

  // ==================== ADHKAR ====================
  Future<void> loadAdhkar() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://raw.githubusercontent.com/rn0x/Adhkar-json/main/adhkar.json',
            ),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        adhkarCategories = (data as List)
            .map((e) => AdhkarCategory.fromJson(e))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading adhkar: $e');
    }
  }

  void openAdhkarCategory(int categoryId) {
    currentAdhkarCategory = adhkarCategories.firstWhere(
      (c) => c.id == categoryId,
    );
    notifyListeners();
  }

  // ==================== RADIO & VIDEO ====================
  Future<void> _loadRadios() async {
    try {
      final lang = currentLang == 'ar' ? 'ar' : 'eng';
      final response = await http
          .get(Uri.parse('https://mp3quran.net/api/v3/radios?language=$lang'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        radios = (data['radios'] as List)
            .map((e) => RadioStation.fromJson(e))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading radios: $e');
      // Fallback radios
      radios = [
        RadioStation(
          name: 'إذاعة القرآن الكريم',
          url: 'https://n0e.radiojar.com/4wqre23fytzuv',
        ),
        RadioStation(
          name: 'إذاعة السنة النبوية',
          url: 'https://live.mp3quran.net:9982/;',
        ),
      ];
    }
  }

  Future<void> loadLiveTv() async {
    try {
      final lang = currentLang == 'ar' ? 'ar' : 'eng';
      final response = await http
          .get(Uri.parse('https://mp3quran.net/api/v3/live-tv?language=$lang'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        liveTvStations = (data['livetv'] as List)
            .map((e) => LiveTvStation.fromJson(e))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading live TV: $e');
    }
    notifyListeners();
  }

  Future<void> loadVideoTypes() async {
    try {
      final lang = currentLang == 'ar' ? 'ar' : 'eng';
      final response = await http
          .get(
            Uri.parse('https://mp3quran.net/api/v3/video_types?language=$lang'),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        videoTypes = (data['video_types'] as List)
            .map((e) => VideoType.fromJson(e))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading video types: $e');
    }
    notifyListeners();
  }

  Future<void> loadVideos() async {
    try {
      final lang = currentLang == 'ar' ? 'ar' : 'eng';
      final response = await http
          .get(Uri.parse('https://mp3quran.net/api/v3/videos?language=$lang'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        videos = [];
        if (data['videos'] != null) {
          for (var group in data['videos']) {
            for (var video in group['videos']) {
              videos.add(
                VideoItem.fromJson({
                  ...video,
                  'reciter_name': group['reciter_name'],
                }),
              );
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading videos: $e');
    }
    notifyListeners();
  }

  void filterVideos(String filter) {
    currentVideoFilter = filter;
    notifyListeners();
  }

  List<VideoItem> get filteredVideos {
    if (currentVideoFilter == 'all') return videos;
    return videos.where((v) => v.videoType == currentVideoFilter).toList();
  }

  // ==================== RECITERS ====================
  Future<void> _loadReciters() async {
    try {
      final lang = currentLang == 'ar' ? 'ar' : 'eng';
      final response = await http
          .get(Uri.parse('https://mp3quran.net/api/v3/reciters?language=$lang'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        availableReciters = (data['reciters'] as List)
            .map((e) => Reciter.fromJson(e))
            .where((r) => r.server != null && r.surahList.isNotEmpty)
            .toList();

        if (availableReciters.isNotEmpty &&
            !availableReciters.any((r) => r.id == settings.reciterId)) {
          settings = settings.copyWith(reciterId: availableReciters.first.id);
          saveSettings();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading reciters: $e');
    }
  }

  // ==================== EDITIONS ====================
  Future<void> _loadEditions() async {
    try {
      final responses = await Future.wait([
        http
            .get(
              Uri.parse(
                'https://api.alquran.cloud/v1/edition?format=text&type=translation',
              ),
            )
            .timeout(const Duration(seconds: 15)),
        http
            .get(
              Uri.parse(
                'https://api.alquran.cloud/v1/edition?format=text&type=tafsir',
              ),
            )
            .timeout(const Duration(seconds: 15)),
      ]);

      if (responses[0].statusCode == 200) {
        final data = json.decode(responses[0].body);
        availableTranslations = (data['data'] as List)
            .map((e) => Edition.fromJson(e))
            .toList();
      }

      if (responses[1].statusCode == 200) {
        final data = json.decode(responses[1].body);
        availableTafsirs = (data['data'] as List)
            .map((e) => Edition.fromJson(e))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading editions: $e');
    }
  }

  // ==================== AUDIO SYSTEM ====================
  double get audioDuration => audioPlayer.duration?.inSeconds.toDouble() ?? 0;
  double get audioCurrentTime => audioPlayer.position.inSeconds.toDouble();

  Future<void> seekTo(double seconds) async {
    await audioPlayer.seek(Duration(seconds: seconds.toInt()));
  }

  Future<void> seekToVerse(int verseNumber) async {
    if (audioVerseTimings.isEmpty ||
        verseNumber < 1 ||
        verseNumber > audioVerseTimings.length) {
      return;
    }
    final timing = audioVerseTimings[verseNumber - 1];
    await audioPlayer.seek(timing.start);
    audioPlayingVerse = verseNumber;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> playSurah(int surahNumber, {int startVerse = 1}) async {
    final surah = surahs.firstWhere((s) => s.number == surahNumber);
    currentSurah = surah;
    await initializeAudio(autoPlay: true, startVerse: startVerse);
  }

  Future<void> initializeAudio({
    bool autoPlay = false,
    int startVerse = 1,
  }) async {
    if (currentSurah == null) return;

    final reciter = availableReciters.firstWhere(
      (r) => r.id == settings.reciterId,
      orElse: () => Reciter(id: '', name: '', server: null, surahList: []),
    );

    if (reciter.server == null ||
        !reciter.surahList.contains(currentSurah!.number)) {
      return;
    }

    isAudioLoading = true;
    notifyListeners();

    try {
      final url =
          '${reciter.server}${currentSurah!.number.toString().padLeft(3, '0')}.mp3';
      currentAudioSourceInfo = AudioSourceInfo(
        id: currentSurah!.number,
        url: url,
      );
      currentAudioType = AudioType.surah;
      audioPlayingVerse = startVerse;

      await audioPlayer.setUrl(url);
      _calculateVerseTimings();

      if (autoPlay) {
        await audioPlayer.play();
      }
    } catch (e) {
      if (kDebugMode) print('Error initializing audio: $e');
    }

    isAudioLoading = false;
    notifyListeners();
  }

  void _calculateVerseTimings() {
    if (currentSurahVerses.isEmpty || audioPlayer.duration == null) return;

    final totalChars = currentSurahVerses.fold<int>(
      0,
      (sum, v) => sum + v.text.length,
    );
    double cumulativeTime = 0;

    audioVerseTimings = currentSurahVerses.map((v) {
      final charRatio = v.text.length / totalChars;
      final estimatedTime = charRatio * audioPlayer.duration!.inMilliseconds;
      final timing = VerseTiming(
        start: Duration(milliseconds: cumulativeTime.round()),
        end: Duration(milliseconds: (cumulativeTime + estimatedTime).round()),
      );
      cumulativeTime += estimatedTime;
      return timing;
    }).toList();
  }

  Future<void> playRadio(RadioStation radio) async {
    currentAudioType = AudioType.radio;
    currentAudioSourceInfo = AudioSourceInfo(
      id: 0,
      url: radio.url,
      name: radio.name,
    );
    isAudioLoading = true;
    notifyListeners();

    try {
      await audioPlayer.setUrl(radio.url);
      await audioPlayer.play();
    } catch (e) {
      if (kDebugMode) print('Error playing radio: $e');
    }

    isAudioLoading = false;
    notifyListeners();
  }

  Future<void> playAdhkarAudio(String audioPath, int adhkarId) async {
    final url = 'https://www.hisnmuslim.com$audioPath';
    currentAudioType = AudioType.adhkar;
    currentAudioSourceInfo = AudioSourceInfo(id: adhkarId, url: url);
    isAudioLoading = true;
    notifyListeners();

    try {
      await audioPlayer.setUrl(url);
      await audioPlayer.play();
    } catch (e) {
      if (kDebugMode) print('Error playing adhkar audio: $e');
    }

    isAudioLoading = false;
    notifyListeners();
  }

  Future<void> toggleAudio() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
    notifyListeners();
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    currentAudioType = AudioType.none;
    currentAudioSourceInfo = null;
    audioPlayingVerse = 1;
    notifyListeners();
  }

  void handleAudioEnd() {
    if (currentAudioType != AudioType.surah) return;

    switch (audioRepeatMode) {
      case AudioRepeatMode.surah:
        audioPlayer.seek(Duration.zero);
        audioPlayer.play();
        break;
      case AudioRepeatMode.autoAdvance:
        if (currentSurah != null && currentSurah!.number < 114) {
          loadSurah(currentSurah!.number + 1, startFromAyah: 1).then((_) {
            initializeAudio(autoPlay: true);
          });
        } else {
          stopAudio();
        }
        break;
      default:
        audioPlayer.seek(Duration.zero);
    }
  }

  void setAudioRepeatMode(AudioRepeatMode mode) {
    audioRepeatMode = mode;
    notifyListeners();
  }

  // ==================== BOOKMARKS ====================
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getString('bookmarks');
    if (bookmarksJson != null) {
      try {
        final List<dynamic> decoded = json.decode(bookmarksJson);
        bookmarks = decoded.map((e) => Bookmark.fromJson(e)).toList();
      } catch (e) {
        if (kDebugMode) print('Error loading bookmarks: $e');
      }
    }
  }

  Future<void> saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'bookmarks',
      json.encode(bookmarks.map((b) => b.toJson()).toList()),
    );
  }

  void toggleBookmark(int surah, int ayah) {
    final existing = bookmarks.indexWhere(
      (b) => b.surah == surah && b.ayah == ayah,
    );
    if (existing >= 0) {
      bookmarks.removeAt(existing);
    } else {
      bookmarks.add(
        Bookmark(
          surah: surah,
          ayah: ayah,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    // Update surah bookmark status
    final surahIndex = surahs.indexWhere((s) => s.number == surah);
    if (surahIndex >= 0) {
      surahs[surahIndex] = surahs[surahIndex].copyWith(
        isBookmarked: bookmarks.any((b) => b.surah == surah),
      );
    }

    saveBookmarks();
    notifyListeners();
  }

  bool isBookmarked(int surah, int ayah) {
    return bookmarks.any((b) => b.surah == surah && b.ayah == ayah);
  }

  // ==================== LAST READ ====================
  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadJson = prefs.getString('last_read');
    if (lastReadJson != null) {
      try {
        lastRead = LastRead.fromJson(json.decode(lastReadJson));
      } catch (e) {
        if (kDebugMode) print('Error loading last read: $e');
      }
    }
  }

  Future<void> saveLastRead(int surah, int ayah) async {
    lastRead = LastRead(
      surah: surah,
      ayah: ayah,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read', json.encode(lastRead!.toJson()));
    notifyListeners();
  }

  // ==================== LAST READ MARKER ====================
  Future<void> _loadLastReadMarker() async {
    final prefs = await SharedPreferences.getInstance();
    final markerJson = prefs.getString('last_read_marker');
    if (markerJson != null) {
      try {
        lastReadMarker = LastReadMarker.fromJson(json.decode(markerJson));
      } catch (e) {
        if (kDebugMode) print('Error loading last read marker: $e');
      }
    }
  }

  Future<void> saveLastReadMarker() async {
    final prefs = await SharedPreferences.getInstance();
    if (lastReadMarker != null) {
      await prefs.setString(
        'last_read_marker',
        json.encode(lastReadMarker!.toJson()),
      );
    } else {
      await prefs.remove('last_read_marker');
    }
    notifyListeners();
  }

  void setLastReadMarker(int surah, int ayah) {
    if (lastReadMarker != null &&
        lastReadMarker!.surah == surah &&
        lastReadMarker!.ayah == ayah) {
      lastReadMarker = null;
    } else {
      lastReadMarker = LastReadMarker(
        surah: surah,
        ayah: ayah,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
    saveLastReadMarker();
  }

  // ==================== KHATMAH GOAL ====================
  Future<void> _loadKhatmahGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final goalJson = prefs.getString('khatmah_goal');
    if (goalJson != null) {
      try {
        khatmahGoal = KhatmahGoal.fromJson(json.decode(goalJson));
      } catch (e) {
        if (kDebugMode) print('Error loading khatmah goal: $e');
      }
    }
  }

  Future<void> saveKhatmahGoal() async {
    final prefs = await SharedPreferences.getInstance();
    if (khatmahGoal != null) {
      await prefs.setString('khatmah_goal', json.encode(khatmahGoal!.toJson()));
    } else {
      await prefs.remove('khatmah_goal');
    }
    notifyListeners();
  }

  void setKhatmahGoal(KhatmahGoal goal) {
    khatmahGoal = goal;
    saveKhatmahGoal();
  }

  void deleteKhatmahGoal() {
    khatmahGoal = null;
    lastReadMarker = null;
    saveKhatmahGoal();
    saveLastReadMarker();
  }

  double get khatmahProgress {
    if (khatmahGoal == null) return 0;
    if (lastReadMarker == null) return 0;

    int totalUnits, completedUnits;
    if (khatmahGoal!.type == 'surah') {
      totalUnits = khatmahGoal!.end - khatmahGoal!.start + 1;
      completedUnits = lastReadMarker!.surah - khatmahGoal!.start;
    } else {
      totalUnits = khatmahGoal!.end - khatmahGoal!.start + 1;
      completedUnits =
          _getPageFromSurahAyah(lastReadMarker!.surah, lastReadMarker!.ayah) -
          khatmahGoal!.start;
    }

    return totalUnits > 0
        ? (completedUnits / totalUnits * 100).clamp(0, 100)
        : 0;
  }

  int _getPageFromSurahAyah(int surah, int ayah) {
    // Simplified page calculation - in real app, use proper page mapping
    return ((surah - 1) * 5 + (ayah / 10).ceil()).clamp(1, 604);
  }

  // ==================== PRAYER & LOCATION ====================
  Future<void> fetchLocation() async {
    try {
      Position position = await _determinePosition();
      currentPosition = position;

      final myCoordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      prayerTimes = PrayerTimes.today(myCoordinates, params);

      final qibla = Qibla(myCoordinates);
      qiblaDirection = qibla.direction;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        placemark = placemarks.first;
        currentCityName =
            placemark?.locality ??
            placemark?.administrativeArea ??
            'Your Location';
      }

      _startPrayerTimesTimer();
    } catch (e) {
      if (kDebugMode) print("Error loading location data: $e");
      // Default to Cairo
      final myCoordinates = Coordinates(30.0444, 31.2357);
      final params = CalculationMethod.muslim_world_league.getParameters();
      prayerTimes = PrayerTimes.today(myCoordinates, params);
      final qibla = Qibla(myCoordinates);
      qiblaDirection = qibla.direction;
      currentCityName = 'Cairo';
    }
    notifyListeners();
  }

  void _startPrayerTimesTimer() {
    prayerTimesTimer?.cancel();
    prayerTimesTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (currentPosition != null) {
        final myCoordinates = Coordinates(
          currentPosition!.latitude,
          currentPosition!.longitude,
        );
        final params = CalculationMethod.muslim_world_league.getParameters();
        prayerTimes = PrayerTimes.today(myCoordinates, params);
        notifyListeners();
      }
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // ==================== CLEANUP ====================
  @override
  void dispose() {
    prayerTimesTimer?.cancel();
    audioPlayer.dispose();
    connectivitySubscription?.cancel();
    super.dispose();
  }

  // ==================== OFFLINE MODE ====================
  Future<void> _initConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivity(connectivityResult);
    
    connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectivity);
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      isOffline = true;
    } else {
      isOffline = false;
    }
    notifyListeners();
  }

  Future<void> startTextDownload() async {
    if (offlineStatus.textDownloaded || downloadProgress.active) return;
    
    downloadProgress = DownloadProgress(totalItems: 114, downloadedItems: 0, active: true);
    notifyListeners();

    try {
      // Download Quran text
      for (int i = 1; i <= 114; i++) {
        // Simulate download - in real app, store in database
        await Future.delayed(const Duration(milliseconds: 100));
        downloadProgress.downloadedItems = i;
        notifyListeners();
      }
      
      offlineStatus.textDownloaded = true;
      offlineStatus.textDbSize = 2.5; // MB estimate
      _saveOfflineStatus();
    } catch (e) {
      if (kDebugMode) print('Download error: $e');
    } finally {
      downloadProgress.active = false;
      notifyListeners();
    }
  }

  Future<void> _loadOfflineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('offline_status');
    if (json != null) {
      try {
        offlineStatus = OfflineStatus.fromJson(jsonDecode(json));
      } catch (e) {}
    }
  }

  Future<void> _saveOfflineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('offline_status', json.encode(offlineStatus.toJson()));
  }

  Future<void> clearOfflineData() async {
    offlineStatus = OfflineStatus();
    offlineDbSize = 0;
    audioDbSize = 0;
    await _saveOfflineStatus();
    notifyListeners();
  }
}
