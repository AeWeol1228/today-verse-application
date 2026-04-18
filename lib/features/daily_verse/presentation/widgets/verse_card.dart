import 'package:flutter/material.dart';
import '../../domain/entities/verse.dart';

class VerseCard extends StatelessWidget {
  final Verse verse;

  const VerseCard({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"${verse.verseText}"',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Text(
          '— ${verse.reference}',
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}
