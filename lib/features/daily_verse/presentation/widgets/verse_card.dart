import 'package:flutter/material.dart';
import '../../domain/entities/verse.dart';

class VerseCard extends StatefulWidget {
  final Verse verse;

  const VerseCard({super.key, required this.verse});

  @override
  State<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends State<VerseCard> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verses = widget.verse.verseText
        .split('\n')
        .where((s) => s.isNotEmpty)
        .toList();
    final verseNumbers = [widget.verse.verse, widget.verse.verseEnd];
    final gold = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: verses.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${verses[i]}"',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '— ${widget.verse.book} ${widget.verse.chapter}:${verseNumbers[i]}',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            verses.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              width: _currentPage == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? gold
                    : gold.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
