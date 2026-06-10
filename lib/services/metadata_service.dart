import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

/// Result of a metadata fetch operation.
class LinkMetadata {
  final String? title;
  final String? faviconUrl;
  final String domain;

  const LinkMetadata({
    this.title,
    this.faviconUrl,
    required this.domain,
  });
}

/// Fetches page title and favicon URL for a given URL.
class MetadataService {
  MetadataService._();
  static const MetadataService instance = MetadataService._();

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

  /// Fetches metadata for [url]: title and favicon.
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
                  'Mozilla/5.0 (compatible; ReadDecay/1.0; +https://readdecay.app)',
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

      return LinkMetadata(
        title: title?.isNotEmpty == true ? title : null,
        faviconUrl: parsedFaviconUrl ?? faviconUrl,
        domain: domain,
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
