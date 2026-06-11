import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../services/metadata_service.dart';
import '../utils/constants.dart';

/// Bottom sheet for adding a new link manually, with optional folder placement.
class AddLinkSheet extends ConsumerStatefulWidget {
  const AddLinkSheet({super.key, this.preSelectedCollectionId});
  final String? preSelectedCollectionId;

  @override
  ConsumerState<AddLinkSheet> createState() => _AddLinkSheetState();
}

class _AddLinkSheetState extends ConsumerState<AddLinkSheet> {
  final _controller = TextEditingController();
  final _titleController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _error;
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    _selectedCollectionId = widget.preSelectedCollectionId;
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _checkClipboardAndAutoPaste();
    });
  }

  void _onTextChanged() {
    setState(() {}); // to show/hide suffixIcon dynamically
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _checkClipboardAndAutoPaste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text != null && text.isNotEmpty) {
        final svc = MetadataService.instance;
        final url = svc.normalizeUrl(text);
        if (svc.isValidUrl(url)) {
          setState(() {
            _controller.text = text;
            _error = null;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _controller.text = data!.text!;
      setState(() => _error = null);
    }
  }

  Future<void> _submit() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;

    final svc = MetadataService.instance;
    final url = svc.normalizeUrl(raw);

    if (!svc.isValidUrl(url)) {
      setState(() => _error = 'Please enter a valid URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(linkActionsProvider.notifier).saveLink(
            url,
            collectionId: _selectedCollectionId,
            title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to save link. Please try again.';
      });
    }
  }

  void _showCreateFolderDialog() {
    final folderNameController = TextEditingController();
    final folderEmojiController = TextEditingController(text: '📁');
    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(
            'New Folder',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: folderEmojiController,
                decoration: const InputDecoration(
                  labelText: 'Emoji Icon',
                  hintText: 'e.g. 📚, 🎥, 📰',
                ),
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: folderNameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'e.g. Reading, Dev, Watch Later',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.6))),
            ),
            TextButton(
              onPressed: () async {
                final name = folderNameController.text.trim();
                if (name.isNotEmpty) {
                  final newId = await ref.read(linkActionsProvider.notifier).addCollection(
                    name,
                    folderEmojiController.text.trim().isNotEmpty ? folderEmojiController.text.trim() : '📁',
                  );
                  if (!context.mounted) return;
                  setState(() {
                    _selectedCollectionId = newId;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Create', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.onSurface)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final collectionsAsync = ref.watch(collectionsProvider);
    final cs = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(kSpaceMD, kSpaceLG, kSpaceMD, kSpaceMD + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: kSpaceLG),

              Text(
                'Save a link',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: kSpaceXS),
              Text(
                'Paste a URL to add it to your reading list.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: kSpaceLG),

              // URL input
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: GoogleFonts.inter(fontSize: 15, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'https://example.com/article',
                  prefixIcon: Icon(
                    Icons.link,
                    color: cs.onSurface.withValues(alpha: 0.3),
                    size: 20,
                  ),
                  errorText: _error,
                  errorStyle: GoogleFonts.inter(color: kFreshnessLow, fontSize: 12),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          color: cs.onSurface.withValues(alpha: 0.3),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _error = null);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.content_paste_outlined, size: 18),
                          color: cs.onSurface.withValues(alpha: 0.4),
                          onPressed: _pasteFromClipboard,
                        ),
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: kSpaceMD),

              // Custom Name/Title Input (Optional)
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Custom Name (Optional)',
                  hintText: 'e.g. LinkShelf Source Code',
                ),
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: kSpaceMD),

              // Collection Folder selection
              Text(
                'SAVE TO FOLDER',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.35),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: collectionsAsync.when(
                  loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1))),
                  error: (e, st) => const Text('Error loading folders'),
                  data: (folders) {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ChoiceChip(
                          avatar: const Text('📥'),
                          label: const Text('Inbox Only'),
                          selected: _selectedCollectionId == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCollectionId = null);
                            }
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor: cs.onSurface,
                          showCheckmark: false,
                          side: BorderSide(
                            color: _selectedCollectionId == null ? Colors.transparent : cs.outline,
                            width: 0.5,
                          ),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: _selectedCollectionId == null ? FontWeight.w600 : FontWeight.w400,
                            color: _selectedCollectionId == null ? cs.surface : cs.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                        ...folders.map((folder) {
                          final isSelected = _selectedCollectionId == folder.id;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ChoiceChip(
                              avatar: Text(folder.emoji ?? '📁'),
                              label: Text(folder.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCollectionId = selected ? folder.id : null;
                                });
                              },
                              backgroundColor: Colors.transparent,
                              selectedColor: cs.onSurface,
                              showCheckmark: false,
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : cs.outline,
                                width: 0.5,
                              ),
                              labelStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? cs.surface : cs.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                          );
                        }),
                        // "+ New Folder" chip
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: InputChip(
                            avatar: Icon(Icons.add, size: 16, color: cs.onSurface.withValues(alpha: 0.65)),
                            label: const Text('New Folder'),
                            onPressed: _showCreateFolderDialog,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: cs.outline, width: 0.5),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: cs.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: kSpaceLG),

              // Save button — inverted neutral
              SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedSwitcher(
                  duration: kDurationFast,
                  child: _isLoading
                      ? Container(
                          key: const ValueKey('loading'),
                          decoration: BoxDecoration(
                            color: cs.outline.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(kRadiusMD),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        )
                      : FilledButton(
                          key: const ValueKey('save'),
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.onSurface,
                            foregroundColor: cs.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kRadiusMD),
                            ),
                            textStyle: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
