class Surah {
  final int number;
  final String name;
  final String englishName;
  final String revelationType;
  final int versesCount;
  final bool isBookmarked;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.revelationType,
    required this.versesCount,
    this.isBookmarked = false,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      revelationType: json['revelationType'] == 'Meccan' ? 'Meccan' : 'Medinan',
      versesCount: json['numberOfAyahs'],
    );
  }

  Surah copyWith({bool? isBookmarked}) {
    return Surah(
      number: number,
      name: name,
      englishName: englishName,
      revelationType: revelationType,
      versesCount: versesCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class Ayah {
  final int numberInSurah;
  final String text;
  final Map<String, String> translations;
  final Map<String, String> tafsirs;

  Ayah({
    required this.numberInSurah,
    required this.text,
    this.translations = const {},
    this.tafsirs = const {},
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(numberInSurah: json['numberInSurah'], text: json['text']);
  }
}

class AdhkarCategory {
  final int id;
  final String category;
  final List<AdhkarItem> items;

  AdhkarCategory({
    required this.id,
    required this.category,
    required this.items,
  });

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) {
    return AdhkarCategory(
      id: json['id'],
      category: json['category'],
      items: (json['array'] as List)
          .map((e) => AdhkarItem.fromJson(e))
          .toList(),
    );
  }
}

class AdhkarItem {
  final int id;
  final String text;
  final String count;
  final String audio;
  final String filename;

  AdhkarItem({
    required this.id,
    required this.text,
    required this.count,
    required this.audio,
    required this.filename,
  });

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'],
      text: json['text'],
      count: json['count'],
      audio: json['audio'] ?? '',
      filename: json['filename'] ?? '',
    );
  }
}

class RadioStation {
  final String name;
  final String url;

  RadioStation({required this.name, required this.url});

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(name: json['name'], url: json['url']);
  }
}

class LiveTvStation {
  final String name;
  final String url;

  LiveTvStation({required this.name, required this.url});

  factory LiveTvStation.fromJson(Map<String, dynamic> json) {
    return LiveTvStation(name: json['name'], url: json['url']);
  }
}

class VideoType {
  final int id;
  final String videoType;

  VideoType({required this.id, required this.videoType});

  factory VideoType.fromJson(Map<String, dynamic> json) {
    return VideoType(id: json['id'], videoType: json['video_type']);
  }
}

class VideoItem {
  final String reciterName;
  final String videoUrl;
  final String videoThumbUrl;
  final String videoType;

  VideoItem({
    required this.reciterName,
    required this.videoUrl,
    required this.videoThumbUrl,
    required this.videoType,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      reciterName: json['reciter_name'] ?? '',
      videoUrl: json['video_url'] ?? '',
      videoThumbUrl: json['video_thumb_url'] ?? '',
      videoType: json['video_type'] ?? '',
    );
  }
}

class Reciter {
  final String id;
  final String name;
  final String? server;
  final List<int> surahList;

  Reciter({
    required this.id,
    required this.name,
    this.server,
    required this.surahList,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final moshaf = json['moshaf'] as List?;
    String? server;
    List<int> surahList = [];

    if (moshaf != null && moshaf.isNotEmpty) {
      server = moshaf[0]['server'];
      final surahListStr = moshaf[0]['surah_list'] as String?;
      if (surahListStr != null) {
        surahList = surahListStr
            .split(',')
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e > 0)
            .toList();
      }
    }

    return Reciter(
      id: json['id'].toString(),
      name: json['name'],
      server: server,
      surahList: surahList,
    );
  }
}

class Edition {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;

  Edition({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
  });

  factory Edition.fromJson(Map<String, dynamic> json) {
    return Edition(
      identifier: json['identifier'],
      language: json['language'],
      name: json['name'],
      englishName: json['englishName'] ?? '',
      format: json['format'],
      type: json['type'],
    );
  }
}

class Bookmark {
  final int surah;
  final int ayah;
  final int timestamp;

  Bookmark({required this.surah, required this.ayah, required this.timestamp});

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      surah: json['surah'],
      ayah: json['ayah'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'surah': surah, 'ayah': ayah, 'timestamp': timestamp};
  }
}

class LastRead {
  final int surah;
  final int ayah;
  final int timestamp;

  LastRead({required this.surah, required this.ayah, required this.timestamp});

  factory LastRead.fromJson(Map<String, dynamic> json) {
    return LastRead(
      surah: json['surah'],
      ayah: json['ayah'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'surah': surah, 'ayah': ayah, 'timestamp': timestamp};
  }
}

class LastReadMarker {
  final int surah;
  final int ayah;
  final int timestamp;

  LastReadMarker({
    required this.surah,
    required this.ayah,
    required this.timestamp,
  });

