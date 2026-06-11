import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';

class CustomFilterCreatorScreen extends ConsumerStatefulWidget {
  const CustomFilterCreatorScreen({super.key});

  @override
  ConsumerState<CustomFilterCreatorScreen> createState() => _CustomFilterCreatorScreenState();
}

class _CustomFilterCreatorScreenState extends ConsumerState<CustomFilterCreatorScreen> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController(text: '⚡');
  final _tagsController = TextEditingController();
  final _domainsController = TextEditingController();

  double? _minFreshness;
  double? _maxFreshness;
  int? _minReadTime;
  int? _maxReadTime;

  String _snoozeFilter = 'all'; // 'all', 'exclude_snoozed', 'only_snoozed'
  String _sortField = 'freshness_asc'; // 'freshness_asc', 'freshness_desc', 'created_desc', 'created_asc', 'read_time_asc', 'title_asc'

  final List<String> _selectedCollections = [];

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _tagsController.dispose();
    _domainsController.dispose();
    super.dispose();
  }

  void _saveFilter() {
    final name = _nameController.text.trim();
    final icon = _iconController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a list name')),
      );
      return;
    }

    ref.read(linkActionsProvider.notifier).addCustomFilter(
          name: name,
          icon: icon.isNotEmpty ? icon : '⚡',
          minFreshness: _minFreshness,
          maxFreshness: _maxFreshness,
          tags: _tagsController.text.trim().isNotEmpty ? _tagsController.text.trim() : null,
          collections: _selectedCollections.isNotEmpty ? _selectedCollections.join(',') : null,
          domains: _domainsController.text.trim().isNotEmpty ? _domainsController.text.trim() : null,
          minReadTime: _minReadTime,
          maxReadTime: _maxReadTime,
          snoozeFilter: _snoozeFilter,
          sortField: _sortField,
        );

    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Smart List'),
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveFilter,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kSpaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // List Info Card
            _CardSection(
              title: 'General Info',
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _iconController,
                        decoration: const InputDecoration(labelText: 'Icon'),
                        style: const TextStyle(fontSize: 22),
                        maxLength: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: kSpaceMD),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Smart List Name',
                          hintText: 'e.g. Long Weekend Reads',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Freshness Boundaries
            _CardSection(
              title: 'Freshness Range',
              children: [
                CheckboxListTile(
                  title: const Text('Filter by Freshness score'),
                  value: _minFreshness != null || _maxFreshness != null,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _minFreshness = 0.0;
                        _maxFreshness = 1.0;
                      } else {
                        _minFreshness = null;
                        _maxFreshness = null;
                      }
                    });
                  },
                  activeColor: cs.onSurface,
                ),
                if (_minFreshness != null && _maxFreshness != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
                    child: RangeSlider(
                      values: RangeValues(_minFreshness!, _maxFreshness!),
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      labels: RangeLabels(
                        _minFreshness!.toStringAsFixed(2),
                        _maxFreshness!.toStringAsFixed(2),
                      ),
                      onChanged: (values) {
                        setState(() {
                          _minFreshness = values.start;
                          _maxFreshness = values.end;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
                    child: Text(
                      'Shows links between ${(_minFreshness! * 100).toStringAsFixed(0)}% and ${(_maxFreshness! * 100).toStringAsFixed(0)}% freshness.',
                      style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ],
            ),

            // Read Time Boundaries
            _CardSection(
              title: 'Estimated Reading Time',
              children: [
                CheckboxListTile(
                  title: const Text('Filter by reading time'),
                  value: _minReadTime != null || _maxReadTime != null,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _minReadTime = 1;
                        _maxReadTime = 20;
                      } else {
                        _minReadTime = null;
                        _maxReadTime = null;
                      }
                    });
                  },
                  activeColor: cs.onSurface,
                ),
                if (_minReadTime != null && _maxReadTime != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMD),
                    child: RangeSlider(
                      values: RangeValues(_minReadTime!.toDouble(), _maxReadTime!.toDouble()),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      labels: RangeLabels(
                        '$_minReadTime min',
                        '$_maxReadTime min',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _minReadTime = values.start.round();
                          _maxReadTime = values.end.round();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
                    child: Text(
                      'Shows links taking between $_minReadTime and $_maxReadTime minutes to read.',
                      style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ],
            ),

            // Tags Inclusions
            _CardSection(
              title: 'Filter by Tags',
              children: [
                Padding(
                  padding: const EdgeInsets.all(kSpaceMD),
                  child: TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. dev, cooking, article (comma-separated)',
                      labelText: 'Tags (Inclusions)',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),

            // Folder/Collection selections
            _CardSection(
              title: 'Filter by Folders',
              children: [
                collectionsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const SizedBox.shrink(),
                  data: (folders) {
                    if (folders.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(kSpaceMD),
                        child: Text(
                          'No folders created yet.',
                          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(kSpaceSM),
                      child: Wrap(
                        spacing: 8,
                        children: folders.map((folder) {
                          final isSelected = _selectedCollections.contains(folder.id);
                          return FilterChip(
                            avatar: Text(folder.emoji ?? '📁'),
                            label: Text(folder.name),
                            selected: isSelected,
                            selectedColor: cs.onSurface.withValues(alpha: 0.15),
                            checkmarkColor: cs.onSurface,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCollections.add(folder.id);
                                } else {
                                  _selectedCollections.remove(folder.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Target Domains
            _CardSection(
              title: 'Filter by Domains',
              children: [
                Padding(
                  padding: const EdgeInsets.all(kSpaceMD),
                  child: TextField(
                    controller: _domainsController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. youtube.com, medium.com (comma-separated)',
                      labelText: 'Domains (Inclusions)',
                    ),
                  ),
                ),
              ],
            ),

            // Snooze state filter
            _CardSection(
              title: 'Snooze Filter',
              children: [
                Padding(
                  padding: const EdgeInsets.all(kSpaceMD),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('All')),
                      ButtonSegment(value: 'exclude_snoozed', label: Text('No Snooze')),
                      ButtonSegment(value: 'only_snoozed', label: Text('Snoozed')),
                    ],
                    selected: {_snoozeFilter},
                    showSelectedIcon: false,
                    onSelectionChanged: (val) {
                      setState(() => _snoozeFilter = val.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: cs.onSurface,
                      selectedForegroundColor: cs.surface,
                    ),
                  ),
                ),
              ],
            ),

            // Custom sorting preferences
            _CardSection(
              title: 'Default Sorting for this List',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
                  child: DropdownButton<String>(
                    value: _sortField,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    onChanged: (val) => setState(() => _sortField = val!),
                    items: [
                      DropdownMenuItem(value: 'freshness_asc', child: Text('Stalest first (Score Asc)', style: GoogleFonts.inter())),
                      DropdownMenuItem(value: 'freshness_desc', child: Text('Freshest first (Score Desc)', style: GoogleFonts.inter())),
                      DropdownMenuItem(value: 'created_desc', child: Text('Newest saved first', style: GoogleFonts.inter())),
                      DropdownMenuItem(value: 'created_asc', child: Text('Oldest saved first', style: GoogleFonts.inter())),
                      DropdownMenuItem(value: 'read_time_asc', child: Text('Shortest read time first', style: GoogleFonts.inter())),
                      DropdownMenuItem(value: 'title_asc', child: Text('Alphabetical (Title A-Z)', style: GoogleFonts.inter())),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, kSpaceMD, 4, kSpaceSM),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.35),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(kRadiusMD),
            border: Border.all(color: cs.outline, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}
