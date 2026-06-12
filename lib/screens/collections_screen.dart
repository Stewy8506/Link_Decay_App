import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/google_fonts.dart';

import '../models/models.dart';
import '../models/link_status.dart';
import '../providers/providers.dart';
import '../services/export_service.dart';
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
    final isWide = MediaQuery.of(context).size.width > 600;

    return collectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (folders) {
        if (folders.isEmpty) {
          return _EmptyFoldersView(onCreatePressed: onCreatePressed);
        }

        final allLinks = allLinksAsync.valueOrNull ?? [];
        final baseHalfLife = ref.watch(halfLifeDaysProvider);
        final decayCurveType = ref.watch(decayCurveTypeProvider);
        final now = DateTime.now();

        // Stats calculations
        int organizedCount = 0;
        int uncategorizedCount = 0;
        double freshnessSum = 0.0;

        for (final l in allLinks) {
          if (l.status == LinkStatus.inbox) {
            final score = computeFreshness(
              createdAt: l.createdAt,
              now: now,
              halfLifeDays: l.customHalfLifeDays ?? baseHalfLife,
              snoozedUntil: l.snoozedUntil,
              decayCurveType: decayCurveType,
            );
            if (l.collectionId != null) {
              organizedCount++;
              freshnessSum += score;
            } else {
              uncategorizedCount++;
            }
          }
        }

        final avgFreshness = organizedCount > 0 ? (freshnessSum / organizedCount) : 1.0;
        final freshColor = avgFreshness > 0.66
            ? kFreshnessHigh
            : avgFreshness > 0.33
                ? kFreshnessMid
                : kFreshnessLow;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Dashboard Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: kSpaceSM),
                child: _FoldersDashboardPanel(
                  folderCount: folders.length,
                  organizedCount: organizedCount,
                  uncategorizedCount: uncategorizedCount,
                  avgFreshness: avgFreshness,
                  freshnessColor: freshColor,
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceMD, kSpaceMD, kSpaceMD),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide 
                      ? ((MediaQuery.of(context).size.width - 240) / 220).floor().clamp(2, 6) 
                      : 2,
                  crossAxisSpacing: kSpaceMD,
                  mainAxisSpacing: kSpaceMD,
                  childAspectRatio: isWide ? 1.25 : 1.15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Widget card;
                    if (index == folders.length) {
                      // Create New Folder Card
                      card = _CreateFolderCard(onTap: onCreatePressed);
                    } else {
                      final folder = folders[index];
                      // Compute link counts in inbox
                      final folderInboxLinks = allLinks
                          .where((l) => l.collectionId == folder.id && l.status == LinkStatus.inbox)
                          .toList();

                      card = _FolderCard(
                        collection: folder,
                        inboxCount: folderInboxLinks.length,
                        links: folderInboxLinks,
                      );
                    }

                    // Staggered-like entry animation
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 60).clamp(0, 300)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: card,
                    );
                  },
                  childCount: folders.length + 1,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: isWide ? 40 : 120),
            ),
          ],
        );
      },
    );
  }
}

// ─── Folders Dashboard Panel ──────────────────────────────────────────────────

class _FoldersDashboardPanel extends StatelessWidget {
  const _FoldersDashboardPanel({
    required this.folderCount,
    required this.organizedCount,
    required this.uncategorizedCount,
    required this.avgFreshness,
    required this.freshnessColor,
  });

  final int folderCount;
  final int organizedCount;
  final int uncategorizedCount;
  final double avgFreshness;
  final Color freshnessColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final totalInbox = organizedCount + uncategorizedCount;
    final orgPercent = totalInbox > 0 ? (organizedCount / totalInbox * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(kRadiusLG),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overview',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.55),
                  letterSpacing: 0.2,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: freshnessColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Decay Status',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: kSpaceMD),
          Row(
            children: [
              _StatItem(
                label: 'Folders',
                value: '$folderCount',
                subLabel: 'Created',
              ),
              _VerticalDivider(),
              _StatItem(
                label: 'Organized',
                value: '$orgPercent%',
                subLabel: '$organizedCount of $totalInbox links',
              ),
              _VerticalDivider(),
              _StatItem(
                label: 'Avg Freshness',
                value: '${(avgFreshness * 100).toStringAsFixed(0)}%',
                subLabel: 'Decay rate',
                valueColor: freshnessColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.subLabel,
    this.valueColor,
  });

  final String label;
  final String value;
  final String subLabel;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: cs.onSurface.withValues(alpha: 0.4),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor ?? cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: kSpaceMD),
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
    );
  }
}

// ─── Folders Empty State View ──────────────────────────────────────────────────

