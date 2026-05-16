import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/verse.dart';

// Verse Page — Page 2 of the verse experience PageView.
// Shows both verses together on one scrollable page.
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
    final verseNumbers = [verse.verse, verse.verseEnd];

    return Container(
      color: context.tvPaper,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Opening quote mark — 64px Cormorant gold italic
            Text(
              '“',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 64,
                fontStyle: FontStyle.italic,
                color: context.tvGold,
                height: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Reference pill
            Text(
              verse.reference,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 14,
                color: context.tvGold,
                letterSpacing: 1.7,
              ),
            ),
            const SizedBox(height: 28),

            // Verse lines with number column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lines.length, (i) {
                final num = i < verseNumbers.length ? verseNumbers[i] : verse.verseEnd;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verse number
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$num',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 13,
                            color: context.tvGold.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            height: 1.9,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Verse text
                      Expanded(
                        child: Text(
                          lines[i],
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // Closing quote mark
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '”',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 64,
                  fontStyle: FontStyle.italic,
                  color: context.tvGold,
                  height: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Footer attribution
            Text(
              '개역개정 · KRV',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 12,
                color: context.tvTextLo,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
