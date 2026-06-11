import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../data/database.dart';

class HealthCheckProgressDialog extends StatefulWidget {
  const HealthCheckProgressDialog({super.key, required this.links, required this.db});
  final List<Link> links;
  final AppDatabase db;

  @override
  State<HealthCheckProgressDialog> createState() =>
      _HealthCheckProgressDialogState();
}

class _HealthCheckProgressDialogState
    extends State<HealthCheckProgressDialog> {
  int _currentIndex = 0;
  int _deadCount = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    final client = http.Client();
    for (int i = 0; i < widget.links.length; i++) {
      if (!mounted) break;
      setState(() {
        _currentIndex = i + 1;
      });

      final link = widget.links[i];
      bool isDead = false;

      try {
        final uri = Uri.parse(link.url);
        final response = await client
            .head(uri)
            .timeout(const Duration(seconds: 3));
        if (response.statusCode == 404 || response.statusCode >= 500) {
          isDead = true;
        }
      } catch (_) {
        try {
          final uri = Uri.parse(link.url);
          final response = await client
              .get(uri)
              .timeout(const Duration(seconds: 3));
          if (response.statusCode == 404 || response.statusCode >= 500) {
            isDead = true;
          }
        } catch (_) {
          isDead = true;
        }
      }

      if (isDead) {
        _deadCount++;
        await widget.db.updateLinkDeadStatus(link.id, true);
      } else {
        await widget.db.updateLinkDeadStatus(link.id, false);
      }
    }
    client.close();

    if (mounted) {
      setState(() {
        _isFinished = true;
      });
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        _isFinished ? 'Scan Complete' : 'Checking Link Health...',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!_isFinished) ...[
            const SizedBox(height: 8),
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 20),
            Text(
              'Scanning $_currentIndex of ${widget.links.length} links...',
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ] else ...[
            Text(
              'Found $_deadCount dead or unreachable link${_deadCount == 1 ? "" : "s"} out of ${widget.links.length} links scanned.',
              style: GoogleFonts.inter(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Dead links have been flagged with a ☠️ badge in your inbox.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        if (_isFinished)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
      ],
    );
  }
}
