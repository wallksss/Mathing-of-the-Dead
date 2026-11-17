import 'package:firebase_ui_auth/firebase_ui_auth.dart' show FirebaseUIAuth;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/user_repository.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/common.dart';
import 'app_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const appearance = _AppearanceSection();
          const others = Column(
            children: [_GameSection(), SizedBox(height: 16), _AccountSection()],
          );
          if (constraints.maxWidth >= 1000) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: appearance),
                  SizedBox(width: 16),
                  Expanded(child: others),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: const Column(
                  children: [appearance, SizedBox(height: 16), others],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

String _presetName(AppLocalizations l, ThemePreset p) => switch (p) {
  ThemePreset.classic => l.presetClassic,
  ThemePreset.toxic => l.presetToxic,
  ThemePreset.bloodMoon => l.presetBloodMoon,
  ThemePreset.midnight => l.presetMidnight,
  ThemePreset.fog => l.presetFog,
  ThemePreset.pumpkin => l.presetPumpkin,
};

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    return _Section(
      icon: Icons.palette_rounded,
      title: l.appearance,
      children: [
        _Label(l.themeMode),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              icon: const Icon(Icons.brightness_auto_rounded),
              label: Text(l.themeSystem),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode_rounded),
              label: Text(l.themeLight),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode_rounded),
              label: Text(l.themeDark),
            ),
          ],
          selected: {s.themeMode},
          onSelectionChanged: (v) => c.setThemeMode(v.first),
        ),
        _Label(l.themePresets),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in ThemePreset.values)
              ChoiceChip(
                avatar: CircleAvatar(backgroundColor: p.seed, radius: 8),
                label: Text(_presetName(l, p)),
                selected: s.seedColor.toARGB32() == p.seed.toARGB32(),
                onSelected: (_) => c.setSeedColor(p.seed),
              ),
          ],
        ),
        _Label(l.seedColor),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in Colors.primaries)
              _Swatch(
                color: color,
                selected: s.seedColor.toARGB32() == color.toARGB32(),
                onTap: () => c.setSeedColor(color),
              ),
          ],
        ),
        _Label(l.customColor),
        _CustomColor(color: s.seedColor, onChanged: c.setSeedColor),
        _Label(l.fontFamily),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final font in availableFonts)
              ChoiceChip(
                label: Text(font, style: GoogleFonts.getFont(font)),
                selected: s.fontFamily == font,
                onSelected: (_) => c.setFontFamily(font),
              ),
          ],
        ),
        _Label('${l.fontSize} · ${(s.textScale * 100).round()}%'),
        Row(
          children: [
            const Icon(Icons.text_decrease_rounded),
            Expanded(
              child: Slider(
                value: s.textScale,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: '${(s.textScale * 100).round()}%',
                onChanged: c.setTextScale,
              ),
            ),
            const Icon(Icons.text_increase_rounded),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(l.fontPreview),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

/// Hue / saturation sliders for any seed color.
class _CustomColor extends StatelessWidget {
  const _CustomColor({required this.color, required this.onChanged});

  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hsv = HSVColor.fromColor(color);
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 90, child: Text(l.hue)),
                  Expanded(
                    child: Slider(
                      value: hsv.hue,
                      max: 360,
                      onChanged: (v) =>
                          onChanged(hsv.withHue(v).withValue(0.8).toColor()),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 90, child: Text(l.saturation)),
                  Expanded(
                    child: Slider(
                      value: hsv.saturation,
                      onChanged: (v) => onChanged(
                        hsv.withSaturation(v).withValue(0.8).toColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameSection extends ConsumerWidget {
  const _GameSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    return _Section(
      icon: Icons.sports_esports_rounded,
      title: l.game,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(
            s.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          ),
          title: Text(l.soundEffects),
          subtitle: Text(l.soundEffectsDesc),
          value: s.soundEnabled,
          onChanged: c.setSound,
        ),
        _Label(l.zombieSpeed),
        SegmentedButton<ZombieSpeed>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: ZombieSpeed.off, label: Text(l.speedOff)),
            ButtonSegment(value: ZombieSpeed.slow, label: Text(l.speedSlow)),
            ButtonSegment(
              value: ZombieSpeed.normal,
              label: Text(l.speedNormal),
            ),
            ButtonSegment(value: ZombieSpeed.fast, label: Text(l.speedFast)),
          ],
          selected: {s.zombieSpeed},
          onSelectionChanged: (v) => c.setZombieSpeed(v.first),
        ),
        _Label(l.language),
        const LanguagePicker(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: c.reset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(l.resetSettings),
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends ConsumerStatefulWidget {
  const _AccountSection();

  @override
  ConsumerState<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<_AccountSection> {
  final _nickname = TextEditingController();
  late final Future<void> _loaded = _load();
  bool _saving = false;

  Future<void> _load() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final profile = await ref.read(userRepositoryProvider).loadProfile(user);
    _nickname.text = profile.nickname;
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    final name = _nickname.text.trim();
    if (user == null || name.isEmpty) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).updateNickname(user.uid, name);
      ref.read(dataVersionProvider.notifier).bump();
      messenger.showSnackBar(SnackBar(content: Text(l.nicknameSaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.saveFailed('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    return _Section(
      icon: Icons.account_circle_rounded,
      title: l.account,
      children: [
        if (user != null)
          Text(l.signedInAs(user.email ?? user.displayName ?? user.uid)),
        const SizedBox(height: 12),
        FutureBuilder<void>(
          future: _loaded,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const GraveLoader(size: 32);
            }
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nickname,
                    maxLength: 24,
                    decoration: InputDecoration(
                      labelText: l.nickname,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(l.save),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () => FirebaseUIAuth.signOut(context: context),
          icon: const Icon(Icons.logout_rounded),
          label: Text(l.signOut),
        ),
      ],
    );
  }
}
