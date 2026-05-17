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
  List<String> _queue = [];
  String? _currentUrl; // 현재 재생 중인 URL (UI 반영 불필요 → state 외부)

  VerseAudioNotifier() : super(const VerseAudioState()) {
    _player.playerStateStream.listen((ps) {
      if (ps.processingState == ProcessingState.completed) {
        state = const VerseAudioState();
        if (_queue.isNotEmpty) {
          _playNext();
        } else {
          _currentUrl = null;
          _player.stop();
        }
      } else if (ps.playing) {
        state = const VerseAudioState(isPlaying: true);
      }
    });
  }

  /// 현재 재생 중인 오디오 URL. 전환 판단에 사용.
  String? get currentPlayingUrl => _currentUrl;

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _player.setVolume(volume);
  }

  Future<void> stop() async {
    _queue.clear();
    _currentUrl = null;
    await _player.stop();
    state = const VerseAudioState();
  }

  /// 큐만 비움 (재생은 유지). fold→normal 전환 시 사용.
  void clearQueue() => _queue.clear();

  /// 큐가 비어있을 때만 URL 추가. normal→fold 전환 시 사용.
  void enqueueIfEmpty(String url) {
    if (_queue.isEmpty) _queue.add(url);
  }

  Future<void> toggle(String audioUrl) async {
    if (state.isPlaying || state.isLoading) {
      await stop();
    } else {
      await playOnce(audioUrl);
    }
  }

  /// 여러 URL을 순서대로 재생. fold 모드 TTS 버튼에서 사용.
  Future<void> toggleSequence(List<String> urls) async {
    if (state.isPlaying || state.isLoading) {
      await stop();
    } else {
      await _playSequence(urls);
    }
  }

  Future<void> _playSequence(List<String> urls) async {
    if (urls.isEmpty) return;
    _queue = urls.sublist(1).toList();
    await playOnce(urls.first);
  }

  Future<void> _playNext() async {
    if (_queue.isEmpty) return;
    final url = _queue.removeAt(0);
    await playOnce(url);
  }

  Future<void> playOnce(String audioUrl) async {
    if (state.isLoading || state.isPlaying) return;

    _currentUrl = audioUrl;
    state = const VerseAudioState(isLoading: true);

    try {
      final path = await _getLocalPath(audioUrl);
      await _player.setVolume(_volume);
      await _player.setFilePath(path);
      await _player.play();
    } catch (_) {
      _queue.clear();
      _currentUrl = null;
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
