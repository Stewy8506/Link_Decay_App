import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/database.dart';
import '../models/link_status.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';
import '../widgets/link_card.dart';
import '../widgets/add_link_sheet.dart';
import 'archive_screen.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateCollectionDialog(BuildContext context) {
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
                decoration: const InputDecoration(
                  labelText: 'Emoji Icon',
                  hintText: 'e.g. 📁, 📚, 💼',
                ),
                style: const TextStyle(fontSize: 20),
                maxLength: 2,
              ),
              const SizedBox(height: kSpaceSM),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'e.g. Tech, Cook, Work',
                ),
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
                  ref.read(linkActionsProvider.notifier).addCollection(
                        name,
                        emoji.isNotEmpty ? emoji : '📁',
                      );
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Create',
                style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header Tab Switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceMD, kSpaceMD, kSpaceSM),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.outline, width: 0.5),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: isDark
                        ? cs.outline.withValues(alpha: 0.6)
                        : cs.outline.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  labelColor: cs.onSurface,
                  unselectedLabelColor: cs.onSurface.withValues(alpha: 0.45),
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Folders'),
                    Tab(text: 'Archive'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FoldersTab(onCreatePressed: () => _showCreateCollectionDialog(context)),
                  const ArchiveScreen(), // Embedded archive
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoldersTab extends ConsumerWidget {
  const _FoldersTab({required this.onCreatePressed});
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final allLinksAsync = ref.watch(allLinksProvider);

    return collectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (folders) {
        final allLinks = allLinksAsync.valueOrNull ?? [];

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(kSpaceMD),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: kSpaceMD,
                  mainAxisSpacing: kSpaceMD,
                  childAspectRatio: 1.15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == folders.length) {
                      // Create New Folder Card
                      return _CreateFolderCard(onTap: onCreatePressed);
                    }

                    final folder = folders[index];
                    // Compute link counts in inbox
                    final folderInboxLinks = allLinks
                        .where((l) => l.collectionId == folder.id && l.status == LinkStatus.inbox)
                        .toList();

                    return _FolderCard(
                      collection: folder,
                      inboxCount: folderInboxLinks.length,
                      links: folderInboxLinks,
                    );
                  },
                  childCount: folders.length + 1,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 120), // Padding for Floating Navbar
            ),
          ],
        );
      },
    );
  }
}

class _FolderCard extends ConsumerWidget {
  const _FolderCard({
    required this.collection,
    required this.inboxCount,
    required this.links,
  });

  final Collection collection;
  final int inboxCount;
  final List<Link> links;

  void _showFolderOptions(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    HapticFeedback.mediumImpact();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(kSpaceMD),
                child: Text(
                  'Folder Options',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const Divider(height: 0),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: cs.onSurface),
                title: Text('Rename Folder', style: GoogleFonts.inter(color: cs.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, ref);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: kFreshnessLow),
                title: Text('Delete Folder', style: GoogleFonts.inter(color: kFreshnessLow)),
                subtitle: const Text('Links will be moved back to general Inbox'),
                onTap: () {
                  ref.read(linkActionsProvider.notifier).deleteCollection(collection.id);
                  Navigator.pop(context);
                  HapticFeedback.heavyImpact();
                },
              ),
              const SizedBox(height: kSpaceSM),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: collection.name);
    final emojiController = TextEditingController(text: collection.emoji ?? '📁');

    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Edit Folder', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final emoji = emojiController.text.trim();
                if (name.isNotEmpty) {
                  ref.read(linkActionsProvider.notifier).updateCollection(
                        collection.id,
                        name,
                        emoji.isNotEmpty ? emoji : '📁',
                      );
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                }
              },
              child: Text('Save', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Calculate freshness indicator if items are present
    double avgFreshness = 1.0;
    if (links.isNotEmpty) {
      final baseHalfLife = ref.watch(halfLifeDaysProvider);
      final now = DateTime.now();
      double sum = 0.0;
      for (final l in links) {
        sum += computeFreshness(
          createdAt: l.createdAt,
          now: now,
          halfLifeDays: l.customHalfLifeDays ?? baseHalfLife,
          snoozedUntil: l.snoozedUntil,
        );
      }
      avgFreshness = sum / links.length;
    }

    final freshColor = avgFreshness > 0.66
        ? kFreshnessHigh
        : avgFreshness > 0.33
            ? kFreshnessMid
            : kFreshnessLow;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => CollectionDetailScreen(collection: collection),
            ),
          );
        },
        onLongPress: () => _showFolderOptions(context, ref),
        borderRadius: BorderRadius.circular(kRadiusMD),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(kRadiusMD),
            border: Border.all(color: cs.outline, width: 0.5),
          ),
          padding: const EdgeInsets.all(kSpaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Emoji Icon + Link Count Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    collection.emoji ?? '📁',
                    style: const TextStyle(fontSize: 26),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.outline.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$inboxCount',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Area: Title + Freshness Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (links.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: freshColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Avg Freshness: ${(avgFreshness * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'Empty folder',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateFolderCard extends StatelessWidget {
  const _CreateFolderCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusMD),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(kRadiusMD),
            border: Border.all(color: cs.outline, width: 1.0, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.create_new_folder_outlined, color: cs.onSurface.withValues(alpha: 0.4), size: 28),
              const SizedBox(height: kSpaceSM),
              Text(
                'Add Folder',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Collection Detail Screen ──────────────────────────────────────────────

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({super.key, required this.collection});
  final Collection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all inbox links and filter for this collection
    final linksAsync = ref.watch(inboxLinksProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${collection.emoji ?? "📁"} ${collection.name}'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: linksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allInbox) {
          final folderLinks = allInbox.where((l) => l.collectionId == collection.id).toList();

          if (folderLinks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_outlined, size: 64, color: cs.onSurface.withValues(alpha: 0.25)),
                  const SizedBox(height: kSpaceMD),
                  Text(
                    'No links in this folder',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: folderLinks.length + 1,
            padding: const EdgeInsets.only(top: kSpaceSM),
            itemBuilder: (context, i) {
              if (i == folderLinks.length) {
                return const SizedBox(height: 100);
              }
              return LinkCard(key: ValueKey(folderLinks[i].id), link: folderLinks[i]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (_) => AddLinkSheet(preSelectedCollectionId: collection.id),
            isScrollControlled: true,
            useSafeArea: true,
          );
        },
        backgroundColor: cs.onSurface,
        foregroundColor: cs.surface,
        elevation: 0,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'Add link',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusXL),
        ),
      ),
    );
  }
}
