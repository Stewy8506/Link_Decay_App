import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';

class MultiSelectBar extends ConsumerWidget {
  const MultiSelectBar({super.key});

  void _showAddTagDialog(BuildContext context, WidgetRef ref, Set<String> ids) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Add Tag to Selected', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'e.g. readlater'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
            ),
            TextButton(
              onPressed: () {
                final tag = controller.text.trim();
                if (tag.isNotEmpty) {
                  ref.read(linkActionsProvider.notifier).bulkAddTag(ids, tag);
                  ref.read(selectedLinkIdsProvider.notifier).state = const {};
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                }
              },
              child: Text('Add', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showFolderPicker(BuildContext context, WidgetRef ref, Set<String> ids) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.65,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(kSpaceMD),
                  child: Text(
                    'Move Selected to Folder',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.folder_off_outlined, color: cs.onSurface.withValues(alpha: 0.6)),
                  title: Text('No Folder (Uncategorized)', style: GoogleFonts.inter(color: cs.onSurface)),
                  onTap: () {
                    ref.read(linkActionsProvider.notifier).bulkMoveToCollection(ids, null);
                    ref.read(selectedLinkIdsProvider.notifier).state = const {};
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  },
                ),
                const Divider(height: 0),
                Expanded(
                  child: collectionsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => const SizedBox.shrink(),
                    data: (folders) {
                      return ListView.builder(
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          return ListTile(
                            leading: Text(folder.emoji ?? '📁', style: const TextStyle(fontSize: 16)),
                            title: Text(folder.name, style: GoogleFonts.inter(color: cs.onSurface)),
                            onTap: () {
                              ref.read(linkActionsProvider.notifier).bulkMoveToCollection(ids, folder.id);
                              ref.read(selectedLinkIdsProvider.notifier).state = const {};
                              Navigator.pop(context);
                              HapticFeedback.mediumImpact();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: kSpaceSM),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Set<String> ids) {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Delete Selected Links?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          content: Text('Are you sure you want to delete ${ids.length} selected links permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
            ),
            TextButton(
              onPressed: () {
                ref.read(linkActionsProvider.notifier).bulkDelete(ids);
                ref.read(selectedLinkIdsProvider.notifier).state = const {};
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
    final selectedIds = ref.watch(selectedLinkIdsProvider);
    final isVisible = selectedIds.isNotEmpty;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final barBg = cs.surfaceContainerHighest.withValues(alpha: 0.95);
    final barBorder = cs.outline.withValues(alpha: 0.6);

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedSlide(
        offset: isVisible ? Offset.zero : const Offset(0, 1.5),
        duration: kDurationNormal,
        curve: Curves.easeInOut,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
            ),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: barBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: barBorder, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
              child: Row(
                children: [
                  // Count Indicator
                  Flexible(
                    child: Text(
                      '${selectedIds.length} selected',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Bulk Actions Strip
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    tooltip: 'Mark as Read',
                    onPressed: () {
                      ref.read(linkActionsProvider.notifier).bulkMarkRead(selectedIds);
                      ref.read(selectedLinkIdsProvider.notifier).state = const {};
                      HapticFeedback.mediumImpact();
                    },
                  ),
                  _ActionButton(
                    icon: Icons.archive_outlined,
                    tooltip: 'Archive All',
                    onPressed: () {
                      ref.read(linkActionsProvider.notifier).bulkArchive(selectedIds);
                      ref.read(selectedLinkIdsProvider.notifier).state = const {};
                      HapticFeedback.mediumImpact();
                    },
                  ),
                  _ActionButton(
                    icon: Icons.folder_outlined,
                    tooltip: 'Move to Folder',
                    onPressed: () => _showFolderPicker(context, ref, selectedIds),
                  ),
                  _ActionButton(
                    icon: Icons.label_outline,
                    tooltip: 'Add Tag',
                    onPressed: () => _showAddTagDialog(context, ref, selectedIds),
                  ),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete All',
                    color: kFreshnessLow,
                    onPressed: () => _confirmDelete(context, ref, selectedIds),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon),
      color: color ?? cs.onSurface,
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(),
    );
  }
}