class _EmptyFoldersView extends StatelessWidget {
  const _EmptyFoldersView({required this.onCreatePressed});
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpaceXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.folder_open_outlined,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpaceLG),
            Text(
              'No folders yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: kSpaceSM),
            Text(
              'Group your links by topic to keep your reading list organized and track decay rates together.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.45),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpaceXL),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onCreatePressed();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpaceLG, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  borderRadius: BorderRadius.circular(kRadiusXL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: cs.surface),
                    const SizedBox(width: 6),
                    Text(
                      'Create First Folder',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stacked Folder Card Widget ───────────────────────────────────────────────

class _FolderCard extends ConsumerStatefulWidget {
  const _FolderCard({
    required this.collection,
    required this.inboxCount,
    required this.links,
  });

  final Collection collection;
  final int inboxCount;
  final List<Link> links;

  @override
  ConsumerState<_FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends ConsumerState<_FolderCard> {
  double _scale = 1.0;

  void _showFolderOptions(BuildContext context) {
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
                  _showRenameDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: kFreshnessLow),
                title: Text('Delete Folder', style: GoogleFonts.inter(color: kFreshnessLow)),
                subtitle: const Text('Links will be moved back to general Inbox'),
                onTap: () {
                  ref.read(linkActionsProvider.notifier).deleteCollection(widget.collection.id);
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

  void _showRenameDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.collection.name);
    final emojiController = TextEditingController(text: widget.collection.emoji ?? '📁');

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
                        widget.collection.id,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Calculate freshness indicator if items are present
    double avgFreshness = 1.0;
    if (widget.links.isNotEmpty) {
      final baseHalfLife = ref.watch(halfLifeDaysProvider);
      final decayCurveType = ref.watch(decayCurveTypeProvider);
      final now = DateTime.now();
      double sum = 0.0;
      for (final l in widget.links) {
        sum += computeFreshness(
          createdAt: l.createdAt,
          now: now,
          halfLifeDays: l.customHalfLifeDays ?? baseHalfLife,
          snoozedUntil: l.snoozedUntil,
          decayCurveType: decayCurveType,
        );
      }
      avgFreshness = sum / widget.links.length;
    }

    final freshColor = avgFreshness > 0.66
        ? kFreshnessHigh
        : avgFreshness > 0.33
            ? kFreshnessMid
            : kFreshnessLow;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Folder back tab
          Positioned(
            top: -7,
            left: 14,
            child: Container(
              width: 44,
              height: 10,
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
            ),
          ),
          // Stacked page effect
          Positioned(
            top: -4,
            left: 8,
            right: 8,
            height: 10,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusMD)),
                border: Border.all(color: cs.outline, width: 0.5),
              ),
            ),
          ),
          // Main Card Container
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.surfaceContainerHighest,
                    cs.surfaceContainerHighest.withValues(alpha: 0.82),
                  ],
                ),
                borderRadius: BorderRadius.circular(kRadiusMD),
                border: Border.all(color: cs.outline, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.25 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: (_) => setState(() => _scale = 0.96),
                  onTapUp: (_) => setState(() => _scale = 1.0),
                  onTapCancel: () => setState(() => _scale = 1.0),
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailScreen(collection: widget.collection),
                      ),
                    );
                  },
                  onLongPress: () => _showFolderOptions(context),
                  borderRadius: BorderRadius.circular(kRadiusMD),
                  child: Padding(
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
                              widget.collection.emoji ?? '📁',
                              style: const TextStyle(fontSize: 26),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.onSurface.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.inboxCount}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Middle Row: Recent Link Previews
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.links.isEmpty)
                                Text(
                                  'Empty folder',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: cs.onSurface.withValues(alpha: 0.3),
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              else
                                ...widget.links.take(2).map((l) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1.5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.link,
                                          size: 10,
                                          color: cs.onSurface.withValues(alpha: 0.3),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            l.title ?? l.domain,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5,
                                              color: cs.onSurface.withValues(alpha: 0.55),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Bottom Area: Title + Freshness Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.collection.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (widget.links.isNotEmpty)
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: avgFreshness,
                                        minHeight: 3,
                                        backgroundColor: cs.outline.withValues(alpha: 0.4),
                                        valueColor: AlwaysStoppedAnimation<Color>(freshColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(avgFreshness * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurface.withValues(alpha: 0.45),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: cs.outline.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateFolderCard extends StatefulWidget {
  const _CreateFolderCard({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CreateFolderCard> createState() => _CreateFolderCardState();
}

class _CreateFolderCardState extends State<_CreateFolderCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => setState(() => _scale = 0.96),
          onTapUp: (_) => setState(() => _scale = 1.0),
          onTapCancel: () => setState(() => _scale = 1.0),
          onTap: widget.onTap,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export Public Read List',
            onPressed: () {
              final allInbox = linksAsync.valueOrNull ?? [];
              final folderLinks = allInbox.where((l) => l.collectionId == collection.id).toList();
              if (folderLinks.isNotEmpty) {
                ExportService.instance.shareCollectionAsHtml(collection, folderLinks);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot export an empty folder'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
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
                final isWide = MediaQuery.of(context).size.width > 600;
                return SizedBox(height: isWide ? 40 : 100);
              }
              return LinkCard(key: ValueKey(folderLinks[i].id), link: folderLinks[i]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final isWide = MediaQuery.of(context).size.width > 600;
          if (isWide) {
            showDialog<void>(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AddLinkSheet(preSelectedCollectionId: collection.id),
                  ),
                ),
              ),
            );
          } else {
            showModalBottomSheet<void>(
              context: context,
              builder: (_) => AddLinkSheet(preSelectedCollectionId: collection.id),
              isScrollControlled: true,
              useSafeArea: true,
            );
          }
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
