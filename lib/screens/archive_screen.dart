import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../models/link_status.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';
import '../widgets/freshness_bar.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(filteredArchiveLinksProvider);
    final query = ref.watch(archiveSearchQueryProvider);
    final statusFilter = ref.watch(archiveStatusFilterProvider);
    final allTags = ref.watch(allTagsProvider);
    final tagFilter = ref.watch(archiveTagFilterProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            expandedHeight: 100,
            collapsedHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceMD),
              title: Text(
                'Archive',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                  height: 1.0,
                ),
              ),
            ),
          ),

          // ── Search bar ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceSM),
              child: TextField(
                onChanged: (v) =>
                    ref.read(archiveSearchQueryProvider.notifier).state = v,
                style: GoogleFonts.inter(fontSize: 15, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search titles, domains, tags…',
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: cs.onSurface.withValues(alpha: 0.3),
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          color: cs.onSurface.withValues(alpha: 0.3),
                          onPressed: () => ref
                              .read(archiveSearchQueryProvider.notifier)
                              .state = '',
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: statusFilter == null,
                    onSelected: (_) => ref
                        .read(archiveStatusFilterProvider.notifier)
                        .state = null,
                  ),
                  const SizedBox(width: kSpaceSM),
                  _FilterChip(
                    label: 'Read',
                    selected: statusFilter == LinkStatus.read,
                    onSelected: (_) => ref
                        .read(archiveStatusFilterProvider.notifier)
                        .state = LinkStatus.read,
                  ),
                  const SizedBox(width: kSpaceSM),
                  _FilterChip(
                    label: 'Archived',
                    selected: statusFilter == LinkStatus.archived,
                    onSelected: (_) => ref
                        .read(archiveStatusFilterProvider.notifier)
                        .state = LinkStatus.archived,
                  ),
                  if (allTags.isNotEmpty) ...[
                    const SizedBox(width: kSpaceMD),
                    Container(
                      width: 0.5,
                      height: 20,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: cs.outline,
                    ),
                    const SizedBox(width: kSpaceMD),
                    ...allTags.map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(right: kSpaceSM),
                        child: _FilterChip(
                          label: '#$tag',
                          selected: tagFilter == tag,
                          isTag: true,
                          onSelected: (_) {
                            final notifier =
                                ref.read(archiveTagFilterProvider.notifier);
                            notifier.state =
                                notifier.state == tag ? null : tag;
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: kSpaceSM)),

          // ── Results count ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceSM, kSpaceMD, kSpaceSM),
              child: Text(
                '${links.length} ${links.length == 1 ? 'link' : 'links'}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          // ── Link list ─────────────────────────────────────────────────
          links.isEmpty
              ? const SliverFillRemaining(child: _EmptyArchive())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (i == links.length) return const SizedBox(height: 80);
                      return _ArchiveCard(link: links[i]);
                    },
                    childCount: links.length + 1,
                  ),
                ),
        ],
      ),
    );
  }
}

// ─── Archive card (no swipe, just tap to open) ────────────────────────────

class _ArchiveCard extends ConsumerWidget {
  const _ArchiveCard({required this.link});

  final Link link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final halfLife = ref.watch(halfLifeDaysProvider);
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final score = computeFreshness(
      createdAt: link.createdAt,
      now: now,
      halfLifeDays: halfLife,
    );

    final title = link.title ?? link.domain;
    final age = ageLabel(link.createdAt, now);
    final isRead = link.status == LinkStatus.read;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final uri = Uri.tryParse(link.url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceSM),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(kRadiusMD),
            border: Border.all(color: cs.outline, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(kSpaceMD),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Neutral status dot — no green/blue
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isRead
                          ? cs.onSurface.withValues(alpha: 0.5)   // dimmer = read
                          : cs.onSurface.withValues(alpha: 0.25), // dimmest = archived
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: kSpaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: kSpaceXS),
                      Row(
                        children: [
                          Text(
                            link.domain,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '·',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                          Text(
                            age,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                          const Spacer(),
                          // Neutral text label — no colored badge
                          Text(
                            isRead ? 'Read' : 'Archived',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface.withValues(alpha: 0.35),
                            ),
                          ),
                        ],
                      ),
                      if (link.tags.isNotEmpty) ...[
                        const SizedBox(height: kSpaceXS),
                        Text(
                          link.tags.split(',').map((t) => '#${t.trim()}').join(' '),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                      const SizedBox(height: kSpaceSM),
                      FreshnessBar(score: score, height: 2),
                    ],
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

// ─── Filter Chip ──────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.isTag = false,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final bool isTag;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: kDurationFast,
      decoration: BoxDecoration(
        // Selected: inverted neutral — onSurface bg, surface text
        // Unselected: transparent with border
        color: selected ? cs.onSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? Colors.transparent : cs.outline,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onSelected(!selected),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? cs.surface       // Light text on dark chip
                  : cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty Archive ────────────────────────────────────────────────────────

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();

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
                Icons.archive_outlined,
                color: cs.onSurface.withValues(alpha: 0.3),
                size: 30,
              ),
            ),
            const SizedBox(height: kSpaceLG),
            Text(
              'Nothing here yet',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: kSpaceSM),
            Text(
              'Links you read or archive will appear here.',
              style: GoogleFonts.inter(
                fontSize: 14,
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
