import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification) {
            final offset = notification.metrics.pixels;
            // Detect pull down overscroll
            if (offset < -100 && !_isStatsExpanded && !isMultiSelectMode) {
              setState(() {
                _isStatsExpanded = true;
              });
              HapticFeedback.mediumImpact();
            }
          }
          return false;
        },
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Stats Dashboard Panel (Collapsible pull-down) ──────────
                if (_isStatsExpanded)
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: StatsDashboardPanel(
                        onClose: () => setState(() => _isStatsExpanded = false),
                      ),
                    ),
                  ),

                // ── App Bar ──────────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        )
                      : Text(
                          'Inbox',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.3,
                          ),
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
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceSM),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => ref.read(inboxSearchQueryProvider.notifier).state = v,
                        style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search title, domain, or tag…',
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
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

                  // Sort & Summary Info Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(kSpaceMD, 4, kSpaceMD, kSpaceSM),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 13,
                            color: cs.onSurface.withValues(alpha: 0.35),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              activeFilter != null
                                  ? 'List: ${activeFilter.name} · ${links.length} links'
                                  : 'Half-life: ${halfLife.toStringAsFixed(0)} days · ${links.length} links',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: cs.onSurface.withValues(alpha: 0.35),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: kSpaceSM),
                          // Custom Sorting Dropdown
                          DropdownButton<String>(
                            value: activeSortMode,
                            icon: Icon(Icons.sort, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
                            underline: const SizedBox.shrink(),
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(inboxSortModeProvider.notifier).state = val;
                                HapticFeedback.lightImpact();
                              }
                            },
                            items: [
                              DropdownMenuItem(value: 'stalest', child: Text('Stalest first', style: GoogleFonts.inter(fontSize: 11))),
                              DropdownMenuItem(value: 'freshness_desc', child: Text('Freshest first', style: GoogleFonts.inter(fontSize: 11))),
                              DropdownMenuItem(value: 'newest', child: Text('Newest first', style: GoogleFonts.inter(fontSize: 11))),
                              DropdownMenuItem(value: 'read_time', child: Text('Read time', style: GoogleFonts.inter(fontSize: 11))),
                              DropdownMenuItem(value: 'domain', child: Text('Domain name', style: GoogleFonts.inter(fontSize: 11))),
                            ],
                          ),
                        ],
                      ),
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
      ),

      // ── FAB — inverted neutral style ──────────────────────────────────
      floatingActionButtonLocation: const _AboveNavBarFabLocation(),
      floatingActionButton: isMultiSelectMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddSheet(context),
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

// Custom location to place the FAB above the floating bottom navbar
class _AboveNavBarFabLocation extends FloatingActionButtonLocation {
  const _AboveNavBarFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX =
        scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        16;

    final double bottomInset = scaffoldGeometry.minInsets.bottom;
    final double fabY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        (bottomInset + 108.0);

    return Offset(fabX, fabY);
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(kRadiusXL),
              ),
              child: Icon(
                Icons.inbox_outlined,
                color: cs.onSurface.withValues(alpha: 0.3),
                size: 30,
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text(
              'No matching links',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: kSpaceSM),
            Text(
              'Change your filter search or pull down from top to review reading metrics.',
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
