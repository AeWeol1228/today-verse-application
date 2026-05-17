import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_symbol.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../domain/entities/verse.dart';
import '../providers/verse_provider.dart';
import '../providers/verse_audio_provider.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/book_info_card.dart';
import '../widgets/verse_card.dart';

// Verse Experience — 2-page horizontal PageView:
//   Page 0: Book description (context first)
//   Page 1: Verse (both verses together)
class DailyVerseScreen extends ConsumerStatefulWidget {
  // Optional: pre-loaded verse for history re-entry.
  final Verse? initialVerse;

  const DailyVerseScreen({super.key, this.initialVerse});

  @override
  ConsumerState<DailyVerseScreen> createState() => _DailyVerseScreenState();
}

class _DailyVerseScreenState extends ConsumerState<DailyVerseScreen>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _autoPlayTriggered = false;
  bool _notificationCheckDone = false;

  // Fade-in animation for the content
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _schedulePlay(String audioUrl) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      ref.read(verseAudioProvider.notifier)
        ..setVolume(ref.read(ttsVolumeProvider))
        ..playOnce(audioUrl);
    });
  }

  void _playPageAudio(Verse verse, int page) {
    final isTtsEnabled = ref.read(settingsProvider);
    if (!isTtsEnabled) return;
    final url = page == 0 ? verse.audioUrlDescription : verse.audioUrlVerse;
    if (url == null) return;
    ref.read(verseAudioProvider.notifier)
      ..setVolume(ref.read(ttsVolumeProvider))
      ..playOnce(url);
  }

  Future<void> _maybeRequestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('notification_permission_asked') ?? false;
    if (asked || !mounted) return;
    await prefs.setBool('notification_permission_asked', true);

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('알림 허용'),
        content: const Text('매일 오전 10시, 오늘의 성경 구절을\n알림으로 받아보실 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('나중에',
                style: TextStyle(color: context.tvTextMid)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('허용',
                style: TextStyle(color: context.tvGold)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.subscribeToTopic('daily_verse');
    }
  }

  String _topBarTitle(int page) => page == 0 ? '책 설명' : '오늘의 구절';
  String _topBarSubtitle(int page) => page == 0 ? 'Context' : 'Verse';

  String? _currentPageAudioUrl(Verse verse) =>
      _currentPage == 0 ? verse.audioUrlDescription : verse.audioUrlVerse;

  @override
  Widget build(BuildContext context) {
    // If an initial verse was provided (history re-entry), use it directly.
    final initialVerse = widget.initialVerse;

    if (initialVerse != null) {
      return _buildExperience(context, initialVerse);
    }

    final verseAsync = ref.watch(todayVerseProvider);
    final isTtsEnabled = ref.watch(settingsProvider);

    ref.listen<bool>(settingsProvider, (_, next) {
      if (!next) ref.read(verseAudioProvider.notifier).stop();
    });

    ref.listen<double>(ttsVolumeProvider, (_, next) {
      ref.read(verseAudioProvider.notifier).setVolume(next);
    });

    return verseAsync.when(
      loading: () => _buildLoading(context),
      error: (e, _) => _buildError(context),
      data: (verse) {
        if (verse == null) return _buildEmpty(context);

        _fadeCtrl.forward();

        if (!_notificationCheckDone) {
          _notificationCheckDone = true;
          Future.delayed(
            const Duration(milliseconds: 2000),
            _maybeRequestNotificationPermission,
          );
        }

        if (isTtsEnabled && verse.audioUrlDescription != null && !_autoPlayTriggered) {
          _autoPlayTriggered = true;
          _schedulePlay(verse.audioUrlDescription!);
        }

        return FadeTransition(
          opacity: _fadeAnim,
          child: _buildExperience(context, verse),
        );
      },
    );
  }

  Widget _buildExperience(BuildContext context, Verse verse) {
    final isTtsEnabled = ref.watch(settingsProvider);
    final audioState = ref.watch(verseAudioProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(verseAudioProvider.notifier).stop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top bar — animates title as page changes
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: TVTopBar(
                  key: ValueKey(_currentPage),
                  leading: TVGhostButton(
                    onTap: () => Navigator.of(context).pop(),
                    semanticLabel: '홈으로',
                    child: AppSymbol(size: 22, color: context.tvTextMid),
                  ),
                  subtitle: _topBarSubtitle(_currentPage),
                  title: _topBarTitle(_currentPage),
                  trailing: TTSPill(
                    playing: audioState.isPlaying,
                    loading: audioState.isLoading,
                    enabled: isTtsEnabled && _currentPageAudioUrl(verse) != null,
                    duration: '',
                    onToggle: () {
                      final url = _currentPageAudioUrl(verse);
                      if (url != null) {
                        ref.read(verseAudioProvider.notifier).toggle(url);
                      }
                    },
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  onPageChanged: (i) async {
                    setState(() => _currentPage = i);
                    await ref.read(verseAudioProvider.notifier).stop();
                    if (!mounted) return;
                    _playPageAudio(verse, i);
                  },
                  children: [
                    BookDescriptionPage(
                      bookName: verse.book,
                      bookDescription: verse.bookDescription,
                      onSwipeToVerse: () => _pageCtrl.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    VersePage(verse: verse),
                  ],
                ),
              ),

              // Page dots
              TVPageDots(count: 2, active: _currentPage),

              // Settings shortcut — small icon at bottom right
              Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TVGhostButton(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    semanticLabel: '설정',
                    child: Icon(Icons.tune_rounded, size: 18, color: context.tvTextLo),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '오늘의 구절을 가져오는 중…',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.tvTextMid,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 6, height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.tvGold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '구절을 불러오지 못했습니다.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '오늘의 구절이 준비 중입니다.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
