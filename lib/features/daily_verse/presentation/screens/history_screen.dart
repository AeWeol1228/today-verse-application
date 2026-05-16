import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_symbol.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../data/models/verse_model.dart';
import '../providers/verse_provider.dart';
import 'daily_verse_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyVersesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TVTopBar(
              leading: TVGhostButton(
                onTap: () => Navigator.of(context).pop(),
                semanticLabel: '홈',
                child: AppSymbol(size: 22, color: context.tvTextMid),
              ),
              subtitle: 'Archive',
              title: '지난 구절',
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '지난 구절',
                    style: GoogleFonts.nanumMyeongjo(
                      fontSize: 32, fontWeight: FontWeight.w800,
                      color: context.tvTextHi, letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '마주했던 말씀을 언제든 다시 펼쳐보세요',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14, fontStyle: FontStyle.italic,
                      color: context.tvTextLo, letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: historyAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                error: (e, _) => Center(
                  child: Text('불러오지 못했습니다',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                data: (verses) {
                  if (verses.isEmpty) {
                    return Center(
                      child: Text('아직 기록이 없습니다',
                          style: Theme.of(context).textTheme.bodyMedium),
                    );
                  }
                  final grouped = _groupByMonth(verses);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: grouped.length,
                    itemBuilder: (_, i) {
                      final group = grouped[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MonthLabel(label: group.label),
                          ...group.verses.map((v) => _HistoryCard(
                            verse: v,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DailyVerseScreen(initialVerse: v),
                              ),
                            ),
                          )),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MonthGroup> _groupByMonth(List<VerseModel> verses) {
    const monthNames = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final Map<String, _MonthGroup> map = {};

    for (final v in verses) {
      final key = v.dateKey;
      if (key == null) continue;
      final parts = key.split('-');
      if (parts.length < 2) continue;
      final monthIdx = (int.tryParse(parts[1]) ?? 1) - 1;
      final groupKey = '${parts[0]}-${parts[1]}';
      final label = '${monthNames[monthIdx.clamp(0, 11)]} · ${parts[0]}';
      map.putIfAbsent(groupKey, () => _MonthGroup(label: label, verses: []));
      map[groupKey]!.verses.add(v);
    }

    final result = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return result.map((e) => e.value).toList();
  }
}

class _MonthGroup {
  final String label;
  final List<VerseModel> verses;
  _MonthGroup({required this.label, required this.verses});
}

class _MonthLabel extends StatelessWidget {
  final String label;
  const _MonthLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: context.tvLine)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 12, fontStyle: FontStyle.italic,
                color: context.tvTextLo, letterSpacing: 2.2,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: context.tvLine)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final VerseModel verse;
  final VoidCallback onTap;
  const _HistoryCard({required this.verse, required this.onTap});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _pressed = false;

  String get _day {
    final parts = widget.verse.dateKey?.split('-') ?? [];
    return parts.length >= 3 ? parts[2].replaceFirst(RegExp('^0'), '') : '–';
  }

  String get _weekday {
    try {
      final d = DateTime.parse(widget.verse.dateKey!);
      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      return days[d.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  String get _preview {
    final lines = widget.verse.verseText
        .split('\n')
        .where((s) => s.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';
    final t = lines.first;
    return t.length > 55 ? '${t.substring(0, 55)}…' : t;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: _pressed ? context.tvBg3 : context.tvBg2,
          border: Border.all(color: context.tvLine),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date column
            Container(
              width: 50,
              padding: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: context.tvLine)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _day,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26, color: context.tvTextHi,
                      fontWeight: FontWeight.w500, height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _weekday,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 11, color: context.tvTextLo,
                      fontStyle: FontStyle.italic, letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.verse.book,
                        style: GoogleFonts.nanumMyeongjo(
                          fontSize: 17, fontWeight: FontWeight.w700,
                          color: context.tvTextHi, letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.verse.chapter}:${widget.verse.verse}–${widget.verse.verseEnd}',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 12, color: context.tvGold, letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _preview,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13, height: 1.5, color: context.tvTextMid,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: context.tvTextLo),
          ],
        ),
      ),
    );
  }
}
