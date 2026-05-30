import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/verse.dart';

class VersePage extends StatelessWidget {
  final Verse verse;

  const VersePage({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final lines = verse.verseText
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final verseNumbers = List.generate(lines.length, (i) => verse.verse + i);

    return Container(
      color: context.tvPaper,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Kicker
            Text(
              '${verse.book} · ${verse.chapter}:${verse.verse}–${verse.verseEnd}',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: context.tvGold,
                letterSpacing: 1.9,
              ),
            ),
            const SizedBox(height: 6),

            // H1: reference — NanumMyeongjo 42px ExtraBold
            Text(
              '${verse.book} ${verse.chapter}',
              style: GoogleFonts.nanumMyeongjo(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: context.tvTextHi,
                letterSpacing: 0.02 * 42,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              "Today's verse",
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: context.tvTextMid,
                letterSpacing: 0.01 * 20,
              ),
            ),
            const SizedBox(height: 22),

            // Section divider — short gold · "The verse" · long line
            Row(
              children: [
                Container(
                  width: 18, height: 1,
                  color: context.tvGoldSoft.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                Text(
                  'THE VERSE',
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
            const SizedBox(height: 22),

            // Verse lines — number hangs outside left gutter (absolute),
            // text first character aligns with H1 at x=28 from screen edge.
            ...List.generate(lines.length, (i) {
              final num = i < verseNumbers.length ? verseNumbers[i] : verse.verseEnd;
              return Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Verse text — starts at content x=0 (screen x=28), aligned with H1
                    Text(
                      lines[i],
                      style: GoogleFonts.nanumMyeongjo(
                        fontSize: 21,
                        height: 1.9,
                        fontWeight: FontWeight.w400,
                        color: context.tvTextHi,
                        letterSpacing: -0.1,
                      ),
                    ),
                    // Number positioned in the left gutter: right edge 6px before text
                    Positioned(
                      left: -26, // 20px number width + 6px gap
                      top: 4,
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
            const SizedBox(height: 14),

            // Attribution
            Center(
              child: Column(
                children: [
                  Text(
                    '· 개역개정 ·',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: context.tvTextLo,
                      letterSpacing: 0.04 * 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KOREAN REVISED VERSION',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 11,
                      color: context.tvTextLo.withValues(alpha: 0.7),
                      letterSpacing: 0.22 * 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
