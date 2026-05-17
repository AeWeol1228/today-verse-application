import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class BookDescriptionPage extends StatelessWidget {
  final String bookName;
  final String? bookEn;
  final String bookDescription;
  final VoidCallback onSwipeToVerse;

  const BookDescriptionPage({
    super.key,
    required this.bookName,
    this.bookEn,
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
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Kicker
          Text(
            'SCRIPTURE · KRV',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: context.tvGold,
              letterSpacing: 1.9,
            ),
          ),
          const SizedBox(height: 6),

          // Book title — NanumMyeongjo 42px ExtraBold
          Text(
            bookName,
            style: GoogleFonts.nanumMyeongjo(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: context.tvTextHi,
              letterSpacing: 0.02 * 42,
            ),
          ),
          const SizedBox(height: 4),

          // English subtitle — mirrors verse page "Today's verse" height
          Text(
            bookEn ?? '',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: context.tvTextMid,
              letterSpacing: 0.01 * 20,
            ),
          ),
          const SizedBox(height: 22),

          // Section divider — short gold · "About the book" · long line
          Row(
            children: [
              Container(
                width: 18, height: 1,
                color: context.tvGoldSoft.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 10),
              Text(
                'ABOUT THE BOOK',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: context.tvTextLo,
                  letterSpacing: 0.18 * 11,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(height: 1, color: context.tvLineStrong),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description paragraphs
          ...paragraphs.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              p,
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                height: 1.85,
                fontWeight: FontWeight.w400,
                color: context.tvTextHi,
              ),
            ),
          )),
          const SizedBox(height: 8),

          // Ornament ✣
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32, height: 1,
                color: context.tvGoldSoft.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 10),
              Text(
                '✣',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: context.tvGoldSoft,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32, height: 1,
                color: context.tvGoldSoft.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Swipe hint
          GestureDetector(
            onTap: onSwipeToVerse,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 구절로 넘어가기',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: context.tvTextLo,
                      letterSpacing: 0.04 * 14,
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
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
