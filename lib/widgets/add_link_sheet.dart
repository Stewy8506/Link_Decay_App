import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/providers.dart';
import '../services/metadata_service.dart';
import '../utils/constants.dart';

/// Bottom sheet for adding a new link manually.
class AddLinkSheet extends ConsumerStatefulWidget {
  const AddLinkSheet({super.key});

  @override
  ConsumerState<AddLinkSheet> createState() => _AddLinkSheetState();
}

class _AddLinkSheetState extends ConsumerState<AddLinkSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
      await ref.read(linkActionsProvider.notifier).saveLink(url);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to save link. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final cs = Theme.of(context).colorScheme;

    return Padding(
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
                color: cs.outline,
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
                  : null,
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _submit(),
            textInputAction: TextInputAction.go,
          ),
          const SizedBox(height: kSpaceSM),

          // Paste button
          TextButton.icon(
            onPressed: _pasteFromClipboard,
            icon: Icon(
              Icons.content_paste_outlined,
              size: 16,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
            label: Text(
              'Paste from clipboard',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: kSpaceMD),

          // Save button — inverted neutral (matches FAB style)
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
                        // Inverted neutral: onSurface bg, surface text
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
    );
  }
}
