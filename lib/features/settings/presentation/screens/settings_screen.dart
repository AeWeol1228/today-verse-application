import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_symbol.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../daily_verse/presentation/providers/verse_audio_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTtsEnabled = ref.watch(settingsProvider);
    final ttsVolume = ref.watch(ttsVolumeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final notificationHour = ref.watch(notificationHourProvider);

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
              subtitle: 'Settings',
              title: '설정',
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '설정',
                    style: GoogleFonts.nanumMyeongjo(
                      fontSize: 32, fontWeight: FontWeight.w800,
                      color: context.tvTextHi, letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preferences',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14, fontStyle: FontStyle.italic,
                      color: context.tvTextLo, letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  // ── 음성 · Voice ──────────────────────────
                  _SectionHeader(label: '음성 · Voice'),
                  _SettingsGroup(children: [
                    _SwitchRow(
                      title: '자동 낭독',
                      sub: '페이지 진입 시 책 설명과 구절을 읽어줍니다',
                      value: isTtsEnabled,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setTtsEnabled(v),
                    ),
                    _Divider(),
                    _VolumeRow(
                      volume: ttsVolume,
                      enabled: isTtsEnabled,
                      onChanged: (v) {
                        ref.read(ttsVolumeProvider.notifier).setVolume(v);
                        final isPlaying = ref.read(verseAudioProvider).isPlaying;
                        if (!isPlaying) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text(
                                '오늘의 구절 화면에서 음성을 재생한 뒤 조절하면 바로 반영됩니다',
                                style: GoogleFonts.notoSansKr(fontSize: 13),
                              ),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ));
                        }
                      },
                    ),
                  ]),

                  const SizedBox(height: 4),

                  // ── 알림 · Notification ───────────────────
                  _SectionHeader(label: '알림 · Notification'),
                  _SettingsGroup(children: [
                    _NotificationTimePicker(current: notificationHour),
                  ]),

                  const SizedBox(height: 4),

                  // ── 화면 · Theme ──────────────────────────
                  _SectionHeader(label: '화면 · Theme'),
                  _SettingsGroup(children: [
                    _ThemePicker(current: themeMode),
                  ]),

                  const SizedBox(height: 4),

                  // ── 후원 · Support ────────────────────────
                  _SectionHeader(label: '후원 · Support'),
                  _SettingsGroup(children: [
                    _LinkRow(
                      icon: Icons.favorite_rounded,
                      title: '개발자에게 커피 한 잔',
                      sub: '준비 중입니다',
                      enabled: false,
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '오늘 한 절',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14, fontStyle: FontStyle.italic,
                            color: context.tvTextLo, letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'MADE QUIETLY',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 11, color: context.tvTextLo,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 10),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

// ── Settings group container ──────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.tvBg2,
        border: Border.all(color: context.tvLine),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: context.tvLine,
    );
  }
}

// ── Switch row ────────────────────────────────────────────────
class _SwitchRow extends StatelessWidget {
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(sub,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.tvTextMid, fontSize: 12,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46, height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: value ? context.tvGold : Colors.transparent,
          border: Border.all(
            color: value ? Colors.transparent : context.tvLineStrong,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? Colors.white : context.tvTextLo,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Volume row ────────────────────────────────────────────────
class _VolumeRow extends StatelessWidget {
  final double volume;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _VolumeRow({
    required this.volume,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('음량',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: enabled ? null : context.tvTextLo,
                  )),
              Text(
                '${(volume * 100).round()}%',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 13, letterSpacing: 0.2,
                  color: enabled ? context.tvGold : context.tvTextLo,
                ),
              ),
            ],
          ),
          Opacity(
            opacity: enabled ? 1 : 0.4,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: context.tvGold,
                inactiveTrackColor: context.tvLineStrong,
                thumbColor: context.tvBg,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                trackHeight: 3,
              ),
              child: Slider(
                value: volume,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theme picker ──────────────────────────────────────────────
class _ThemePicker extends ConsumerWidget {
  final ThemeMode current;
  const _ThemePicker({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      (mode: ThemeMode.light, label: '라이트', icon: Icons.light_mode_outlined),
      (mode: ThemeMode.dark,  label: '다크',   icon: Icons.dark_mode_outlined),
      (mode: ThemeMode.system,label: '시스템', icon: Icons.brightness_auto_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: options.map((o) {
          final active = current == o.mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(o.mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: active ? context.tvGoldBg : Colors.transparent,
                  border: Border.all(
                    color: active ? context.tvGold : context.tvLine,
                    width: active ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(o.icon,
                        size: 20,
                        color: active ? context.tvGold : context.tvTextMid),
                    const SizedBox(height: 6),
                    Text(
                      o.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: active ? context.tvGold : context.tvTextMid,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Notification time picker ──────────────────────────────────
class _NotificationTimePicker extends ConsumerWidget {
  final int current;
  const _NotificationTimePicker({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const hours = [7, 9, 10, 11];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: hours.map((h) {
          final active = current == h;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(notificationHourProvider.notifier).setHour(h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: active ? context.tvGoldBg : Colors.transparent,
                  border: Border.all(
                    color: active ? context.tvGold : context.tvLine,
                    width: active ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '${h}시',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: active ? context.tvGold : context.tvTextMid,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Link row ──────────────────────────────────────────────────
class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? sub;
  final VoidCallback onTap;
  final bool enabled;

  const _LinkRow({
    required this.icon,
    required this.title,
    this.sub,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.38,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: context.tvGoldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: context.tvGold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyLarge),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(sub!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12, color: context.tvTextMid,
                          )),
                    ],
                  ],
                ),
              ),
              if (enabled)
                Icon(Icons.chevron_right_rounded, size: 18, color: context.tvTextLo),
            ],
          ),
        ),
      ),
    );
  }
}
