import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../models/link_status.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/freshness.dart';
import '../widgets/collection_picker_sheet.dart';
import '../widgets/snooze_sheet.dart';

class LinkDetailScreen extends ConsumerStatefulWidget {
  const LinkDetailScreen({super.key, required this.linkId});
  final String linkId;

  @override
  ConsumerState<LinkDetailScreen> createState() => _LinkDetailScreenState();
}

class _LinkDetailScreenState extends ConsumerState<LinkDetailScreen> {
  final _notesController = TextEditingController();
  final _highlightController = TextEditingController();
  bool _isNotesEditing = false;

  @override
  void dispose() {
    _notesController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  void _saveNotes(Link link) {
    ref.read(linkActionsProvider.notifier).updateNotes(link.id, _notesController.text.trim());
    setState(() => _isNotesEditing = false);
    HapticFeedback.lightImpact();
  }

  void _openUrl(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showEditTitleDialog(BuildContext context, Link link) {
    final controller = TextEditingController(text: link.title ?? link.domain);
    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Rename Link', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          content: TextField(
            controller: controller,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Enter a custom name for this link…',
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
            ),
            TextButton(
              onPressed: () {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) {
                  ref.read(linkActionsProvider.notifier).updateTitle(link.id, txt);
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

  void _showAddHighlightDialog(BuildContext context) {
    _highlightController.clear();
    showDialog<void>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Add Highlight', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          content: TextField(
            controller: _highlightController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Paste a quote or key sentence from the link here…',
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
            ),
            TextButton(
              onPressed: () {
                final txt = _highlightController.text.trim();
                if (txt.isNotEmpty) {
                  ref.read(linkActionsProvider.notifier).addHighlight(widget.linkId, txt);
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                }
              },
              child: Text('Add', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allLinks = ref.watch(allLinksProvider).valueOrNull ?? [];
    final linkIndex = allLinks.indexWhere((l) => l.id == widget.linkId);

    if (linkIndex == -1) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Link not found or has been deleted.')),
      );
    }

    final link = allLinks[linkIndex];
    final baseHalfLife = ref.watch(halfLifeDaysProvider);
    final domainOverrides = ref.watch(domainHalfLifeOverridesProvider);
    final tagOverrides = ref.watch(tagHalfLifeOverridesProvider);
    final decayCurveType = ref.watch(decayCurveTypeProvider);

    // Determine custom or matching half-life
    double currentHalfLife = baseHalfLife;
    if (link.customHalfLifeDays != null) {
      currentHalfLife = link.customHalfLifeDays!;
    } else if (domainOverrides.containsKey(link.domain.toLowerCase())) {
      currentHalfLife = domainOverrides[link.domain.toLowerCase()]!;
    } else {
      final tags = link.tags.split(',').map((t) => t.trim().toLowerCase());
      for (final tag in tags) {
        if (tagOverrides.containsKey(tag)) {
          currentHalfLife = tagOverrides[tag]!;
          break;
        }
      }
    }

    final now = DateTime.now();
    final score = computeFreshness(
      createdAt: link.createdAt,
      now: now,
      halfLifeDays: currentHalfLife,
      snoozedUntil: link.snoozedUntil,
      decayCurveType: decayCurveType,
    );

    if (!_isNotesEditing && _notesController.text != (link.notes ?? '')) {
      _notesController.text = link.notes ?? '';
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final highlightsStream = ref.watch(databaseProvider).watchHighlightsForLink(link.id);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header Banner ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  if (link.ogImageUrl != null)
                    Image.network(
                      link.ogImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _fallbackCover(context, link),
                    )
                  else
                    _fallbackCover(context, link),

                  // Overlay Gradient for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),

                  // Favicon + Title overlay
                  Positioned(
                    left: kSpaceMD,
                    right: kSpaceMD,
                    bottom: kSpaceMD,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: link.faviconUrl != null
                              ? Image.network(
                                  link.faviconUrl!,
                                  errorBuilder: (context, error, stackTrace) => _fallbackFavicon(link.domain, cs),
                                )
                              : _fallbackFavicon(link.domain, cs),
                        ),
                        const SizedBox(width: kSpaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                link.domain,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      link.title ?? link.domain,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16, color: Colors.white70),
                                    onPressed: () => _showEditTitleDialog(context, link),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    tooltip: 'Rename Link',
                                  ),
                                ],
                              ),
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

          // ── Detail Body Content ─────────────────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              // ── General Link Status Info ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceLG, kSpaceMD, kSpaceSM),
                child: Row(
                  children: [
                    // Freshness Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: freshnessColor(score).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: freshnessColor(score),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Freshness: ${score.toStringAsFixed(2)} · ${freshnessLabel(score)}',
                            style: GoogleFonts.inter(
                              color: freshnessColor(score),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Reading Time Estimate
                    if (link.estimatedReadMinutes != null)
                      Row(
                        children: [
                          Icon(Icons.auto_stories_outlined, size: 14, color: cs.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(width: 4),
                          Text(
                            '~${link.estimatedReadMinutes} min read',
                            style: GoogleFonts.inter(
                              color: cs.onSurface.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              if (link.tags.isNotEmpty) ...[
                const SizedBox(height: kSpaceSM),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: link.tags
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.outline.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: cs.outline.withValues(alpha: 0.15),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.tag, size: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                                  const SizedBox(width: 4),
                                  Text(
                                    tag,
                                    style: GoogleFonts.inter(
                                      color: cs.onSurface.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],

              // ── Per-Link Lifespan Customization Slider ──────────────────
              _SectionHeader(label: 'Lifespan Control Override'),
              _CardWrapper(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceMD, kSpaceMD, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          link.customHalfLifeDays == null ? 'Using Global Lifespan' : 'Custom Lifespan Override',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                        ),
                        if (link.customHalfLifeDays != null)
                          TextButton(
                            onPressed: () {
                              ref.read(linkActionsProvider.notifier).updateCustomHalfLife(link.id, null);
                              HapticFeedback.lightImpact();
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: Text('Reset', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                          )
                      ],
                    ),
                  ),
                  Slider(
                    value: (currentHalfLife * 2).clamp(2.0, 60.0),
                    min: 2,
                    max: 60,
                    divisions: 58,
                    onChanged: (val) {
                      ref.read(linkActionsProvider.notifier).updateCustomHalfLife(link.id, val / 2.0);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(kSpaceMD, 0, kSpaceMD, kSpaceMD),
                    child: Text(
                      'This link has a total lifespan of ${(currentHalfLife * 2).toStringAsFixed(0)} days before it is considered stale.',
                      style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45)),
                    ),
                  ),
                ],
              ),

              // ── Notes Field ──────────────────────────────────────────
              _SectionHeader(label: 'Personal Notes'),
              _CardWrapper(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(kSpaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isNotesEditing)
                          GestureDetector(
                            onTap: () => setState(() => _isNotesEditing = true),
                            child: Text(
                              link.notes?.isNotEmpty == true ? link.notes! : 'Tap to write down key takeaways, quotes, or why you saved this link…',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: link.notes?.isNotEmpty == true ? cs.onSurface : cs.onSurface.withValues(alpha: 0.35),
                                height: 1.5,
                              ),
                            ),
                          )
                        else ...[
                          TextField(
                            controller: _notesController,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText: 'Write notes here…',
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: cs.onSurface),
                            autofocus: true,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _isNotesEditing = false),
                                child: Text('Cancel', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
                              ),
                              ElevatedButton(
                                onPressed: () => _saveNotes(link),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.onSurface,
                                  foregroundColor: cs.surface,
                                  elevation: 0,
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),

              // ── Highlights Section ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceLG, kSpaceMD, kSpaceSM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Highlights'.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.35),
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      onPressed: () => _showAddHighlightDialog(context),
                      color: cs.onSurface,
                    ),
                  ],
                ),
              ),

              StreamBuilder<List<LinkHighlight>>(
                stream: highlightsStream,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return _CardWrapper(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(kSpaceMD),
                          child: Text(
                            'Save key snippets by tapping the "+" button.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.4),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: list.map((highlight) {
                      return Dismissible(
                        key: ValueKey(highlight.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: kFreshnessLow.withValues(alpha: 0.2),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: kSpaceLG),
                          child: Icon(Icons.delete_outline, color: kFreshnessLow),
                        ),
                        onDismissed: (_) {
                          ref.read(linkActionsProvider.notifier).deleteHighlight(highlight.id);
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 5),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(kRadiusMD),
                              bottomRight: Radius.circular(kRadiusMD),
                            ),
                            border: Border(
                              left: BorderSide(
                                color: freshnessColor(score),
                                width: 3.5,
                              ),
                              top: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 0.5),
                              right: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 0.5),
                              bottom: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 0.5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(kSpaceMD),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.format_quote, size: 18, color: freshnessColor(score).withValues(alpha: 0.5)),
                                const SizedBox(width: kSpaceSM),
                                Expanded(
                                  child: Text(
                                    highlight.content,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      color: cs.onSurface,
                                      height: 1.5,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              // ── Action Footer Info Cards ──────────────────────────────
              _SectionHeader(label: 'Link History'),
              _CardWrapper(
                children: [
                  _InfoRow(label: 'Added', value: _formatDate(link.createdAt)),
                  if (link.readAt != null) ...[
                    const Divider(height: 0),
                    _InfoRow(label: 'Read', value: _formatDate(link.readAt!)),
                  ],
                  if (link.archivedAt != null) ...[
                    const Divider(height: 0),
                    _InfoRow(label: 'Archived', value: _formatDate(link.archivedAt!)),
                  ],
                  if (link.snoozedSeconds > 0) ...[
                    const Divider(height: 0),
                    _InfoRow(
                      label: 'Snoozes Accumulation',
                      value: '${(link.snoozedSeconds / 3600).toStringAsFixed(1)} hours',
                    ),
                  ],
                ],
              ),

              const SizedBox(height: kSpaceXL),
            ]),
          )
        ],
      ),

      // ── Actions Footer Solid Bar ────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          border: Border(
            top: BorderSide(
              color: cs.outline,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 68,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.open_in_new_outlined,
                  label: 'Open',
                  onPressed: () => _openUrl(link.url),
                ),
                if (link.status == LinkStatus.inbox) ...[
                  _ActionButton(
                    icon: Icons.folder_outlined,
                    label: 'Folder',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (_) => CollectionPickerSheet(
                          linkId: link.id,
                          currentCollectionId: link.collectionId,
                        ),
                        isScrollControlled: true,
                        useSafeArea: true,
                      );
                    },
                  ),
                  _ActionButton(
                    icon: Icons.bedtime_outlined,
                    label: 'Snooze',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (_) => SnoozeSheet(linkId: link.id),
                        isScrollControlled: true,
                        useSafeArea: true,
                      );
                    },
                  ),
                ],
                if (link.status == LinkStatus.inbox)
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'Mark Read',
                    onPressed: () {
                      ref.read(linkActionsProvider.notifier).markAsRead(link.id);
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                  )
                else
                  _ActionButton(
                    icon: Icons.restore_page_outlined,
                    label: 'To Inbox',
                    onPressed: () async {
                      final success = await ref.read(linkActionsProvider.notifier).restoreToInbox(link.id);
                      if (!success) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Archived links cannot be unarchived once they have completely decayed.',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                              ),
                              backgroundColor: kFreshnessLow,
                            ),
                          );
                        }
                        HapticFeedback.vibrate();
                      } else {
                        HapticFeedback.mediumImpact();
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                _ActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: kFreshnessLow,
                  onPressed: () {
                    ref.read(linkActionsProvider.notifier).delete(link.id);
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackCover(BuildContext context, Link link) {
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.04,
            child: Icon(
              Icons.image_outlined,
              size: 140,
              color: cs.onSurface,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  size: 32,
                  color: cs.onSurface.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 8),
                Text(
                  link.domain,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.45),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackFavicon(String domain, ColorScheme cs) {
    final letter = domain.isNotEmpty ? domain[0].toUpperCase() : '?';
    return Center(
      child: Text(
        letter,
        style: GoogleFonts.inter(
          color: cs.onSurface.withValues(alpha: 0.4),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

// ─── Shared Layout Helpers ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceLG, kSpaceMD, kSpaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.35),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardWrapper extends StatelessWidget {
  const _CardWrapper({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayColor = color ?? cs.onSurface;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: displayColor.withValues(alpha: 0.8), size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: displayColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
