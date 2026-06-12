import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/google_fonts.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';

class CollectionPickerSheet extends ConsumerWidget {
  const CollectionPickerSheet({
    super.key,
    required this.linkId,
    this.currentCollectionId,
  });

  final String linkId;
  final String? currentCollectionId;

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController(text: '📁');

    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'New Folder',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emojiController,
                decoration: const InputDecoration(labelText: 'Emoji Icon'),
                style: const TextStyle(fontSize: 20),
                maxLength: 2,
              ),
              const SizedBox(height: kSpaceSM),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Folder Name'),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
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
                final name = nameController.text.trim();
                final emoji = emojiController.text.trim();
                if (name.isNotEmpty) {
                  ref
                      .read(linkActionsProvider.notifier)
                      .addCollection(name, emoji.isNotEmpty ? emoji : '📁');
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Create',
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
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(kRadiusLG),
          topRight: Radius.circular(kRadiusLG),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.65),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(kSpaceMD),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Move to Folder',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),

              // Option: Remove from folder
              ListTile(
                leading: Icon(
                  Icons.folder_off_outlined,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
                title: Text(
                  'No Folder (Uncategorized)',
                  style: GoogleFonts.inter(
                    color: cs.onSurface,
                    fontWeight: currentCollectionId == null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: currentCollectionId == null
                    ? Icon(Icons.check, color: cs.onSurface, size: 18)
                    : null,
                onTap: () {
                  ref
                      .read(linkActionsProvider.notifier)
                      .updateLinkCollection(linkId, null);
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 0),

              // Collections List
              Expanded(
                child: collectionsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(kSpaceLG),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(kSpaceLG),
                    child: Text('Error: $e'),
                  ),
                  data: (folders) {
                    if (folders.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: kSpaceXL),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No folders created yet.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: cs.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        final isSelected = folder.id == currentCollectionId;

                        return ListTile(
                          leading: Text(
                            folder.emoji ?? '📁',
                            style: const TextStyle(fontSize: 18),
                          ),
                          title: Text(
                            folder.name,
                            style: GoogleFonts.inter(
                              color: cs.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check, color: cs.onSurface, size: 18)
                              : null,
                          onTap: () {
                            ref
                                .read(linkActionsProvider.notifier)
                                .updateLinkCollection(linkId, folder.id);
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 0),

              // Bottom Add Action
              Padding(
                padding: const EdgeInsets.all(kSpaceMD),
                child: TextButton.icon(
                  onPressed: () => _showCreateCollectionDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Folder'),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
