import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/verse_provider.dart';
import '../providers/verse_audio_provider.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/verse_card.dart';
import '../widgets/book_info_card.dart';

class DailyVerseScreen extends ConsumerStatefulWidget {
  const DailyVerseScreen({super.key});

  @override
  ConsumerState<DailyVerseScreen> createState() => _DailyVerseScreenState();
}

class _DailyVerseScreenState extends ConsumerState<DailyVerseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _autoPlayTriggered = false;
  bool _notificationCheckDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _maybeRequestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('notification_permission_asked') ?? false;
    if (asked || !mounted) return;
    await prefs.setBool('notification_permission_asked', true);

    if (!mounted) return;
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('알림 허용'),
        content: const Text('매일 오전 10시, 오늘의 성경 구절을\n알림으로 받아보실 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('나중에', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('허용', style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.subscribeToTopic('daily_verse');
    }
  }

  void _schedulePlay(String audioUrl) {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ref.read(verseAudioProvider.notifier)
          ..setVolume(ref.read(ttsVolumeProvider))
          ..playOnce(audioUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final verseAsync = ref.watch(todayVerseProvider);
    final isTtsEnabled = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    ref.listen<bool>(settingsProvider, (_, next) {
      if (!next) ref.read(verseAudioProvider.notifier).stop();
    });

    ref.listen<double>(ttsVolumeProvider, (_, next) {
      ref.read(verseAudioProvider.notifier).setVolume(next);
    });

    return Scaffold(
      body: SafeArea(
        child: verseAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 1),
          ),
          error: (e, _) => const Center(
            child: Text('구절을 불러오지 못했습니다.'),
          ),
          data: (verse) {
            if (verse == null) {
              return Center(
                child: Text(
                  '오늘의 구절이 준비 중입니다.',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            _controller.forward();

            if (!_notificationCheckDone) {
              _notificationCheckDone = true;
              Future.delayed(
                const Duration(milliseconds: 2000),
                _maybeRequestNotificationPermission,
              );
            }

            if (isTtsEnabled && verse.audioUrl != null && !_autoPlayTriggered) {
              _autoPlayTriggered = true;
              _schedulePlay(verse.audioUrl!);
            }

            final audioState = ref.watch(verseAudioProvider);

            final size = MediaQuery.of(context).size;
            final safePaddingTop = MediaQuery.of(context).padding.top;
            final safePaddingBottom = MediaQuery.of(context).padding.bottom;
            // 상단 섹션(헤더+구절)이 화면 50% 지점에서 끝나도록 계산
            final topSectionHeight = (size.height * 0.5 - safePaddingTop - 48.0).clamp(180.0, double.infinity);
            // 하단(BookInfoCard) 가용 공간에서 오버헤드를 빼 콘텐츠 최대 높이 산정
            final maxBookContentHeight = (size.height * 0.5 - safePaddingBottom - 124.0).clamp(100.0, 300.0);

            return FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: topSectionHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _formattedDate().toUpperCase(),
                                  style: theme.textTheme.bodySmall,
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: isTtsEnabled && verse.audioUrl != null
                                          ? () => ref
                                              .read(verseAudioProvider.notifier)
                                              .toggle(verse.audioUrl!)
                                          : null,
                                      child: Icon(
                                        audioState.isPlaying || audioState.isLoading
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 20,
                                        color: isTtsEnabled
                                            ? theme.textTheme.bodySmall?.color
                                            : theme.textTheme.bodySmall?.color
                                                ?.withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SettingsScreen(),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.settings_outlined,
                                        size: 18,
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: VerseCard(verse: verse),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      BookInfoCard(
                        description: verse.bookDescription,
                        maxContentHeight: maxBookContentHeight,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
