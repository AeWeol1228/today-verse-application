import 'package:flutter/material.dart';

class BookInfoCard extends StatefulWidget {
  final String description;
  final double? maxContentHeight;

  const BookInfoCard({super.key, required this.description, this.maxContentHeight});

  @override
  State<BookInfoCard> createState() => _BookInfoCardState();
}

class _BookInfoCardState extends State<BookInfoCard> {
  bool _expanded = true;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contentHeight = widget.maxContentHeight ?? MediaQuery.of(context).size.height * 0.30;

    return GestureDetector(
      onTap: _expanded ? null : _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFF0EAE0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _toggle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '이 책에 대하여',
                    style: theme.textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: contentHeight),
                child: SingleChildScrollView(
                  child: Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
