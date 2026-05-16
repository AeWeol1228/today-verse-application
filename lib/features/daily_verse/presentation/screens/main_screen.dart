import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_symbol.dart';
import '../../../../core/widgets/cathedral_painter.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import 'daily_verse_screen.dart';
import 'history_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Text(
                    _weekdayString(),
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: context.tvTextLo,
                      letterSpacing: 0.06 * 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateLongString(),
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 17,
                      color: context.tvTextMid,
                      letterSpacing: 0.01 * 17,
                    ),
                  ),
                ],
              ),
            ),

            // Cathedral illustration — fills remaining space
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: CathedralStipple(
                    width: MediaQuery.of(context).size.width - 48,
                    color: isDark ? AppColors.darkTextHi : AppColors.lightTextHi,
                  ),
                ),
              ),
            ),

            // App name
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  Text(
                    "Today's Verse",
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: context.tvTextLo,
                      letterSpacing: 0.18 * 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오늘의 구절',
                    style: GoogleFonts.nanumMyeongjo(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: context.tvTextHi,
                      letterSpacing: 0.04 * 26,
                    ),
                  ),
                ],
              ),
            ),

            // Three icon buttons
            Padding(
              padding: const EdgeInsets.only(top: 36, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // History
                  _GhostButton(
                    icon: const Icon(Icons.history_rounded, size: 26),
                    onTap: () => _push(context, const HistoryScreen()),
                  ),
                  const SizedBox(width: 28),

                  // Verse (primary — larger, gold accent)
                  _PrimaryButton(
                    child: AppSymbol(size: 28, color: context.tvGold),
                    onTap: () => _pushFade(context, const DailyVerseScreen()),
                  ),
                  const SizedBox(width: 28),

                  // Settings
                  _GhostButton(
                    icon: const Icon(Icons.tune_rounded, size: 26),
                    onTap: () => _push(context, const SettingsScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _pushFade(BuildContext context, Widget screen) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondary) => screen,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 600),
    ));
  }

  String _weekdayString() {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[DateTime.now().weekday % 7];
  }

  String _dateLongString() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _GhostButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;
  const _GhostButton({required this.icon, required this.onTap});

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.tvLine),
          color: _hovered ? context.tvGoldBg : Colors.transparent,
        ),
        child: IconTheme(
          data: IconThemeData(color: context.tvTextMid),
          child: widget.icon,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PrimaryButton({required this.child, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.tvBg2,
          border: Border.all(color: context.tvLineStrong),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _pressed ? 0.04 : 0.10),
              blurRadius: _pressed ? 14 : 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
