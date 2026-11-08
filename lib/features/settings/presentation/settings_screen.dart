import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/platform/platform_info.dart';
import '../../../core/platform/windows_shell.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/context_ext.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/video_extensions.dart';
import '../../../core/widgets/local_tube_logo.dart';
import '../../folders/domain/library_indexer.dart';
import '../../player/domain/player_controller.dart';
import '../domain/app_settings.dart';
import 'settings_providers.dart';

const kAppVersion = '1.0.0';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final indexer = ref.read(libraryIndexerProvider.notifier);

    Future<void> update(AppSettings Function(AppSettings) f) => notifier.update(f);

    return Scaffold(
      appBar: AppBar(title: Text(l.actionSettings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Section(l.settingsAppearance),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l.settingsTheme),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
                  ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight)),
                  ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem)),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => notifier.setThemeMode(v.first),
              ),
            ),
          ),

          _Section(l.settingsLibrary),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(l.settingsFolders),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.folders),
          ),
          ListTile(
            leading: const Icon(Icons.extension_outlined),
            title: Text(l.settingsExtensions),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final ext in kVideoExtensions)
                    FilterChip(
                      label: Text('.$ext'),
                      selected: s.extensions.contains(ext),
                      onSelected: (on) => update((x) => x.copyWith(
                            extensions: on
                                ? [...x.extensions, ext]
                                : (x.extensions.length > 1
                                    ? x.extensions.where((e) => e != ext).toList()
                                    : x.extensions),
                          )),
                    ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.filter_alt_outlined),
            title: Text(l.settingsMinSize),
            subtitle: Slider(
              value: s.minSizeMb.toDouble(),
              max: 500,
              divisions: 50,
              label: l.megabytes(s.minSizeMb),
              onChanged: (v) =>
                  update((x) => x.copyWith(minSizeMb: v.round())),
            ),
            trailing: Text(l.megabytes(s.minSizeMb)),
          ),

          _Section(l.settingsPlayback),
          SwitchListTile(
            secondary: const Icon(Icons.skip_next_outlined),
            title: Text(l.settingsAutoplay),
            value: s.autoplayNext,
            onChanged: (v) {
              update((x) => x.copyWith(autoplayNext: v));
              ref.read(playerControllerProvider.notifier).setAutoplay(v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: Text(l.settingsDefaultSpeed),
            trailing: DropdownButton<double>(
              value: s.defaultSpeed,
              underline: const SizedBox.shrink(),
              items: [
                for (final sp in PlayerController.speeds)
                  DropdownMenuItem(value: sp, child: Text(Fmt.speed(sp))),
              ],
              onChanged: (v) =>
                  v == null ? null : update((x) => x.copyWith(defaultSpeed: v)),
            ),
          ),
          _LangTile(
            icon: Icons.closed_caption_outlined,
            title: l.settingsSubLang,
            value: s.preferredSubtitleLang,
            onChanged: (v) async {
              await update((x) => x.copyWith(preferredSubtitleLang: v));
              await ref
                  .read(playerControllerProvider.notifier)
                  .applyLanguagePreferences();
            },
          ),
          _LangTile(
            icon: Icons.record_voice_over_outlined,
            title: l.settingsAudioLang,
            value: s.preferredAudioLang,
            onChanged: (v) async {
              await update((x) => x.copyWith(preferredAudioLang: v));
              await ref
                  .read(playerControllerProvider.notifier)
                  .applyLanguagePreferences();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.memory),
            title: Text(l.settingsHwAccel),
            subtitle: Text(l.settingsHwAccelHint),
            value: s.hardwareAcceleration,
            onChanged: (v) =>
                update((x) => x.copyWith(hardwareAcceleration: v)),
          ),

          _Section(l.settingsMaintenance),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l.actionRescan),
            onTap: () {
              indexer.rescanAll();
              context.showSnack(l.rescanStarted);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image_not_supported_outlined),
            title: Text(l.settingsClearThumbs),
            onTap: () async {
              await indexer.clearThumbnailCache();
              if (context.mounted) context.showSnack(l.thumbsCleared);
            },
          ),
          if (PlatformInfo.isWindows)
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: Text(l.settingsAssociate),
              subtitle: Text(l.settingsAssociateHint),
              onTap: () async {
                final ok = await WindowsShell.registerFileAssociations();
                if (context.mounted) {
                  context.showSnack(ok ? l.associateDone : l.associateFailed);
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.settingsAbout),
            subtitle: const Text('Versão $kAppVersion'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'LocalTube',
              applicationVersion: kAppVersion,
              applicationIcon: const LocalTubeLogo(height: 32, showText: false),
              applicationLegalese: l.aboutDescription,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
        child: Text(
          title,
          style: context.text.titleSmall?.copyWith(color: context.colors.primary),
        ),
      );
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  Future<void> _edit(BuildContext context) async {
    final ctrl = TextEditingController(text: value);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z,]')),
          ],
          decoration: InputDecoration(helperText: ctx.l10n.settingsLangHint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.l10n.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: Text(ctx.l10n.actionSave)),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null) onChanged(result.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value.isEmpty ? '—' : value),
        trailing: const Icon(Icons.edit_outlined, size: 20),
        onTap: () => _edit(context),
      );
}
