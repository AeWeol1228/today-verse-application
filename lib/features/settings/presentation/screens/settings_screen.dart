import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTtsEnabled = ref.watch(settingsProvider);
    final ttsVolume = ref.watch(ttsVolumeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '설정',
          style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _SectionLabel(label: '음성', theme: theme),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            child: SwitchListTile(
              title: Text('이 책에 대하여 읽어주기', style: theme.textTheme.bodyMedium),
              subtitle: Text(
                '성경 책 설명을 음성으로 들을 수 있어요',
                style: theme.textTheme.bodySmall,
              ),
              value: isTtsEnabled,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setTtsEnabled(v),
              activeColor: theme.colorScheme.primary,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('볼륨', style: theme.textTheme.bodyMedium?.copyWith(
                        color: isTtsEnabled ? null : theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                      )),
                      Text(
                        '${(ttsVolume * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isTtsEnabled
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: ttsVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    onChanged: isTtsEnabled
                        ? (v) => ref.read(ttsVolumeProvider.notifier).setVolume(v)
                        : null,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _SectionLabel(label: '개발자', theme: theme),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(Icons.coffee_rounded, color: theme.colorScheme.primary),
              title: Text('개발자에게 커피 한 잔', style: theme.textTheme.bodyMedium),
              subtitle: Text(
                '앱이 마음에 드셨다면 응원해 주세요',
                style: theme.textTheme.bodySmall,
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.primary),
              onTap: () => launchUrl(
                Uri.parse('https://qr.kakaopay.com/FXAHety7o'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1.5),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _SettingsCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
