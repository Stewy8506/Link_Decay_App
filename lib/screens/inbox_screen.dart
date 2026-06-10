import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';
import '../widgets/add_link_sheet.dart';
import '../widgets/link_card.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const AddLinkSheet(),
      isScrollControlled: true,
      useSafeArea: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(inboxLinksProvider);
    final halfLife = ref.watch(halfLifeDaysProvider);

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: kBackgroundDark,
            expandedHeight: 100,
            collapsedHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceMD),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inbox',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                      letterSpacing: -0.6,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Half-life indicator
              linksAsync.when(
                data: (links) {
                  if (links.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: kSpaceXS),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kCardDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBorderDark),
                        ),
                        child: Text(
                          '${links.length} links',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: kTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              IconButton(
                onPressed: () => _showAddSheet(context),
                icon: const Icon(Icons.add, size: 24),
                color: kTextPrimary,
                tooltip: 'Add link',
              ),
              const SizedBox(width: kSpaceXS),
            ],
          ),

          // ── Decay info bar ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceSM),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: kTextTertiary),
                  const SizedBox(width: 5),
                  Text(
                    'Half-life: ${halfLife.toStringAsFixed(0)} days · Most stale on top',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: kTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Link List ─────────────────────────────────────────────────
          linksAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: kAccent)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: _ErrorState(error: e.toString()),
            ),
            data: (links) {
              if (links.isEmpty) {
                return const SliverFillRemaining(child: _EmptyState());
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == links.length) {
                      return const SizedBox(height: 100); // Bottom padding for FAB
                    }
                    return LinkCard(key: ValueKey(links[i].id), link: links[i]);
                  },
                  childCount: links.length + 1,
                ),
              );
            },
          ),
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
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

// ─── Empty State ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
                color: kAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(kRadiusXL),
              ),
              child: const Icon(Icons.inbox_outlined, color: kAccent, size: 32),
            ),
            const SizedBox(height: kSpaceLG),
            Text(
              'Your inbox is clear',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: kSpaceSM),
            Text(
              'Save links to start tracking their freshness.\nTap + or share from any app.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: kTextSecondary,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpaceXXL),
        child: Text(
          'Error: $error',
          style: GoogleFonts.inter(color: kFreshnessLow, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
