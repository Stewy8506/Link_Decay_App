import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';
import '../screens/custom_filter_creator.dart';

class SmartListBar extends ConsumerWidget {
  const SmartListBar({super.key});

  void _confirmDeleteFilter(BuildContext context, WidgetRef ref, String id, String name) {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Delete Smart List?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
            ),
            TextButton(
              onPressed: () {
                // If deleting active filter, reset active selection first
                if (ref.read(selectedFilterIdProvider) == id) {
                  ref.read(selectedFilterIdProvider.notifier).state = null;
                }
                ref.read(linkActionsProvider.notifier).deleteCustomFilter(id);
                Navigator.pop(context);
                HapticFeedback.heavyImpact();
              },
              child: Text('Delete', style: TextStyle(color: kFreshnessLow, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customFiltersAsync = ref.watch(customFiltersProvider);
    final activeFilterId = ref.watch(selectedFilterIdProvider);
    final cs = Theme.of(context).colorScheme;

    return customFiltersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (filters) {
        return SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
            children: [
              // Default "All Inbox" Chip
              _SmartChip(
                icon: '📥',
                label: 'All Inbox',
                isSelected: activeFilterId == null,
                onTap: () {
                  ref.read(selectedFilterIdProvider.notifier).state = null;
                  HapticFeedback.lightImpact();
                },
              ),

              const SizedBox(width: kSpaceSM),

              // Custom Filter Chips
              ...filters.map((filter) {
                final isSelected = activeFilterId == filter.id;
                return Padding(
                  padding: const EdgeInsets.only(right: kSpaceSM),
                  child: _SmartChip(
                    icon: filter.icon,
                    label: filter.name,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedFilterIdProvider.notifier).state = filter.id;
                      HapticFeedback.lightImpact();
                    },
                    onLongPress: () => _confirmDeleteFilter(context, ref, filter.id, filter.name),
                  ),
                );
              }),

              // Add New List Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomFilterCreatorScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outline, width: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 14, color: cs.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          'New List',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: cs.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SmartChip extends StatelessWidget {
  const _SmartChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: kDurationFast,
      decoration: BoxDecoration(
        color: isSelected ? cs.onSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : cs.outline,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? cs.surface
                      : cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
