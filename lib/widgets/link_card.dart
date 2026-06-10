import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';
import 'freshness_bar.dart';
import 'snooze_sheet.dart';

/// A dismissible link card with swipe right (read) and left (archive) actions.
class LinkCard extends ConsumerStatefulWidget {
  const LinkCard({super.key, required this.link});

  final Link link;

  @override
  ConsumerState<LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends ConsumerState<LinkCard> {
  static const _dismissThreshold = 0.35;

  void _openUrl() async {
    final uri = Uri.tryParse(widget.link.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSnooze() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SnoozeSheet(linkId: widget.link.id),
      isScrollControlled: true,
      useSafeArea: true,
    );
  }

  Future<bool> _confirmDismiss(DismissDirection dir) async {
    return true;
  }

  void _onDismissed(DismissDirection dir) {
    final actions = ref.read(linkActionsProvider.notifier);
    if (dir == DismissDirection.startToEnd) {
      actions.markAsRead(widget.link.id);
      _showUndoSnackBar('Marked as read', () => actions.restoreToInbox(widget.link.id));
    } else {
      actions.archive(widget.link.id);
      _showUndoSnackBar('Archived', () => actions.restoreToInbox(widget.link.id));
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
            textColor: kAccent,
            onPressed: onUndo,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final halfLife = ref.watch(halfLifeDaysProvider);
    final now = DateTime.now();
    final score = computeFreshness(
      createdAt: widget.link.createdAt,
      now: now,
      halfLifeDays: halfLife,
      snoozedUntil: widget.link.snoozedUntil,
    );
    final isSnoozed = widget.link.snoozedUntil != null &&
        widget.link.snoozedUntil!.isAfter(now);

    return Dismissible(
      key: ValueKey(widget.link.id),
      confirmDismiss: _confirmDismiss,
      onDismissed: _onDismissed,
      dismissThresholds: const {
        DismissDirection.startToEnd: _dismissThreshold,
        DismissDirection.endToStart: _dismissThreshold,
      },
      background: _SwipeBackground(
        direction: DismissDirection.startToEnd,
        color: kSwipeReadColor,
        icon: Icons.check_circle_outline,
        label: 'Read',
      ),
      secondaryBackground: _SwipeBackground(
        direction: DismissDirection.endToStart,
        color: kSwipeArchiveColor,
        icon: Icons.archive_outlined,
        label: 'Archive',
      ),
      child: GestureDetector(
        onTap: _openUrl,
        onLongPress: _showSnooze,
        child: _CardContent(
          link: widget.link,
          score: score,
          isSnoozed: isSnoozed,
        ),
      ),
    );
  }
}

// ─── Card Content ──────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.link,
    required this.score,
    required this.isSnoozed,
  });

  final Link link;
  final double score;
  final bool isSnoozed;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final age = ageLabel(link.createdAt, now);
    final color = freshnessColor(score);
    final title = link.title ?? link.domain;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 5),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(color: kBorderDark, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: favicon + title + score badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Favicon
                _FaviconWidget(
                  faviconUrl: link.faviconUrl,
                  domain: link.domain,
                ),
                const SizedBox(width: kSpaceMD),
                // Title + meta
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
                          color: kTextPrimary,
                          height: 1.35,
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
                              color: kTextSecondary,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '·',
                              style: TextStyle(color: kTextTertiary),
                            ),
                          ),
                          Text(
                            age,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: kSpaceSM),
                // Score badge
                _ScoreBadge(score: score, color: color),
              ],
            ),

            const SizedBox(height: kSpaceMD),

            // Freshness bar
            FreshnessBar(score: score, height: 3),

            // Snoozed badge
            if (isSnoozed) ...[
              const SizedBox(height: kSpaceSM),
              _SnoozeBadge(snoozedUntil: link.snoozedUntil!),
            ],

            // Tags
            if (link.tags.isNotEmpty) ...[
              const SizedBox(height: kSpaceSM),
              _TagsRow(tags: link.tags),
            ],
          ],
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
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: kBorderDark,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: faviconUrl != null
          ? Image.network(
              faviconUrl!,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    final letter = domain.isNotEmpty ? domain[0].toUpperCase() : '?';
    return Center(
      child: Text(
        letter,
        style: GoogleFonts.inter(
          color: kTextSecondary,
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
    final month = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][snoozedUntil.month];
    final label = '${snoozedUntil.day} $month';

    return Row(
      children: [
        const Icon(Icons.bedtime_outlined, size: 12, color: kAccentMuted),
        const SizedBox(width: 4),
        Text(
          'Snoozed until $label',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: kAccentMuted,
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
    final tagList = tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tagList
          .take(3) // Show max 3 tags on card
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: kBorderDark,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: kTextSecondary,
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: kSpaceLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
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
