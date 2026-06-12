import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

/// Result of a metadata fetch operation.
class LinkMetadata {
  final String? title;
  final String? faviconUrl;
  final String domain;
  final String? ogImageUrl;
  final int? estimatedReadMinutes;

  const LinkMetadata({
    this.title,
    this.faviconUrl,
    required this.domain,
    this.ogImageUrl,
    this.estimatedReadMinutes,
  });
}

/// Fetches page title, favicon URL, OG image, and estimates reading time for a URL.
class MetadataService {
  MetadataService._internal();
  static final MetadataService instance = MetadataService._internal();

  /// Extracts domain from [url], e.g. "flutter.dev".
  String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  /// Returns the Google S2 favicon URL for a domain.
  String faviconUrlForDomain(String domain) {
    return 'https://www.google.com/s2/favicons?domain=$domain&sz=64';
  }

  /// Fetches metadata for [url]: title, favicon, OG Image, and Reading Time.
  /// Returns quickly with a domain-derived result if the HTTP fetch fails.
  Future<LinkMetadata> fetch(String url) async {
    final domain = extractDomain(url);
    final faviconUrl = faviconUrlForDomain(domain);

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (compatible; LinkShelf/1.0; +https://linkshelf.app)',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return LinkMetadata(domain: domain, faviconUrl: faviconUrl);
      }

      final document = html_parser.parse(response.body);

      // Try Open Graph title first, then <title> tag.
      String? title;
      final ogTitle = document.head
          ?.querySelector('meta[property="og:title"]')
          ?.attributes['content'];
      if (ogTitle != null && ogTitle.trim().isNotEmpty) {
        title = ogTitle.trim();
      } else {
        title = document.head?.querySelector('title')?.text.trim();
      }

      // Try to get a better favicon from <link> tags.
      String? parsedFaviconUrl;
      final iconLinks = document.head?.querySelectorAll(
        'link[rel~="icon"], link[rel~="shortcut icon"], link[rel~="apple-touch-icon"]',
      );
      if (iconLinks != null && iconLinks.isNotEmpty) {
        final href = iconLinks.last.attributes['href'];
        if (href != null && href.isNotEmpty) {
          if (href.startsWith('http')) {
            parsedFaviconUrl = href;
          } else if (href.startsWith('//')) {
            parsedFaviconUrl = 'https:$href';
          } else {
            final base = Uri.parse(url);
            parsedFaviconUrl = base.resolve(href).toString();
          }
        }
      }

      // Extract OG Image
      String? ogImageUrl = document.head
          ?.querySelector('meta[property="og:image"]')
          ?.attributes['content']
          ?.trim();
      if (ogImageUrl == null || ogImageUrl.isEmpty) {
        ogImageUrl = document.head
            ?.querySelector('meta[name="twitter:image"]')
            ?.attributes['content']
            ?.trim();
      }

      // Estimate Reading Time from word count
      int? readMinutes;
      final body = document.body;
      if (body != null) {
        // Clone/copy body text elements and strip script, style, noscript, etc.
        final cleanBody = body.clone(true);
        cleanBody
            .querySelectorAll(
              'script, style, noscript, iframe, header, footer, nav',
            )
            .forEach((e) => e.remove());
        final text = cleanBody.text.trim();
        final words = text
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .length;
        if (words > 0) {
          readMinutes = (words / 200).ceil();
          if (readMinutes < 1) readMinutes = 1;
        }
      }

      return LinkMetadata(
        title: title?.isNotEmpty == true ? title : null,
        faviconUrl: parsedFaviconUrl ?? faviconUrl,
        domain: domain,
        ogImageUrl: ogImageUrl?.isNotEmpty == true ? ogImageUrl : null,
        estimatedReadMinutes: readMinutes,
      );
    } catch (_) {
      return LinkMetadata(domain: domain, faviconUrl: faviconUrl);
    }
  }

  /// Quick validation: returns true if [url] looks like a valid http(s) URL.
  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url.trim());
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Normalize URL: add https:// if scheme is missing.
  String normalizeUrl(String url) {
    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }
}
