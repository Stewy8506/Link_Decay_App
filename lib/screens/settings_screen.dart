import 'dart:convert';
import 'dart:io' hide Link;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart' show parseHexColor, getTitleStyle, getFontTextStyle;
import '../models/link_status.dart';
import '../providers/providers.dart';
import '../services/export_service.dart';
import '../utils/constants.dart';

import 'settings_section_widgets.dart';
import 'settings_dialogs.dart';
import 'health_check_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _contactDeveloper() async {
    final emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'dasanuvab38@gmail.com',
      queryParameters: {'subject': 'LinkShelf Feedback'},
    );
    try {
      final success = await launchUrl(emailLaunchUri);
      if (!success) {
        _showSnackBar('Could not open email client.');
      }
    } catch (e) {
      _showSnackBar('Could not open email client.');
    }
  }

  Future<void> _runHealthCheck() async {
    final db = ref.read(databaseProvider);
    final links = await (db.select(
      db.links,
    )..where((l) => l.status.equalsValue(LinkStatus.inbox))).get();

    if (links.isEmpty) {
      _showSnackBar('No active links to scan.');
      return;
    }

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return HealthCheckProgressDialog(links: links, db: db);
      },
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  // ── Backup / Import Logic ───────────────────────────────────────────────

  Future<void> _backupJson() async {
    try {
      final db = ref.read(databaseProvider);
      await ExportService.instance.shareJsonExport(db);
      HapticFeedback.lightImpact();
    } catch (e) {
      _showSnackBar('Backup failed: $e');
    }
  }

  Future<void> _backupHtml() async {
    try {
      final db = ref.read(databaseProvider);
      await ExportService.instance.shareHtmlExport(db);
      HapticFeedback.lightImpact();
    } catch (e) {
      _showSnackBar('Bookmarks export failed: $e');
    }
  }

  Future<void> _importJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Import JSON Backup',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: const Text(
              'Choose restore strategy:\n\n'
              '• Merge: Keep existing links & settings.\n'
              '• Overwrite: Clear all database data first.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _executeJsonRestore(content, merge: true);
                },
                child: Text(
                  'Merge',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _executeJsonRestore(content, merge: false);
                },
                child: Text(
                  'Overwrite',
                  style: TextStyle(
                    color: kFreshnessLow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showSnackBar('Import failed: $e');
    }
  }

  Future<void> _executeJsonRestore(
    String jsonContent, {
    required bool merge,
  }) async {
    final db = ref.read(databaseProvider);
    final count = await ExportService.instance.importFromJson(
      db,
      jsonContent,
      merge: merge,
    );
    _showSnackBar('Successfully restored $count links!');
    HapticFeedback.heavyImpact();
  }

  Future<void> _importHtml() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'htm'],
      );
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      final db = ref.read(databaseProvider);
      final count = await ExportService.instance.importFromHtml(db, content);
      _showSnackBar('Successfully imported $count bookmarks!');
      HapticFeedback.heavyImpact();
    } catch (e) {
      _showSnackBar('HTML import failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final domainOverrides = ref.watch(domainHalfLifeOverridesProvider);
    final tagOverrides = ref.watch(tagHalfLifeOverridesProvider);
    final snoozePresets = ref.watch(snoozePresetsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            expandedHeight: 100,
            collapsedHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(
                kSpaceMD,
                0,
                kSpaceMD,
                kSpaceMD,
              ),
              title: Text(
                'Settings',
                style: getTitleStyle(
                  ref.watch(fontFamilyProvider),
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          settingsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error: $e',
                  style: TextStyle(color: kFreshnessLow),
                ),
              ),
            ),
            data: (settings) {
              final halfLife = settings?.halfLifeDays ?? kDefaultHalfLifeDays;
              final threshold =
                  settings?.notificationThreshold ??
                  kDefaultNotificationThreshold;
              final notificationsOn =
                  settings?.notificationsEnabled ??
                  kDefaultNotificationsEnabled;
              final themePalette = settings?.themePalette ?? 'warm_stone';
              final swipeLeft = settings?.swipeLeftAction ?? 'archive';
              final swipeRight = settings?.swipeRightAction ?? 'read';
              final decayCurve = settings?.decayCurveType ?? 'exponential';

              return SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: kSpaceSM),

                  // ── Lifespan & Snooze Presets ──────────────────────────
                  const SectionHeader(label: 'Lifespan & Decay'),
                  SettingCard(
                    children: [
                      SliderRow(
                        icon: Icons.timer_outlined,
                        label: 'Default lifespan',
                        sublabel:
                            'Base duration before a link reaches stale status',
                        value: (halfLife * 2).clamp(2.0, 60.0),
                        min: 2,
                        max: 60,
                        divisions: 58,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(halfLifeDays: v / 2.0);
                        },
                        valueLabel: '${(halfLife * 2).toStringAsFixed(0)} days',
                      ),
                      const Divider(height: 0),
                      SliderRow(
                        icon: Icons.auto_stories_outlined,
                        label: 'Daily reading goal',
                        sublabel: 'Target number of links to read per day',
                        value: (settings?.dailyReadingGoal ?? 2).toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(dailyReadingGoal: v.round());
                        },
                        valueLabel:
                            '${(settings?.dailyReadingGoal ?? 2)} links',
                      ),
                      const Divider(height: 0),
                      DropdownRow(
                        icon: Icons.show_chart_outlined,
                        label: 'Decay Curve Algorithm',
                        sublabel: 'How freshness score decays over time',
                        value: decayCurve,
                        items: const [
                          DropdownMenuItem(
                            value: 'exponential',
                            child: Text('Exponential (Standard)'),
                          ),
                          DropdownMenuItem(
                            value: 'linear',
                            child: Text('Linear'),
                          ),
                        ],
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(decayCurveType: v);
                        },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.snooze_outlined,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Snooze Durations Presets',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${snoozePresets.join(", ")} days',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: cs.onSurface,
                        ),
                        onTap: () => showSnoozePresetsDialog(context, ref, snoozePresets),
                      ),
                    ],
                  ),

                  // ── Interface & Appearance ─────────────────────────────
                  const SectionHeader(label: 'Interface & Appearance'),
                  SettingCard(
                    children: [
                      SwitchRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark mode',
                        sublabel: 'Easier on the eyes at night',
                        value: settings?.isDarkMode ?? true,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(isDarkMode: v);
                        },
                      ),
                      const Divider(height: 0),
                      DropdownRow(
                        icon: Icons.palette_outlined,
                        label: 'Theme Accent Palette',
                        sublabel: 'Choose neutral aesthetic palette style',
                        value: themePalette,
                        items: const [
                          DropdownMenuItem(
                            value: 'warm_stone',
                            child: Text('Warm Stone (Original)'),
                          ),
                          DropdownMenuItem(
                            value: 'cold_slate',
                            child: Text('Cold Slate'),
                          ),
                          DropdownMenuItem(
                            value: 'forest_moss',
                            child: Text('Forest Moss'),
                          ),
                          DropdownMenuItem(
                            value: 'pitch_charcoal',
                            child: Text('Pitch Charcoal'),
                          ),
                        ],
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(themePalette: v);
                        },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.colorize_outlined,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Custom Accent Color',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          settings?.customAccentColor ?? 'Using palette accent',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (settings?.customAccentColor != null)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: parseHexColor(
                                    settings?.customAccentColor,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.outline,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: cs.onSurface,
                            ),
                          ],
                        ),
                        onTap: () => showCustomColorDialog(
                          context,
                          ref,
                          isAccent: true,
                          currentHex: settings?.customAccentColor,
                        ),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.wallpaper_outlined,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Custom Background Color',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          settings?.customBgColor ?? 'Using palette background',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (settings?.customBgColor != null)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: parseHexColor(settings?.customBgColor),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.outline,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: cs.onSurface,
                            ),
                          ],
                        ),
                        onTap: () => showCustomColorDialog(
                          context,
                          ref,
                          isAccent: false,
                          currentHex: settings?.customBgColor,
                        ),
                      ),
                      const Divider(height: 0),
                      DropdownRow(
                        icon: Icons.font_download_outlined,
                        label: 'Font Family',
                        sublabel: 'Aesthetic typography style',
                        value: settings?.fontFamily ?? 'inter',
                        items: const [
                          DropdownMenuItem(
                            value: 'inter',
                            child: Text('Inter'),
                          ),
                          DropdownMenuItem(
                            value: 'outfit',
                            child: Text('Outfit'),
                          ),
                          DropdownMenuItem(
                            value: 'playfair display',
                            child: Text('Playfair Display'),
                          ),
                          DropdownMenuItem(
                            value: 'jetbrains mono',
                            child: Text('JetBrains Mono'),
                          ),
                        ],
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(fontFamily: v);
                        },
                      ),
                    ],
                  ),

                  // ── Interaction & Gestures ─────────────────────────────
                  const SectionHeader(label: 'Gestures & Interaction'),
                  SettingCard(
                    children: [
                      DropdownRow(
                        icon: Icons.swipe_right_alt_outlined,
                        label: 'Swipe Right Action',
                        sublabel: 'Action on swiping right to left',
                        value: swipeRight,
                        items: const [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text('No Action'),
                          ),
                          DropdownMenuItem(
                            value: 'read',
                            child: Text('Mark as Read'),
                          ),
                          DropdownMenuItem(
                            value: 'archive',
                            child: Text('Archive'),
                          ),
                          DropdownMenuItem(
                            value: 'snooze',
                            child: Text('Snooze link'),
                          ),
                          DropdownMenuItem(
                            value: 'collection',
                            child: Text('Move to Folder'),
                          ),
                          DropdownMenuItem(
                            value: 'delete',
                            child: Text('Delete link'),
                          ),
                        ],
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(swipeRightAction: v);
                        },
                      ),
                      const Divider(height: 0),
                      DropdownRow(
                        icon: Icons.swipe_left_alt_outlined,
                        label: 'Swipe Left Action',
                        sublabel: 'Action on swiping left to right',
                        value: swipeLeft,
                        items: const [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text('No Action'),
                          ),
                          DropdownMenuItem(
                            value: 'read',
                            child: Text('Mark as Read'),
                          ),
                          DropdownMenuItem(
                            value: 'archive',
                            child: Text('Archive'),
                          ),
                          DropdownMenuItem(
                            value: 'snooze',
                            child: Text('Snooze link'),
                          ),
                          DropdownMenuItem(
                            value: 'collection',
                            child: Text('Move to Folder'),
                          ),
                          DropdownMenuItem(
                            value: 'delete',
                            child: Text('Delete link'),
                          ),
                        ],
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(swipeLeftAction: v);
                        },
                      ),
                    ],
                  ),

                  // ── Notifications ────────────────────────────────────
                  const SectionHeader(label: 'Notifications & Reminders'),
                  SettingCard(
                    children: [
                      SwitchRow(
                        icon: Icons.notifications_outlined,
                        label: 'Daily reminders',
                        sublabel: 'Notified at 9 AM if links are stale',
                        value: notificationsOn,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(notificationsEnabled: v);
                        },
                      ),
                      const Divider(height: 0),
                      SliderRow(
                        icon: Icons.warning_amber_outlined,
                        label: 'Alert threshold',
                        sublabel:
                            'Notify when freshness drops below ${(threshold * 100).toStringAsFixed(0)}%',
                        value: threshold,
                        min: 0.05,
                        max: 0.9,
                        divisions: 17,
                        onChanged: (v) {
                          ref
                              .read(linkActionsProvider.notifier)
                              .updateSettings(notificationThreshold: v);
                        },
                        valueLabel: '${(threshold * 100).toStringAsFixed(0)}%',
                      ),
                    ],
                  ),

                  // ── Lifespan Overrides ────────────────────────────────
                  const SectionHeader(label: 'Lifespan Overrides'),
                  SettingCard(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.dns_outlined,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Domain-Specific Lifespan',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${domainOverrides.length} domain overrides configured',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                        trailing: Icon(
                          Icons.add,
                          size: 20,
                          color: cs.onSurface,
                        ),
                        onTap: () => showDomainOverrideDialog(context, ref, domainOverrides),
                      ),
                      if (domainOverrides.isNotEmpty) ...[
                        const Divider(height: 0),
                        ...domainOverrides.entries.map((e) {
                          return ListTile(
                            title: Text(
                              e.key,
                              style: getFontTextStyle(
                                ref.watch(fontFamilyProvider),
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              'Lifespan: ${(e.value * 2).toStringAsFixed(0)} days',
                              style: getFontTextStyle(
                                ref.watch(fontFamilyProvider),
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: kFreshnessLow,
                              ),
                              onPressed: () {
                                final updated = Map<String, double>.from(
                                  domainOverrides,
                                )..remove(e.key);
                                ref
                                    .read(linkActionsProvider.notifier)
                                    .updateSettings(
                                      domainHalfLifeOverrides: jsonEncode(
                                        updated,
                                      ),
                                    );
                                HapticFeedback.lightImpact();
                              },
                            ),
                          );
                        }),
                      ],
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.tag,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Tag-Specific Lifespan',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${tagOverrides.length} tag overrides configured',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                        trailing: Icon(
                          Icons.add,
                          size: 20,
                          color: cs.onSurface,
                        ),
                        onTap: () => showTagOverrideDialog(context, ref, tagOverrides),
                      ),
                      if (tagOverrides.isNotEmpty) ...[
                        const Divider(height: 0),
                        ...tagOverrides.entries.map((e) {
                          return ListTile(
                            title: Text(
                              '#${e.key}',
                              style: getFontTextStyle(
                                ref.watch(fontFamilyProvider),
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              'Lifespan: ${(e.value * 2).toStringAsFixed(0)} days',
                              style: getFontTextStyle(
                                ref.watch(fontFamilyProvider),
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: kFreshnessLow,
                              ),
                              onPressed: () {
                                final updated = Map<String, double>.from(
                                  tagOverrides,
                                )..remove(e.key);
                                ref
                                    .read(linkActionsProvider.notifier)
                                    .updateSettings(
                                      tagHalfLifeOverrides: jsonEncode(updated),
                                    );
                                HapticFeedback.lightImpact();
                              },
                            ),
                          );
                        }),
                      ],
                    ],
                  ),

                  // ── Data Tools ────────────────────────────────────────
                  const SectionHeader(label: 'Data & Backup'),
                  SettingCard(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.file_upload_outlined,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Export JSON Backup',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 14,
                            color: cs.onSurface,
                          ),
                        ),
                        onTap: _backupJson,
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.file_download_outlined,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Import JSON Backup',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 14,
                            color: cs.onSurface,
                          ),
                        ),
                        onTap: _importJson,
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.bookmark_outline,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Export Bookmarks (HTML)',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 14,
                            color: cs.onSurface,
                          ),
                        ),
                        onTap: _backupHtml,
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.bookmark_add_outlined,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Import Bookmarks (HTML)',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 14,
                            color: cs.onSurface,
                          ),
                        ),
                        onTap: _importHtml,
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.health_and_safety_outlined,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Run Link Health Check',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 14,
                            color: cs.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Scan saved links for dead or broken pages',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                        onTap: _runHealthCheck,
                      ),
                    ],
                  ),

                  // ── About & Contact Developer ──────────────────────────
                  const SectionHeader(label: 'About & Contact'),
                  SettingCard(
                    children: [
                      const InfoRow(label: 'App Name', value: kAppName),
                      const Divider(height: 0),
                      const InfoRow(label: 'Version', value: kAppVersion),
                      const Divider(height: 0),
                      const InfoRow(label: 'Storage', value: 'Local SQLite (Drift)'),
                      const Divider(height: 0),
                      const InfoRow(label: 'License', value: 'MIT (Open Source)'),
                      const Divider(height: 0),
                      ListTile(
                        leading: Icon(
                          Icons.mail_outline,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          'Contact Developer',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 14,
                            color: cs.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Report bugs or request features',
                          style: getFontTextStyle(
                            ref.watch(fontFamilyProvider),
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                        trailing: Icon(
                          Icons.launch,
                          size: 16,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        onTap: _contactDeveloper,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Crafted with ☕ in Kolkata 🤍',
                      style: getFontTextStyle(
                        ref.watch(fontFamilyProvider),
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}
