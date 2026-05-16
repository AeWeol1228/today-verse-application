import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// Shared top bar for inner screens (verse experience, history, settings).
class TVTopBar extends StatelessWidget {
  final Widget leading;
  final String subtitle;
  final String title;
  final Widget? trailing;

  const TVTopBar({
    super.key,
    required this.leading,
    required this.subtitle,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          leading,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitle,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 12, fontStyle: FontStyle.italic,
                    color: context.tvTextLo, letterSpacing: 0.4,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.tvTextMid,
                  ),
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox(width: 42),
        ],
      ),
    );
  }
}

// Ghost icon button used in top bars
class TVGhostButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;

  const TVGhostButton({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  State<TVGhostButton> createState() => _TVGhostButtonState();
}

class _TVGhostButtonState extends State<TVGhostButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _hovered = true),
        onTapUp: (_) => setState(() => _hovered = false),
        onTapCancel: () => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered ? context.tvGoldBg : Colors.transparent,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

// TTS pill: play/pause icon + duration + animated waveform
class TTSPill extends StatelessWidget {
  final bool playing;
  final bool loading;
  final bool enabled;
  final String duration;
  final VoidCallback? onToggle;

  const TTSPill({
    super.key,
    required this.playing,
    this.loading = false,
    this.enabled = true,
    this.duration = '',
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.tvBg2,
          border: Border.all(color: context.tvLine),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              loading
                  ? Icons.hourglass_empty_rounded
                  : (playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
              size: 16,
              color: (playing || loading) ? context.tvGold : context.tvTextMid,
            ),
            if (duration.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                duration,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 13, color: context.tvTextMid, letterSpacing: 0.2,
                ),
              ),
            ],
            if (playing) ...[
              const SizedBox(width: 6),
              _Waveform(color: context.tvGold),
            ],
          ],
        ),
      ),
    );
  }
}

class _Waveform extends StatefulWidget {
  final Color color;
  const _Waveform({required this.color});

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const heights = [6.0, 11.0, 8.0, 13.0, 7.0];
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(heights.length, (i) {
          final phase = (_ctrl.value + i * 0.12) % 1.0;
          final scale = 0.4 + 0.6 * (0.5 - 0.5 * (phase < 0.5 ? phase * 2 - 1 : 1 - (phase - 0.5) * 2)).abs();
          return Container(
            width: 2,
            height: heights[i] * scale,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }
}

// Page indicator dots
class TVPageDots extends StatelessWidget {
  final int count;
  final int active;

  const TVPageDots({super.key, required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final isActive = i == active;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? context.tvGold : context.tvLineStrong,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}
