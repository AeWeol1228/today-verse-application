import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/verse_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final verseAsync = ref.watch(todayVerseProvider);
    final theme = Theme.of(context);

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

            return FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formattedDate().toUpperCase(),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(flex: 2),
                      VerseCard(verse: verse),
                      const Spacer(flex: 3),
                      BookInfoCard(description: verse.bookDescription),
                      const SizedBox(height: 32),
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
