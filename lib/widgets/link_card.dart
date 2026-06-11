import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';
import '../screens/link_detail_screen.dart';
import 'collection_picker_sheet.dart';
import 'freshness_bar.dart';
import 'snooze_sheet.dart';

/// A dismissible link card with configurable swipe actions and tap/long-press gestures.
class LinkCard extends ConsumerStatefulWidget {
  const LinkCard({super.key, required this.link});

  final Link link;

  @override
  ConsumerState<LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends ConsumerState<LinkCard> {
  static const _dismissThreshold = 0.35;

  void _openDetailScreen() {
    HapticFeedback.lightImpact();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => LinkDetailScreen(linkId: widget.link.id),
      ),
    );
  }

  void _quickOpenUrl() async {
    HapticFeedback.lightImpact();
    final uri = Uri.tryParse(widget.link.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSnooze() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SnoozeSheet(linkId: widget.link.id),
      isScrollControlled: true,
      useSafeArea: true,
    );
  }

  void _showCollectionPicker() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => CollectionPickerSheet(
        linkId: widget.link.id,
        currentCollectionId: widget.link.collectionId,
      ),
      isScrollControlled: true,
      useSafeArea: true,
    );
  }

  Future<bool> _confirmDismiss(DismissDirection dir, String leftAction, String rightAction) async {
    HapticFeedback.lightImpact();
    final action = dir == DismissDirection.startToEnd ? rightAction : leftAction;
    if (action == 'snooze' || action == 'collection' || action == 'none') {
      if (action == 'snooze') {
        _showSnooze();
      } else if (action == 'collection') {
        _showCollectionPicker();
      }
      return false;
    }
    return true;
  }

  void _onDismissed(DismissDirection dir, String leftAction, String rightAction) {
    HapticFeedback.mediumImpact();
    final actions = ref.read(linkActionsProvider.notifier);
    final action = dir == DismissDirection.startToEnd ? rightAction : leftAction;

    if (action == 'read') {
      actions.markAsRead(widget.link.id);
      _showUndoSnackBar('Marked as read', () => actions.restoreToInbox(widget.link.id));
    } else if (action == 'archive') {
      actions.archive(widget.link.id);
      _showUndoSnackBar('Archived', () => actions.restoreToInbox(widget.link.id));
    } else if (action == 'delete') {
      final linkData = widget.link;
      actions.delete(widget.link.id);
      _showUndoSnackBar('Link deleted', () {
        ref.read(databaseProvider).insertLink(
          LinksCompanion.insert(
            id: linkData.id,
            url: linkData.url,
            domain: linkData.domain,
            title: Value(linkData.title),
            faviconUrl: Value(linkData.faviconUrl),
            createdAt: linkData.createdAt,
            snoozedUntil: Value(linkData.snoozedUntil),
            status: linkData.status,
            tags: Value(linkData.tags),
            snoozedSeconds: Value(linkData.snoozedSeconds),
            collectionId: Value(linkData.collectionId),
            notes: Value(linkData.notes),
            ogImageUrl: Value(linkData.ogImageUrl),
            estimatedReadMinutes: Value(linkData.estimatedReadMinutes),
            customHalfLifeDays: Value(linkData.customHalfLifeDays),
          ),
        );
      });
    }
  }

  void _showUndoSnackBar(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: onUndo,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  _SwipeDetails _getSwipeDetails(String action) {
    switch (action) {
      case 'read':
        return const _SwipeDetails(color: kSwipeReadColor, icon: Icons.check_circle_outline, label: 'Read');
      case 'archive':
        return const _SwipeDetails(color: kSwipeArchiveColor, icon: Icons.archive_outlined, label: 'Archive');
      case 'delete':
        return const _SwipeDetails(color: kFreshnessLow, icon: Icons.delete_outline, label: 'Delete');
      case 'snooze':
        return const _SwipeDetails(color: kAccentMuted, icon: Icons.bedtime_outlined, label: 'Snooze');
      case 'collection':
        return const _SwipeDetails(color: kAccent, icon: Icons.folder_outlined, label: 'Folder');
      default:
        return const _SwipeDetails(color: Colors.transparent, icon: Icons.block, label: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseHalfLife = ref.watch(halfLifeDaysProvider);
    final domainOverrides = ref.watch(domainHalfLifeOverridesProvider);
    final tagOverrides = ref.watch(tagHalfLifeOverridesProvider);
    final leftAction = ref.watch(swipeLeftActionProvider);
    final rightAction = ref.watch(swipeRightActionProvider);

    // Determine custom/matching half-life
    double currentHalfLife = baseHalfLife;
    if (widget.link.customHalfLifeDays != null) {
      currentHalfLife = widget.link.customHalfLifeDays!;
    } else if (domainOverrides.containsKey(widget.link.domain.toLowerCase())) {
      currentHalfLife = domainOverrides[widget.link.domain.toLowerCase()]!;
    } else {
      final tags = widget.link.tags.split(',').map((t) => t.trim().toLowerCase());
      for (final tag in tags) {
        if (tagOverrides.containsKey(tag)) {
          currentHalfLife = tagOverrides[tag]!;
          break;
        }
      }
    }

    final now = DateTime.now();
    final score = computeFreshness(
      createdAt: widget.link.createdAt,
      now: now,
      halfLifeDays: currentHalfLife,
      snoozedUntil: widget.link.snoozedUntil,
    );
    final isSnoozed = widget.link.snoozedUntil != null &&
        widget.link.snoozedUntil!.isAfter(now);

    final leftSwipe = _getSwipeDetails(leftAction);
    final rightSwipe = _getSwipeDetails(rightAction);

    final isMultiSelect = ref.watch(selectedLinkIdsProvider).isNotEmpty;
    final isSelected = ref.watch(selectedLinkIdsProvider).contains(widget.link.id);

    Widget cardBody = _CardContent(
      link: widget.link,
      score: score,
      isSnoozed: isSnoozed,
      onTap: isMultiSelect
          ? () {
              final selected = ref.read(selectedLinkIdsProvider.notifier);
              final current = selected.state.toSet();
              if (current.contains(widget.link.id)) {
                current.remove(widget.link.id);
              } else {
                current.add(widget.link.id);
              }
              selected.state = current;
              HapticFeedback.lightImpact();
            }
          : _openDetailScreen,
      onQuickOpen: _quickOpenUrl,
      onLongPress: isMultiSelect
          ? null
          : () {
              // Enter multi-select mode
              ref.read(selectedLinkIdsProvider.notifier).state = {widget.link.id};
              HapticFeedback.mediumImpact();
            },
      isSelected: isSelected,
      isMultiSelectMode: isMultiSelect,
    );

    // If swipe actions are configured to 'none', don't wrap in Dismissible for that direction
    if (leftAction == 'none' && rightAction == 'none') {
      return cardBody;
    }

    return Dismissible(
      key: ValueKey(widget.link.id),
      confirmDismiss: (dir) => _confirmDismiss(dir, leftAction, rightAction),
      onDismissed: (dir) => _onDismissed(dir, leftAction, rightAction),
      dismissThresholds: const {
        DismissDirection.startToEnd: _dismissThreshold,
        DismissDirection.endToStart: _dismissThreshold,
      },
      direction: leftAction == 'none'
          ? DismissDirection.startToEnd
          : rightAction == 'none'
              ? DismissDirection.endToStart
              : DismissDirection.horizontal,
      background: rightAction != 'none'
          ? _SwipeBackground(
              direction: DismissDirection.startToEnd,
              color: rightSwipe.color,
              icon: rightSwipe.icon,
              label: rightSwipe.label,
            )
          : null,
      secondaryBackground: leftAction != 'none'
          ? _SwipeBackground(
              direction: DismissDirection.endToStart,
              color: leftSwipe.color,
              icon: leftSwipe.icon,
              label: leftSwipe.label,
            )
          : null,
      child: cardBody,
    );
  }
}

class _SwipeDetails {
  final Color color;
  final IconData icon;
  final String label;
  const _SwipeDetails({required this.color, required this.icon, required this.label});
}

// ─── Card Content ──────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.link,
    required this.score,
    required this.isSnoozed,
    required this.onTap,
    required this.onQuickOpen,
    required this.onLongPress,
    required this.isSelected,
    required this.isMultiSelectMode,
  });

  final Link link;
  final double score;
  final bool isSnoozed;
  final VoidCallback onTap;
  final VoidCallback onQuickOpen;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isMultiSelectMode;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final age = ageLabel(link.createdAt, now);
    final color = freshnessColor(score);
    final title = link.title ?? link.domain;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? cs.outline.withValues(alpha: 0.15)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(
          color: isSelected ? cs.onSurface : cs.outline,
          width: isSelected ? 1.0 : 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(kRadiusMD),
          splashColor: cs.onSurface.withValues(alpha: 0.05),
          highlightColor: cs.onSurface.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(kSpaceMD),
            child: Row(
              children: [
                if (isMultiSelectMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap(),
                    activeColor: cs.onSurface,
                    checkColor: cs.surface,
                  ),
                  const SizedBox(width: kSpaceSM),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: favicon + title + score/quick-open badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FaviconWidget(
                            faviconUrl: link.faviconUrl,
                            domain: link.domain,
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
                                    letterSpacing: -0.1,
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
                                    if (link.estimatedReadMinutes != null) ...[
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
                                        '${link.estimatedReadMinutes} min read',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: cs.onSurface.withValues(alpha: 0.45),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: kSpaceSM),
                          // Score badge & Quick Open icon
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _ScoreBadge(score: score, color: color),
                              if (!isMultiSelectMode) ...[
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: onQuickOpen,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.open_in_new,
                                      size: 14,
                                      color: cs.onSurface.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: kSpaceMD),

                      // Freshness bar
                      FreshnessBar(score: score, height: 3),

                      if (isSnoozed) ...[
                        const SizedBox(height: kSpaceSM),
                        _SnoozeBadge(snoozedUntil: link.snoozedUntil!),
                      ],

                      if (link.tags.isNotEmpty) ...[
                        const SizedBox(height: kSpaceSM),
                        _TagsRow(tags: link.tags),
                      ],
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

// ─── Sub-widgets ──────────────────────────────────────────────────────────

class _FaviconWidget extends StatelessWidget {
  const _FaviconWidget({required this.faviconUrl, required this.domain});

  final String? faviconUrl;
  final String domain;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cs.outline.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: faviconUrl != null
          ? Image.network(
              faviconUrl!,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _fallback(context),
            )
          : _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final letter = domain.isNotEmpty ? domain[0].toUpperCase() : '?';
    return Center(
      child: Text(
        letter,
        style: GoogleFonts.inter(
          color: cs.onSurface.withValues(alpha: 0.4),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.color});

  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        score.toStringAsFixed(2),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SnoozeBadge extends StatelessWidget {
  const _SnoozeBadge({required this.snoozedUntil});

  final DateTime snoozedUntil;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final month = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][snoozedUntil.month];
    final label = '${snoozedUntil.day} $month';

    return Row(
      children: [
        Icon(
          Icons.bedtime_outlined,
          size: 12,
          color: cs.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 4),
        Text(
          'Snoozed until $label',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: cs.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.tags});

  final String tags;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tagList = tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tagList
          .take(3)
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Swipe Background ─────────────────────────────────────────────────────

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.direction,
    required this.color,
    required this.icon,
    required this.label,
  });

  final DismissDirection direction;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isStart = direction == DismissDirection.startToEnd;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
