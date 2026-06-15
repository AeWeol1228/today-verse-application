import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_symbol.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import 'daily_verse_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final AudioPlayer _introPlayer = AudioPlayer();
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playIntro();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _introPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _playIntro();
    }
  }

  Future<void> _playIntro() async {
    try {
      await _introPlayer.setAsset('assets/main.mp3');
      await _introPlayer.play();
    } catch (_) {}
  }

  static bool _isFold(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide > 600;

  @override
  Widget build(BuildContext context) =>
      _isFold(context) ? _buildFold(context) : _buildNormal(context);

  Widget _buildNormal(BuildContext context) {
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

            // Church illustration — height-aware sizing for small screens (e.g. iPhone SE)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const framePad = 20.0; // 10px × 2
                      const imgAspect = 5.0 / 7.0; // church_img w/h ratio

                      final naturalImgW = constraints.maxWidth - framePad;
                      final naturalFrameH = naturalImgW / imgAspect + framePad;

                      // Normal screens: width-constrained, image fits vertically
                      if (naturalFrameH <= constraints.maxHeight) {
                        return _churchImage(context, width: naturalImgW);
                      }

                      // Small screens (iPhone SE): scale down to fit height
                      final scaledImgW =
                          (constraints.maxHeight - framePad) * imgAspect;
                      return _churchImage(context, width: scaledImgW);
                    },
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
                    '오늘 한 절',
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

  Widget _buildFold(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left page — church image
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(56, 20, 24, 20),
                      child: LayoutBuilder(
                        builder: (context, c) => _churchImage(context, width: c.maxWidth),
                      ),
                    ),
                  ),
                ),
                // Right page — wordmark + buttons
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: context.tvLine)),
                    ),
                    padding: const EdgeInsets.fromLTRB(36, 20, 64, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weekdayString()} · ${_dateLongString()}',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14, fontStyle: FontStyle.italic,
                            color: context.tvGold, letterSpacing: 0.18 * 14,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '오늘 한 절',
                          style: GoogleFonts.nanumMyeongjo(
                            fontSize: 56, fontWeight: FontWeight.w800,
                            color: context.tvTextHi, letterSpacing: 0.04 * 56,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Today's Verse",
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18, fontStyle: FontStyle.italic,
                            color: context.tvTextMid, letterSpacing: 0.04 * 18,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            '아침에 커피 한 잔처럼, 짧고 깊게 한 구절을 마주합니다.',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14, height: 1.7,
                              color: context.tvTextMid,
                            ),
                          ),
                        ),
                        const SizedBox(height: 38),
                        // Buttons — centered within right page
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _GhostButton(
                                icon: const Icon(Icons.history_rounded, size: 26),
                                onTap: () => _push(context, const HistoryScreen()),
                              ),
                              const SizedBox(width: 22),
                              _PrimaryButton(
                                child: AppSymbol(size: 28, color: context.tvGold),
                                onTap: () => _pushFade(context, const DailyVerseScreen()),
                              ),
                              const SizedBox(width: 22),
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
                ),
              ],
            ),
            // Center spine shadow
            IgnorePointer(
              child: Positioned.fill(
                child: Center(
                  child: Container(
                    width: 14,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          context.isDark
                              ? Colors.black.withValues(alpha: 0.45)
                              : const Color(0x12462D0F),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _churchImage(BuildContext context, {double? width}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFB58A2A))),
        borderRadius: BorderRadius.all(Radius.circular(3)),
        boxShadow: [
          BoxShadow(color: Color(0x2E462D0F), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x29462D0F), blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(-1, 1, 1),
        child: Image.asset(
          'assets/church_img.png',
          width: width,
          fit: BoxFit.contain,
          color: const Color(0xFFFAF7F2),
          colorBlendMode: BlendMode.multiply,
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

class _GhostButtonState extends State<_GhostButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rippleCtrl;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: 1.0, // starts completed → ring/flash invisible
    );
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _rippleCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 360), () {
      if (mounted) widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Gold ring ripple
          AnimatedBuilder(
            animation: _rippleCtrl,
            builder: (context, _) {
              final t = _rippleCtrl.value;
              return Opacity(
                opacity: (1.0 - t).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1.0 + t * 0.45,
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.tvGold, width: 2),
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner gold flash
          AnimatedBuilder(
            animation: _rippleCtrl,
            builder: (context, _) => Opacity(
              opacity: (1.0 - _rippleCtrl.value).clamp(0.0, 1.0),
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.tvGoldBg,
                ),
              ),
            ),
          ),
          // Button body
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.tvLine),
              color: Colors.transparent,
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: context.tvTextMid),
                child: widget.icon,
              ),
            ),
          ),
        ],
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

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _rippleCtrl;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: 1.0, // starts completed → ring/flash invisible
    );
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _rippleCtrl.forward(from: 0);
    setState(() => _pressed = true);
    Future.delayed(const Duration(milliseconds: 360), () {
      if (mounted) {
        setState(() => _pressed = false);
        widget.onTap(); // navigate after animation finishes
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Gold ring ripple
          AnimatedBuilder(
            animation: _rippleCtrl,
            builder: (context, _) {
              final t = _rippleCtrl.value;
              return Opacity(
                opacity: (1.0 - t).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1.0 + t * 0.45,
                  child: Container(
                    width: 76, height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.tvGold, width: 2),
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner gold flash
          AnimatedBuilder(
            animation: _rippleCtrl,
            builder: (context, _) => Opacity(
              opacity: (1.0 - _rippleCtrl.value).clamp(0.0, 1.0),
              child: Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.tvGoldBg,
                ),
              ),
            ),
          ),
          // Main button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
            width: 76, height: 76,
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
          // Gold dot below — scales up on press
          Positioned(
            bottom: -10,
            child: AnimatedOpacity(
              opacity: _pressed ? 0.3 : 0.85,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: _pressed ? 2.2 : 1.0,
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOut,
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.tvGold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
