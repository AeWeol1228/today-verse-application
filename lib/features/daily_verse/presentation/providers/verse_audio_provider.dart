import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VerseAudioState {
  final bool isLoading;
  final bool isPlaying;
  final bool hasError;

  const VerseAudioState({
    this.isLoading = false,
    this.isPlaying = false,
    this.hasError = false,
  });
}

class VerseAudioNotifier extends StateNotifier<VerseAudioState> {
  final AudioPlayer _player = AudioPlayer();
  double _volume = 1.0;

  VerseAudioNotifier() : super(const VerseAudioState()) {
    _player.playerStateStream.listen((ps) {
      if (ps.processingState == ProcessingState.completed) {
        _player.stop();
        state = const VerseAudioState();
      } else if (ps.playing) {
        state = const VerseAudioState(isPlaying: true);
      }
    });
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _player.setVolume(volume);
  }

  Future<void> stop() async {
    await _player.stop();
    state = const VerseAudioState();
  }

  Future<void> toggle(String audioUrl) async {
    if (state.isPlaying || state.isLoading) {
      await stop();
    } else {
      await playOnce(audioUrl);
    }
  }

  Future<void> playOnce(String audioUrl) async {
    if (state.isLoading || state.isPlaying) return;

    state = const VerseAudioState(isLoading: true);

    try {
      final path = await _getLocalPath(audioUrl);
      await _player.setVolume(_volume);
      await _player.setFilePath(path);
      await _player.play(); // isPlaying: true는 playerStateStream 리스너에서 세팅
    } catch (_) {
      state = const VerseAudioState(hasError: true);
    }
  }

  Future<String> _getLocalPath(String audioUrl) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = Uri.decodeFull(audioUrl).split('/').last;
    final file = File('${dir.path}/$filename');

    if (await file.exists()) return file.path;

    final response = await http.get(Uri.parse(audioUrl));
    if (response.statusCode != 200) {
      throw Exception('Download failed: ${response.statusCode}');
    }
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final verseAudioProvider =
    StateNotifierProvider<VerseAudioNotifier, VerseAudioState>(
  (_) => VerseAudioNotifier(),
);
