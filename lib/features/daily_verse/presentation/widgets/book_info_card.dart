import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

// Book Description Page — Page 1 of the verse experience PageView.
class BookDescriptionPage extends StatelessWidget {
  final String bookName;
  final String bookDescription;
  final VoidCallback onSwipeToVerse;

  const BookDescriptionPage({
    super.key,
    required this.bookName,
    required this.bookDescription,
    required this.onSwipeToVerse,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = bookDescription
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre label
          Text(
            'BOOK BACKGROUND',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: context.tvGold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),

          // Book title — 나눔명조 ExtraBold 44px
          Text(
            bookName,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),

          // Period separator dot
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.tvGold.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Description paragraphs
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(p, style: Theme.of(context).textTheme.bodyMedium),
              )),

          const SizedBox(height: 8),

          // Ornament divider ─── ✣ ───
          Row(
            children: [
              Expanded(
                child: Container(
                    height: 1,
                    color: context.tvGold.withValues(alpha: 0.25)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '✣',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: context.tvGold.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                    height: 1,
                    color: context.tvGold.withValues(alpha: 0.25)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Swipe hint
          GestureDetector(
            onTap: onSwipeToVerse,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '오늘의 구절로 넘어가기',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: context.tvTextLo,
                    letterSpacing: 0.3,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: context.tvGold,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
