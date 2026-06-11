import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/google_fonts.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';
import '../widgets/add_link_sheet.dart';
import '../widgets/link_card.dart';
import '../widgets/smart_list_bar.dart';
import '../widgets/multi_select_bar.dart';
import '../widgets/stats_dashboard_panel.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  bool _isStatsExpanded = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const AddLinkSheet(),
      isScrollControlled: true,
      useSafeArea: true,
    );
  }

  String _getSortModeLabel(String mode) {
    switch (mode) {
      case 'stalest': return 'Stalest';
      case 'freshness_desc': return 'Freshest';
      case 'newest': return 'Newest';
      case 'read_time': return 'Read Time';
      case 'domain': return 'Domain';
      default: return 'Sort';
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = ref.watch(sortedFilteredInboxProvider);
    final halfLife = ref.watch(halfLifeDaysProvider);
    final selectedIds = ref.watch(selectedLinkIdsProvider);
    final activeSortMode = ref.watch(inboxSortModeProvider);
    final activeFilter = ref.watch(activeFilterProvider);

    final isMultiSelectMode = selectedIds.isNotEmpty;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── Stats Dashboard Panel (Collapsible pull-down) ──────────
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: kDurationNormal,
                  curve: Curves.easeInOut,
                  child: _isStatsExpanded
                      ? SafeArea(
                          bottom: false,
                          child: StatsDashboardPanel(
                            onClose: () => setState(() => _isStatsExpanded = false),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              // ── App Bar ──────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                toolbarHeight: 80,
                titleSpacing: kSpaceMD,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: isMultiSelectMode
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref.read(selectedLinkIdsProvider.notifier).state = const {};
                          HapticFeedback.lightImpact();
                        },
                      )
                    : null,
                title: isMultiSelectMode
                    ? Text(
                        '${selectedIds.length} Selected',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Inbox',
                            style: GoogleFonts.inter(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeFilter != null
                                ? 'List: ${activeFilter.name} · ${links.length} links'
                                : 'Lifespan: ${(halfLife * 2).toStringAsFixed(0)} days · ${links.length} links',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                actions: [
                  if (isMultiSelectMode)
                    TextButton(
                      onPressed: () {
                        final notifier = ref.read(selectedLinkIdsProvider.notifier);
                        if (selectedIds.length == links.length) {
                          notifier.state = const {};
                        } else {
                          notifier.state = links.map((l) => l.id).toSet();
                        }
                        HapticFeedback.lightImpact();
                      },
                      child: Text(
                        selectedIds.length == links.length ? 'Deselect All' : 'Select All',
                        style: GoogleFonts.inter(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else ...[
                    // Pull-down toggle indicator
                    IconButton(
                      icon: Icon(
                        _isStatsExpanded ? Icons.analytics : Icons.analytics_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isStatsExpanded = !_isStatsExpanded;
                        });
                        HapticFeedback.lightImpact();
                      },
                      tooltip: 'Stats Dashboard',
                    ),
                    IconButton(
                      onPressed: () => _showAddSheet(context),
                      icon: const Icon(Icons.add, size: 24),
                      color: cs.onSurface,
                      tooltip: 'Add link',
                    ),
                    const SizedBox(width: kSpaceXS),
                  ]
                ],
              ),

              // ── Search & Filter Controls ───────────────────────────────
              if (!isMultiSelectMode) ...[
                // Search Bar & Sort Button Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(kSpaceMD, 4, kSpaceMD, kSpaceSM),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => ref.read(inboxSearchQueryProvider.notifier).state = v,
                            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Search title, domain, or tag…',
                              filled: true,
                              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18,
                                color: cs.onSurface.withValues(alpha: 0.35),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref.read(inboxSearchQueryProvider.notifier).state = '';
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: kSpaceMD),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: cs.outline, width: 0.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: cs.outline, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: cs.primary, width: 1.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: kSpaceSM),
                        PopupMenuButton<String>(
                          initialValue: activeSortMode,
                          onSelected: (val) {
                            ref.read(inboxSortModeProvider.notifier).state = val;
                            HapticFeedback.lightImpact();
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'stalest', child: Text('Stalest first', style: GoogleFonts.inter(fontSize: 12))),
                            PopupMenuItem(value: 'freshness_desc', child: Text('Freshest first', style: GoogleFonts.inter(fontSize: 12))),
                            PopupMenuItem(value: 'newest', child: Text('Newest first', style: GoogleFonts.inter(fontSize: 12))),
                            PopupMenuItem(value: 'read_time', child: Text('Read time', style: GoogleFonts.inter(fontSize: 12))),
                            PopupMenuItem(value: 'domain', child: Text('Domain name', style: GoogleFonts.inter(fontSize: 12))),
                          ],
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: cs.outline, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sort, size: 16, color: cs.onSurface.withValues(alpha: 0.6)),
                                const SizedBox(width: 6),
                                Text(
                                  _getSortModeLabel(activeSortMode),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down, size: 14, color: cs.onSurface.withValues(alpha: 0.6)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Smart Lists Selection Horizontal Scroll
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: kSpaceSM),
                    child: SmartListBar(),
                  ),
                ),
              ],

              // ── Link list ────────────────────────────────────────────────
              if (links.isEmpty)
                const SliverFillRemaining(child: _EmptyInbox())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (i == links.length) {
                        return const SizedBox(height: 200); // Pad for FAB/navbar
                      }
                      return LinkCard(key: ValueKey(links[i].id), link: links[i]);
                    },
                    childCount: links.length + 1,
                  ),
                ),
            ],
          ),

          // Bulk Actions Overlay Floating Bar
          const MultiSelectBar(),
        ],
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

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
                    Icons.bookmark_border_rounded,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSpaceLG),
            Text(
              'No links in sight',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: kSpaceSM),
            Text(
              'Your inbox is empty. Save links to track their freshness, or adjust your current filter settings.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.4),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
