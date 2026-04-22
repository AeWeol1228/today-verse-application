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

  VerseAudioNotifier() : super(const VerseAudioState()) {
    _player.playerStateStream.listen((ps) {
      if (ps.processingState == ProcessingState.completed) {
        _player.stop();
        state = const VerseAudioState();
      }
    });
  }

  Future<void> stop() async {
    await _player.stop();
    state = const VerseAudioState();
  }

  Future<void> playOnce(String audioUrl) async {
    if (state.isLoading || state.isPlaying) return;

    state = const VerseAudioState(isLoading: true);

    try {
      final path = await _getLocalPath(audioUrl);
      await _player.setFilePath(path);
      await _player.play();
      state = const VerseAudioState(isPlaying: true);
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