  factory LastReadMarker.fromJson(Map<String, dynamic> json) {
    return LastReadMarker(
      surah: json['surah'],
      ayah: json['ayah'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'surah': surah, 'ayah': ayah, 'timestamp': timestamp};
  }
}

class KhatmahGoal {
  final String type; // 'surah' or 'page'
  final int start;
  final int end;
  final int duration; // days
  final int startDate;

  KhatmahGoal({
    required this.type,
    required this.start,
    required this.end,
    required this.duration,
    required this.startDate,
  });

  factory KhatmahGoal.fromJson(Map<String, dynamic> json) {
    return KhatmahGoal(
      type: json['type'],
      start: json['start'],
      end: json['end'],
      duration: json['duration'],
      startDate: json['startDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'start': start,
      'end': end,
      'duration': duration,
      'startDate': startDate,
    };
  }
}

class AppSettings {
  final String theme;
  final double fontSize;
  final String arabicFont;
  final String language;
  final String displayMode;
  final bool showTranslation;
  final bool showTafsir;
  final List<String> selectedTranslations;
  final List<String> selectedTafsirs;
  final String reciterId;
  final bool audioSync;

  AppSettings({
    this.theme = 'dark',
    this.fontSize = 24,
    this.arabicFont = 'naskh',
    this.language = 'ar',
    this.displayMode = 'list',
    this.showTranslation = true,
    this.showTafsir = false,
    this.selectedTranslations = const ['en.sahih'],
    this.selectedTafsirs = const ['ar.muyassar'],
    this.reciterId = '7',
    this.audioSync = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: json['theme'] ?? 'dark',
      fontSize: (json['fontSize'] ?? 24).toDouble(),
      arabicFont: json['arabicFont'] ?? 'naskh',
      language: json['language'] ?? 'ar',
      displayMode: json['displayMode'] ?? 'list',
      showTranslation: json['showTranslation'] ?? true,
      showTafsir: json['showTafsir'] ?? false,
      selectedTranslations: List<String>.from(
        json['selectedTranslations'] ?? ['en.sahih'],
      ),
      selectedTafsirs: List<String>.from(
        json['selectedTafsirs'] ?? ['ar.muyassar'],
      ),
      reciterId: json['reciterId'] ?? '7',
      audioSync: json['audioSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'fontSize': fontSize,
      'arabicFont': arabicFont,
      'language': language,
      'displayMode': displayMode,
      'showTranslation': showTranslation,
      'showTafsir': showTafsir,
      'selectedTranslations': selectedTranslations,
      'selectedTafsirs': selectedTafsirs,
      'reciterId': reciterId,
      'audioSync': audioSync,
    };
  }

  AppSettings copyWith({
    String? theme,
    double? fontSize,
    String? arabicFont,
    String? language,
    String? displayMode,
    bool? showTranslation,
    bool? showTafsir,
    List<String>? selectedTranslations,
    List<String>? selectedTafsirs,
    String? reciterId,
    bool? audioSync,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      arabicFont: arabicFont ?? this.arabicFont,
      language: language ?? this.language,
      displayMode: displayMode ?? this.displayMode,
      showTranslation: showTranslation ?? this.showTranslation,
      showTafsir: showTafsir ?? this.showTafsir,
      selectedTranslations: selectedTranslations ?? this.selectedTranslations,
      selectedTafsirs: selectedTafsirs ?? this.selectedTafsirs,
      reciterId: reciterId ?? this.reciterId,
      audioSync: audioSync ?? this.audioSync,
    );
  }
}

enum AudioType { none, surah, radio, adhkar }

enum AudioRepeatMode { none, surah, autoAdvance }

class AudioSourceInfo {
  final int id;
  final String url;
  final String? name;

  AudioSourceInfo({required this.id, required this.url, this.name});
}

class VerseTiming {
  final Duration start;
  final Duration end;

  VerseTiming({required this.start, required this.end});
}

// Offline Mode Models
class OfflineStatus {
  bool textDownloaded;
  Map<String, bool> audioDownloaded;
  double textDbSize;
  double audioDbSize;

  OfflineStatus({
    this.textDownloaded = false,
    this.audioDownloaded = const {},
    this.textDbSize = 0,
    this.audioDbSize = 0,
  });

  factory OfflineStatus.fromJson(Map<String, dynamic> json) {
    return OfflineStatus(
      textDownloaded: json['textDownloaded'] ?? false,
      audioDownloaded: Map<String, bool>.from(json['audioDownloaded'] ?? {}),
      textDbSize: (json['textDbSize'] ?? 0).toDouble(),
      audioDbSize: (json['audioDbSize'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'textDownloaded': textDownloaded,
      'audioDownloaded': audioDownloaded,
      'textDbSize': textDbSize,
      'audioDbSize': audioDbSize,
    };
  }
}

class DownloadProgress {
  int totalItems;
  int downloadedItems;
  bool active;

  DownloadProgress({
    this.totalItems = 0,
    this.downloadedItems = 0,
    this.active = false,
  });
}
