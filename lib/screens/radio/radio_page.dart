import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../app_provider.dart';
import '../../core.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Radio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: provider.radios.length,
        itemBuilder: (context, index) {
          final radio = provider.radios[index];
          return ListTile(
            title: Text(radio.name, style: const TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: Icon(
                provider.audioPlayer.playing && provider.audioPlayer.audioSource?.sequence.first.tag == radio.url
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: AppColors.primary,
                size: 32,
              ),
              onPressed: () async {
                if (provider.audioPlayer.playing && provider.audioPlayer.audioSource?.sequence.first.tag == radio.url) {
                  await provider.audioPlayer.pause();
                } else {
                  await provider.audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(radio.url), tag: radio.url));
                  await provider.audioPlayer.play();
                }
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}
