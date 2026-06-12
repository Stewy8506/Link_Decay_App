import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';
import '../screens/link_detail_screen.dart';
import 'collection_picker_sheet.dart';
import 'snooze_sheet.dart';
import 'link_card_components.dart';
import 'link_preview_dialog.dart';
import 'freshness_bar.dart';

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
      _showUndoSnackBar('Marked as read', () => actions.restoreToInbox(widget.link.id, force: true));
    } else if (action == 'archive') {
      actions.archive(widget.link.id);
      _showUndoSnackBar('Archived', () => actions.restoreToInbox(widget.link.id, force: true));
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

  void _showPreviewDialog(double score) {
    HapticFeedback.mediumImpact();
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Preview',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LinkPreviewDialog(
          link: widget.link,
          score: score,
          onOpen: () {
            Navigator.pop(context);
            _quickOpenUrl();
          },
          onMarkRead: () {
            Navigator.pop(context);
            final actions = ref.read(linkActionsProvider.notifier);
            actions.markAsRead(widget.link.id);
            _showUndoSnackBar('Marked as read', () => actions.restoreToInbox(widget.link.id, force: true));
          },
          onArchive: () {
            Navigator.pop(context);
            final actions = ref.read(linkActionsProvider.notifier);
            actions.archive(widget.link.id);
            _showUndoSnackBar('Archived', () => actions.restoreToInbox(widget.link.id, force: true));
          },
          onSelect: () {
            Navigator.pop(context);
            ref.read(selectedLinkIdsProvider.notifier).state = {widget.link.id};
          },
          onEdit: () {
            Navigator.pop(context);
            _openDetailScreen();
          },
          onSnooze: () {
            Navigator.pop(context);
            _showSnooze();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0 * animation.value,
            sigmaY: 5.0 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseHalfLife = ref.watch(halfLifeDaysProvider);
    final domainOverrides = ref.watch(domainHalfLifeOverridesProvider);
    final tagOverrides = ref.watch(tagHalfLifeOverridesProvider);
    final leftAction = ref.watch(swipeLeftActionProvider);
    final rightAction = ref.watch(swipeRightActionProvider);
    final decayCurveType = ref.watch(decayCurveTypeProvider);

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
      decayCurveType: decayCurveType,
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
              _showPreviewDialog(score);
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
          ? SwipeBackground(
              direction: DismissDirection.startToEnd,
              color: rightSwipe.color,
              icon: rightSwipe.icon,
              label: rightSwipe.label,
            )
          : null,
      secondaryBackground: leftAction != 'none'
          ? SwipeBackground(
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

class _CardContent extends StatefulWidget {
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
  State<_CardContent> createState() => _CardContentState();
}

class _CardContentState extends State<_CardContent> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final age = ageLabel(widget.link.createdAt, now);
    final color = freshnessColor(widget.score);
    final title = widget.link.title ?? widget.link.domain;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 5),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? cs.outline.withValues(alpha: 0.15)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(kRadiusMD),
          border: Border.all(
            color: widget.isSelected ? cs.onSurface : cs.outline.withValues(alpha: 0.5),
            width: widget.isSelected ? 1.0 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.015),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: (_) => setState(() => _scale = 0.98),
            onTapUp: (_) => setState(() => _scale = 1.0),
            onTapCancel: () => setState(() => _scale = 1.0),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onSecondaryTap: widget.onLongPress, // Right-click support for desktop/web
            borderRadius: BorderRadius.circular(kRadiusMD),
            splashColor: cs.onSurface.withValues(alpha: 0.05),
            highlightColor: cs.onSurface.withValues(alpha: 0.03),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 3.5,
                  child: Container(
                    color: color,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(kSpaceMD + 3.5, kSpaceMD, kSpaceMD, kSpaceMD),
                  child: Row(
                    children: [
                      if (widget.isMultiSelectMode) ...[
                        Checkbox(
                          value: widget.isSelected,
                          onChanged: (_) => widget.onTap(),
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
                                FaviconWidget(
                                  faviconUrl: widget.link.faviconUrl,
                                  domain: widget.link.domain,
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
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          if (widget.link.isDead) ...[
                                            Container(
                                              margin: const EdgeInsets.only(right: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: cs.error.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: cs.error.withValues(alpha: 0.25),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.link_off,
                                                    size: 10,
                                                    color: cs.error,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    'DEAD LINK',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.w700,
                                                      color: cs.error,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          Text(
                                            widget.link.domain,
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
                                          if (widget.link.estimatedReadMinutes != null) ...[
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
                                              '${widget.link.estimatedReadMinutes} min read',
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
                                    ScoreBadge(score: widget.score, color: color),
                                    if (!widget.isMultiSelectMode) ...[
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: widget.onQuickOpen,
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
                            FreshnessBar(score: widget.score, height: 3),

                            if (widget.isSnoozed) ...[
                              const SizedBox(height: kSpaceSM),
                              SnoozeBadge(snoozedUntil: widget.link.snoozedUntil!),
                            ],

                            if (widget.link.tags.isNotEmpty) ...[
                              const SizedBox(height: kSpaceSM),
                              TagsRow(tags: widget.link.tags),
                            ],
                          ],
                        ),
                      ),
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
