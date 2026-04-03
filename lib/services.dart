import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class Services {
  static Future<List<AdhkarCategory>> getAdhkar() async {
    final String response = await rootBundle.loadString('assets/adhkar.json');
    final data = await json.decode(response);

    return (data as List).map((e) => AdhkarCategory.fromJson(e)).toList();
  }

  static Future<List<RadioStation>> getRadios() async {
    final String response = await rootBundle.loadString('assets/radios.json');
    final data = await json.decode(response);

    return (data['radios'] as List).map((e) => RadioStation.fromJson(e)).toList();
  }

  static Future<List<Surah>> getSurahs() async {
    final String response = await rootBundle.loadString('assets/surahs.json');
    final data = await json.decode(response);

    return (data['data']['surahs'] as List).map((e) => Surah.fromJson(e)).toList();
  }

  static Future<List<Ayah>> getAyahs(int surahNumber, {int? edition}) async {
    final String response = await rootBundle.loadString('assets/surahs/$surahNumber.json');
    final data = await json.decode(response);

    return (data['data']['ayahs'] as List).map((e) => Ayah.fromJson(e)).toList();
  }

  static Future<void> saveRead(int surah, int ayah) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('surah', surah);
    await prefs.setInt('ayah', ayah);
  }

  static Future<List<int>> getProg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return [prefs.getInt('surah') ?? 1, prefs.getInt('ayah') ?? 1];
  }

  static Future<void> saveTimings(double lat, double lng, int method) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('lat', lat);
    await prefs.setDouble('lng', lng);
    await prefs.setInt('method', method);
  }

  static Future<List<dynamic>> getTimings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return [prefs.getDouble('lat'), prefs.getDouble('lng'), prefs.getInt('method')];
  }
}
