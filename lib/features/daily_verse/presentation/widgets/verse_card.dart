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
        Expanded(
          child: PageView.builder(
            itemCount: verses.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => _VersePageItem(
              text: verses[i],
              reference:
                  '${widget.verse.book} ${widget.verse.chapter}:${verseNumbers[i]}',
              gold: gold,
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
                color: _currentPage == i ? gold : gold.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VersePageItem extends StatefulWidget {
  final String text;
  final String reference;
  final Color gold;

  const _VersePageItem({
    required this.text,
    required this.reference,
    required this.gold,
  });

  @override
  State<_VersePageItem> createState() => _VersePageItemState();
}

class _VersePageItemState extends State<_VersePageItem> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    final next = max > 0 && current < max - 1;
    if (next != _canScrollDown) setState(() => _canScrollDown = next);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${widget.text}"',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text(
                '— ${widget.reference}',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        if (_canScrollDown)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [bg.withOpacity(0), bg],
                  ),
                ),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: widget.gold.withOpacity(0.6),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
