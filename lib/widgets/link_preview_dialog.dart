import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';
import '../utils/google_fonts.dart';
import 'link_card_components.dart';

class LinkPreviewDialog extends StatelessWidget {
  const LinkPreviewDialog({
    super.key,
    required this.link,
    required this.score,
    required this.onOpen,
    required this.onMarkRead,
    required this.onArchive,
    required this.onSelect,
    required this.onEdit,
    required this.onSnooze,
  });

  final Link link;
  final double score;
  final VoidCallback onOpen;
  final VoidCallback onMarkRead;
  final VoidCallback onArchive;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final age = ageLabel(link.createdAt, now);
    final color = freshnessColor(score);
    final title = link.title ?? link.domain;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(kSpaceLG),
          constraints: const BoxConstraints(maxWidth: 450),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusLG),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(kRadiusLG),
                  border: Border.all(
                    color: cs.outline.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.91,
                        child: link.ogImageUrl != null && link.ogImageUrl!.isNotEmpty
                            ? Image.network(
                                link.ogImageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const ShimmerPlaceholder(width: double.infinity, height: double.infinity);
                                },
                                errorBuilder: (context, error, stackTrace) => _fallbackPreviewCover(context),
                              )
                            : _fallbackPreviewCover(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(kSpaceLG),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FaviconWidget(faviconUrl: link.faviconUrl, domain: link.domain),
                                const SizedBox(width: kSpaceMD),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        link.domain,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: cs.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      Text(
                                        age,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: cs.onSurface.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ScoreBadge(score: score, color: color),
                              ],
                            ),
                            const SizedBox(height: kSpaceMD),
                            Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                                height: 1.3,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (link.estimatedReadMinutes != null || link.isDead) ...[
                              const SizedBox(height: kSpaceSM),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (link.estimatedReadMinutes != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: cs.outline.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '⏱️ ${link.estimatedReadMinutes} min read',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: cs.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  if (link.isDead)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: cs.error.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: cs.error.withValues(alpha: 0.25), width: 0.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.link_off, size: 12, color: cs.error),
                                          const SizedBox(width: 4),
                                          Text(
                                            'DEAD LINK',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: cs.error,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            if (link.tags.isNotEmpty) ...[
                              const SizedBox(height: kSpaceMD),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: link.tags
                                    .split(',')
                                    .map((t) => t.trim())
                                    .where((t) => t.isNotEmpty)
                                    .map((tag) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: cs.outline.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: cs.outline.withValues(alpha: 0.15),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.tag, size: 10, color: cs.onSurface.withValues(alpha: 0.5)),
                                              const SizedBox(width: 3),
                                              Text(
                                                tag,
                                                style: GoogleFonts.inter(
                                                  color: cs.onSurface.withValues(alpha: 0.7),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                            if (link.notes != null && link.notes!.isNotEmpty) ...[
                              const SizedBox(height: kSpaceMD),
                              Text(
                                'Notes',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(kSpaceMD),
                                decoration: BoxDecoration(
                                  color: cs.outline.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(kRadiusSM),
                                  border: Border.all(
                                    color: cs.outline.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  link.notes!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: cs.onSurface.withValues(alpha: 0.85),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: kSpaceLG),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: onOpen,
                                    icon: const Icon(Icons.open_in_new, size: 16),
                                    label: const Text('Open Link'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: cs.onSurface,
                                      foregroundColor: cs.surface,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: kSpaceSM),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: onMarkRead,
                                    icon: const Icon(Icons.check_circle_outline, size: 16),
                                    label: const Text('Mark Read'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: kSwipeReadColor,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      backgroundColor: kSwipeReadColor.withValues(alpha: 0.12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: kSwipeReadColor.withValues(alpha: 0.25), width: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: kSpaceMD),
                            // Secondary icon bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SecondaryIconButton(
                                  icon: Icons.edit_outlined,
                                  label: 'Edit',
                                  onPressed: onEdit,
                                ),
                                SecondaryIconButton(
                                  icon: Icons.bedtime_outlined,
                                  label: 'Snooze',
                                  onPressed: onSnooze,
                                ),
                                SecondaryIconButton(
                                  icon: Icons.archive_outlined,
                                  label: 'Archive',
                                  onPressed: onArchive,
                                ),
                                SecondaryIconButton(
                                  icon: Icons.checklist_outlined,
                                  label: 'Select',
                                  onPressed: onSelect,
                                ),
                              ],
                            ),
                            const SizedBox(height: kSpaceMD),
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Dismiss',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget _fallbackPreviewCover(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hash = link.domain.hashCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final color1 = isDark
        ? cs.outline.withValues(alpha: 0.15)
        : cs.outline.withValues(alpha: 0.08);
    final color2 = isDark
        ? cs.surfaceContainerHighest.withValues(alpha: 0.45)
        : cs.surfaceContainerHighest.withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: hash.isEven ? Alignment.topLeft : Alignment.topRight,
          end: hash.isEven ? Alignment.bottomRight : Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.link,
                size: 80,
                color: cs.onSurface,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: FaviconWidget(faviconUrl: link.faviconUrl, domain: link.domain),
                ),
                const SizedBox(height: kSpaceSM),
                Text(
                  link.domain,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryIconButton extends StatelessWidget {
  const SecondaryIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: cs.outline.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: cs.onSurface.withValues(alpha: 0.8), size: 20),
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
