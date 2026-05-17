import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool? _wasFold;
  Verse? _currentVerse; // fold 전환 처리에 필요

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isFold = MediaQuery.of(context).size.shortestSide > 600;
    if (_wasFold != null && _wasFold != isFold) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleFoldTransition(isFold);
      });
    }
    _wasFold = isFold;
  }

  void _handleFoldTransition(bool nowFold) {
    final verse = _currentVerse ?? widget.initialVerse;
    if (verse == null) return;

    final notifier = ref.read(verseAudioProvider.notifier);
    final audioState = ref.read(verseAudioProvider);
    final currentUrl = notifier.currentPlayingUrl;
    final isActive = audioState.isPlaying || audioState.isLoading;

    if (nowFold) {
      // normal → fold: 설명 재생 중이면 구절을 큐에 추가
      if (isActive &&
          currentUrl == verse.audioUrlDescription &&
          verse.audioUrlVerse != null) {
        notifier.enqueueIfEmpty(verse.audioUrlVerse!);
      }
    } else {
      // fold → normal: 큐 비우고 현재 음성에 맞는 페이지로 이동
      notifier.clearQueue();
      if (isActive) {
        final targetPage = currentUrl == verse.audioUrlVerse ? 1 : 0;
        setState(() => _currentPage = targetPage);
        _pageCtrl.jumpToPage(targetPage);
      }
    }
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

        _currentVerse = verse;
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

  static bool _isFold(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide > 600;

  Widget _buildExperience(BuildContext context, Verse verse) {
    if (_isFold(context)) return _buildFoldExperience(context, verse);
    return _buildNormalExperience(context, verse);
  }

  Widget _buildFoldExperience(BuildContext context, Verse verse) {
    final isTtsEnabled = ref.watch(settingsProvider);
    final audioState = ref.watch(verseAudioProvider);

    final paragraphs = verse.bookDescription
        .split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final lines = verse.verseText
        .split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final verseNumbers = [verse.verse, verse.verseEnd];
    final dateStr = 'Today · ${_dateLongString()}';

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(verseAudioProvider.notifier).stop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Master header — full width
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 6, 60, 14),
                    child: Row(
                      children: [
                        TVGhostButton(
                          onTap: () => Navigator.of(context).pop(),
                          semanticLabel: '홈으로',
                          child: AppSymbol(size: 26, color: context.tvTextMid),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dateStr,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 12, fontStyle: FontStyle.italic,
                                  color: context.tvTextLo, letterSpacing: 0.22 * 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '오늘의 구절',
                                style: GoogleFonts.nanumMyeongjo(
                                  fontSize: 22, fontWeight: FontWeight.w700,
                                  color: context.tvTextHi, letterSpacing: 0.04 * 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  // Two-column reading area
                  Expanded(
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left: book description
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(60, 8, 28, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SCRIPTURE · KRV',
                                      style: GoogleFonts.cormorantGaramond(
                                        fontSize: 12, fontStyle: FontStyle.italic,
                                        color: context.tvGold, letterSpacing: 1.9,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      verse.book,
                                      style: GoogleFonts.nanumMyeongjo(
                                        fontSize: 42, fontWeight: FontWeight.w800,
                                        height: 1.1, color: context.tvTextHi,
                                        letterSpacing: 0.02 * 42,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      verse.bookEn ?? '',
                                      style: GoogleFonts.cormorantGaramond(
                                        fontSize: 20, fontStyle: FontStyle.italic,
                                        color: context.tvTextMid,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    _foldDivider(context, 'ABOUT THE BOOK'),
                                    ...paragraphs.map((p) => Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Text(p, style: GoogleFonts.notoSansKr(
                                        fontSize: 15, height: 1.85,
                                        color: context.tvTextHi,
                                      )),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            // Right: verse
                            Expanded(
                              child: Container(
                                color: context.tvPaper,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: context.tvLine),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(28, 8, 60, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${verse.book} · ${verse.chapter}:${verse.verse}–${verse.verseEnd}',
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 12, fontStyle: FontStyle.italic,
                                          color: context.tvGold, letterSpacing: 1.9,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${verse.book} ${verse.chapter}장',
                                        style: GoogleFonts.nanumMyeongjo(
                                          fontSize: 42, fontWeight: FontWeight.w800,
                                          height: 1.1, color: context.tvTextHi,
                                          letterSpacing: 0.02 * 42,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Today's verse",
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 20, fontStyle: FontStyle.italic,
                                          color: context.tvTextMid,
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      _foldDivider(context, 'THE VERSE'),
                                      ...List.generate(lines.length, (i) {
                                        final num = i < verseNumbers.length
                                            ? verseNumbers[i] : verse.verseEnd;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 22),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Text(
                                                lines[i],
                                                style: GoogleFonts.nanumMyeongjo(
                                                  fontSize: 20, height: 1.9,
                                                  fontWeight: FontWeight.w400,
                                                  color: context.tvTextHi,
                                                  letterSpacing: -0.1,
                                                ),
                                              ),
                                              Positioned(
                                                left: -28, top: 5,
                                                child: SizedBox(
                                                  width: 20,
                                                  child: Text(
                                                    '$num',
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.cormorantGaramond(
                                                      fontSize: 12,
                                                      color: context.tvGoldSoft,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.9,
                                                      letterSpacing: 0.04 * 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      // Ornament ✣
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(width: 32, height: 1, color: context.tvGoldSoft.withValues(alpha: 0.5)),
                                          const SizedBox(width: 10),
                                          Text('✣', style: GoogleFonts.cormorantGaramond(
                                            fontSize: 14, fontStyle: FontStyle.italic,
                                            color: context.tvGoldSoft,
                                          )),
                                          const SizedBox(width: 10),
                                          Container(width: 32, height: 1, color: context.tvGoldSoft.withValues(alpha: 0.5)),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Center(
                                        child: Text(
                                          '· 개역개정 ·',
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 13, fontStyle: FontStyle.italic,
                                            color: context.tvTextLo, letterSpacing: 0.04 * 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Center spine shadow
                        IgnorePointer(
                          child: Positioned.fill(
                            child: Center(
                              child: Container(
                                width: 14,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      context.isDark
                                          ? Colors.black.withValues(alpha: 0.45)
                                          : const Color(0x12462D0F),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Floating TTS — plays description then verse sequentially
              if (isTtsEnabled && verse.audioUrlDescription != null)
                Positioned(
                  right: 36,
                  bottom: 38,
                  child: FloatingTTSButton(
                    playing: audioState.isPlaying,
                    loading: audioState.isLoading,
                    onToggle: () {
                      final urls = [
                        verse.audioUrlDescription!,
                        if (verse.audioUrlVerse != null) verse.audioUrlVerse!,
                      ];
                      ref.read(verseAudioProvider.notifier).toggleSequence(urls);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foldDivider(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: [
          Container(width: 18, height: 1, color: context.tvGoldSoft.withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 11, fontStyle: FontStyle.italic,
              color: context.tvTextLo, letterSpacing: 0.18 * 11,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: context.tvLineStrong)),
        ],
      ),
    );
  }

  String _dateLongString() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildNormalExperience(BuildContext context, Verse verse) {
    final isTtsEnabled = ref.watch(settingsProvider);
    final audioState = ref.watch(verseAudioProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(verseAudioProvider.notifier).stop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
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
                          bookEn: verse.bookEn,
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

              // Floating TTS button — bottom-right, above page dots
              if (isTtsEnabled && _currentPageAudioUrl(verse) != null)
                Positioned(
                  right: 20,
                  bottom: 60,
                  child: FloatingTTSButton(
                    playing: audioState.isPlaying,
                    loading: audioState.isLoading,
                    onToggle: () {
                      final url = _currentPageAudioUrl(verse);
                      if (url != null) {
                        ref.read(verseAudioProvider.notifier).toggle(url);
                      }
                    },
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
