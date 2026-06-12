import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' show Value;
import '../app_theme.dart' show parseHexColor;
import '../providers/providers.dart';
import '../utils/constants.dart';

void showDomainOverrideDialog(
  BuildContext context,
  WidgetRef ref,
  Map<String, double> current,
) {
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
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
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

void showTagOverrideDialog(
  BuildContext context,
  WidgetRef ref,
  Map<String, double> current,
) {
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
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
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

void showSnoozePresetsDialog(
  BuildContext context,
  WidgetRef ref,
  List<int> current,
) {
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
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
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

void showCustomColorDialog(
  BuildContext context,
  WidgetRef ref, {
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
