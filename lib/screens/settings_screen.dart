import 'dart:convert';
import 'dart:io' hide Link;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:drift/drift.dart' show Value;
import '../app_theme.dart' show parseHexColor, getTitleStyle, getFontTextStyle;
import '../data/database.dart';
import '../models/link_status.dart';
import '../providers/providers.dart';
import '../services/export_service.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

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
        return _HealthCheckProgressDialog(links: links, db: db);
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

  // ── Decay Overrides Editors ──────────────────────────────────────────────

  void _addDomainOverrideDialog(Map<String, double> current) {
    final domainController = TextEditingController();
    double days = 14.0;

    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'Domain Lifespan Override',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: domainController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. youtube.com',
                      labelText: 'Domain Name',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: kSpaceMD),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Link Lifespan',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      Text(
                        '${days.toStringAsFixed(0)} days',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Slider(
                    value: days,
                    min: 2,
                    max: 60,
                    divisions: 58,
                    onChanged: (v) => setState(() => days = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final dom = domainController.text.trim().toLowerCase();
                    if (dom.isNotEmpty) {
                      final updated = Map<String, double>.from(current)
                        ..[dom] = days / 2.0;
                      ref
                          .read(linkActionsProvider.notifier)
                          .updateSettings(
                            domainHalfLifeOverrides: jsonEncode(updated),
                          );
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addTagOverrideDialog(Map<String, double> current) {
    final tagController = TextEditingController();
    double days = 14.0;

    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'Tag Lifespan Override',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. news',
                      labelText: 'Tag Name',
                    ),
                  ),
                  const SizedBox(height: kSpaceMD),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Link Lifespan',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      Text(
                        '${days.toStringAsFixed(0)} days',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Slider(
                    value: days,
                    min: 2,
                    max: 60,
                    divisions: 58,
                    onChanged: (v) => setState(() => days = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final t = tagController.text.trim().toLowerCase();
                    if (t.isNotEmpty) {
                      final updated = Map<String, double>.from(current)
                        ..[t] = days / 2.0;
                      ref
                          .read(linkActionsProvider.notifier)
                          .updateSettings(
                            tagHalfLifeOverrides: jsonEncode(updated),
                          );
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editSnoozePresetsDialog(List<int> current) {
    List<int> tempPresets = List<int>.from(current)..sort();

    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'Edit Snooze Presets',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select duration values (in days) that will be displayed in the link snooze panel.',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tempPresets.map((days) {
                        return Chip(
                          label: Text('$days ${days == 1 ? "day" : "days"}'),
                          onDeleted: tempPresets.length <= 1
                              ? null
                              : () {
                                  setState(() {
                                    tempPresets.remove(days);
                                  });
                                },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add preset duration:',
                            style: TextStyle(fontSize: 13, color: cs.onSurface),
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Day'),
                          onPressed: () {
                            int next = 1;
                            while (tempPresets.contains(next)) {
                              next++;
                            }
                            if (next <= 30) {
                              setState(() {
                                tempPresets.add(next);
                                tempPresets.sort();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(linkActionsProvider.notifier)
                        .updateSettings(snoozePresets: jsonEncode(tempPresets));
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openCustomColorDialog({
    required bool isAccent,
    required String? currentHex,
  }) {
    final hexController = TextEditingController(text: currentHex ?? '');
    final errorState = ValueNotifier<String?>(null);

    final presetColors = isAccent
        ? [
            '#EC4899', // Rose
            '#14B8A6', // Teal
            '#F59E0B', // Amber
            '#6366F1', // Indigo
            '#3B82F6', // Blue
            '#10B981', // Emerald
          ]
        : [
            '#09090B', // Dark Zinc
            '#0D1117', // Github Dark
            '#0F172A', // Slate Dark
            '#1E1E2E', // Mocha Catppuccin
            '#FAF9F6', // Warm Alabaster
            '#F3F4F6', // Soft Light Grey
          ];

    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            isAccent ? 'Custom Accent Color' : 'Custom Background Color',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAccent
                    ? 'Select a preset or enter a custom hex color for buttons and highlights.'
                    : 'Select a preset or enter a custom hex color for the screen background.',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: presetColors.map((hex) {
                          final color = parseHexColor(hex);
                          final isSelected =
                              hexController.text.toUpperCase() ==
                              hex.toUpperCase();
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                hexController.text = hex;
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? cs.onSurface
                                      : cs.outline.withValues(alpha: 0.3),
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<String?>(
                        valueListenable: errorState,
                        builder: (context, error, _) {
                          return TextField(
                            controller: hexController,
                            decoration: InputDecoration(
                              hintText: 'e.g. #FF5733',
                              labelText: 'Hex Color Code',
                              errorText: error,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (val) {
                              setDialogState(() {});
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (isAccent) {
                  ref
                      .read(linkActionsProvider.notifier)
                      .updateSettings(customAccentColor: const Value(null));
                } else {
                  ref
                      .read(linkActionsProvider.notifier)
                      .updateSettings(customBgColor: const Value(null));
                }
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
              ),
            ),
            TextButton(
              onPressed: () {
                final input = hexController.text.trim();
                if (input.isEmpty) {
                  errorState.value = 'Color code cannot be empty';
                  return;
                }
                final parsed = parseHexColor(input);
                if (parsed == null) {
                  errorState.value = 'Invalid Hex format (e.g. #FF5733)';
                  return;
                }

                if (isAccent) {
                  ref
                      .read(linkActionsProvider.notifier)
                      .updateSettings(customAccentColor: Value(input));
                } else {
                  ref
                      .read(linkActionsProvider.notifier)
                      .updateSettings(customBgColor: Value(input));
                }
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
              child: Text(
                'Apply',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
                  _SectionHeader(label: 'Lifespan & Decay'),
                  _SettingCard(
                    children: [
                      _SliderRow(
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
                      const _Divider(),
                      _SliderRow(
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
                      const _Divider(),
                      _DropdownRow(
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
                      const _Divider(),
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
                        onTap: () => _editSnoozePresetsDialog(snoozePresets),
                      ),
                    ],
                  ),

                  // ── Interface & Appearance ─────────────────────────────
                  _SectionHeader(label: 'Interface & Appearance'),
                  _SettingCard(
                    children: [
                      _SwitchRow(
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
                      const _Divider(),
                      _DropdownRow(
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
                      const _Divider(),
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
                        onTap: () => _openCustomColorDialog(
                          isAccent: true,
                          currentHex: settings?.customAccentColor,
                        ),
                      ),
                      const _Divider(),
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
                        onTap: () => _openCustomColorDialog(
                          isAccent: false,
                          currentHex: settings?.customBgColor,
                        ),
                      ),
                      const _Divider(),
                      _DropdownRow(
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
                  _SectionHeader(label: 'Gestures & Interaction'),
                  _SettingCard(
                    children: [
                      _DropdownRow(
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
                      const _Divider(),
                      _DropdownRow(
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
                  _SectionHeader(label: 'Notifications & Reminders'),
                  _SettingCard(
                    children: [
                      _SwitchRow(
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
                      const _Divider(),
                      _SliderRow(
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
                  _SectionHeader(label: 'Lifespan Overrides'),
                  _SettingCard(
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
                        onTap: () => _addDomainOverrideDialog(domainOverrides),
                      ),
                      if (domainOverrides.isNotEmpty) ...[
                        const _Divider(),
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
                      const _Divider(),
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
                        onTap: () => _addTagOverrideDialog(tagOverrides),
                      ),
                      if (tagOverrides.isNotEmpty) ...[
                        const _Divider(),
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
                  _SectionHeader(label: 'Data & Backup'),
                  _SettingCard(
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
                      const _Divider(),
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
                      const _Divider(),
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
                      const _Divider(),
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
                      const _Divider(),
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
                  _SectionHeader(label: 'About & Contact'),
                  _SettingCard(
                    children: [
                      _InfoRow(label: 'App Name', value: kAppName),
                      const _Divider(),
                      _InfoRow(label: 'Version', value: kAppVersion),
                      const _Divider(),
                      _InfoRow(label: 'Storage', value: 'Local SQLite (Drift)'),
                      const _Divider(),
                      _InfoRow(label: 'License', value: 'MIT (Open Source)'),
                      const _Divider(),
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
                      'Crafted with ☕ & 🤍',
                      style: getFontTextStyle(
                        ref.watch(fontFamilyProvider),
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 140),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Sub-components ───────────────────────────────────────────────────────

class _SectionHeader extends ConsumerWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kSpaceMD,
        kSpaceLG,
        kSpaceMD,
        kSpaceSM,
      ),
      child: Text(
        label.toUpperCase(),
        style: getFontTextStyle(
          ref.watch(fontFamilyProvider),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cs.onSurface.withValues(alpha: 0.3),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpaceMD),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 0);
  }
}

class _SliderRow extends ConsumerWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.valueLabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String valueLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final font = ref.watch(fontFamilyProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kSpaceMD,
        kSpaceMD,
        kSpaceMD,
        kSpaceSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.45)),
              const SizedBox(width: kSpaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: getFontTextStyle(
                        font,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: getFontTextStyle(
                        font,
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  valueLabel,
                  style: getFontTextStyle(
                    font,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends ConsumerWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final font = ref.watch(fontFamilyProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.45)),
          const SizedBox(width: kSpaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: getFontTextStyle(
                    font,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  sublabel,
                  style: getFontTextStyle(
                    font,
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DropdownRow extends ConsumerWidget {
  const _DropdownRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final font = ref.watch(fontFamilyProvider);
    final selectedText = items
        .firstWhere(
          (item) => item.value == value,
          orElse: () => DropdownMenuItem(value: value, child: Text(value)),
        )
        .child;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.45)),
          const SizedBox(width: kSpaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: getFontTextStyle(
                    font,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  sublabel,
                  style: getFontTextStyle(
                    font,
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: kSpaceSM),
          PopupMenuButton<String>(
            initialValue: value,
            onSelected: onChanged,
            itemBuilder: (context) {
              return items.map((item) {
                return PopupMenuItem<String>(
                  value: item.value,
                  child: item.child,
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: cs.outline, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: getFontTextStyle(
                      font,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                    child: selectedText,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCheckProgressDialog extends StatefulWidget {
  const _HealthCheckProgressDialog({required this.links, required this.db});
  final List<Link> links;
  final AppDatabase db;

  @override
  State<_HealthCheckProgressDialog> createState() =>
      _HealthCheckProgressDialogState();
}

class _HealthCheckProgressDialogState
    extends State<_HealthCheckProgressDialog> {
  int _currentIndex = 0;
  int _deadCount = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    final client = http.Client();
    for (int i = 0; i < widget.links.length; i++) {
      if (!mounted) break;
      setState(() {
        _currentIndex = i + 1;
      });

      final link = widget.links[i];
      bool isDead = false;

      try {
        final uri = Uri.parse(link.url);
        final response = await client
            .head(uri)
            .timeout(const Duration(seconds: 3));
        if (response.statusCode == 404 || response.statusCode >= 500) {
          isDead = true;
        }
      } catch (_) {
        try {
          final uri = Uri.parse(link.url);
          final response = await client
              .get(uri)
              .timeout(const Duration(seconds: 3));
          if (response.statusCode == 404 || response.statusCode >= 500) {
            isDead = true;
          }
        } catch (_) {
          isDead = true;
        }
      }

      if (isDead) {
        _deadCount++;
        await widget.db.updateLinkDeadStatus(link.id, true);
      } else {
        await widget.db.updateLinkDeadStatus(link.id, false);
      }
    }
    client.close();

    if (mounted) {
      setState(() {
        _isFinished = true;
      });
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        _isFinished ? 'Scan Complete' : 'Checking Link Health...',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!_isFinished) ...[
            const SizedBox(height: 8),
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 20),
            Text(
              'Scanning $_currentIndex of ${widget.links.length} links...',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ] else ...[
            Text(
              'Found $_deadCount dead or unreachable link${_deadCount == 1 ? "" : "s"} out of ${widget.links.length} links scanned.',
              style: GoogleFonts.inter(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Dead links have been flagged with a ☠️ badge in your inbox.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        if (_isFinished)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
      ],
    );
  }
}

class _InfoRow extends ConsumerWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final font = ref.watch(fontFamilyProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: getFontTextStyle(
              font,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: getFontTextStyle(
              font,
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
