import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../../../../core/error/exceptions.dart';

abstract class LinkMetadataDataSource {
  Future<LinkMetadata> fetchMetadata(String url);
  List<String> extractUrls(String text);
}

class LinkMetadataDataSourceImpl implements LinkMetadataDataSource {
  final http.Client client;
  
  LinkMetadataDataSourceImpl({http.Client? client}) 
      : client = client ?? http.Client();

  final RegExp urlRegex = RegExp(
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    caseSensitive: false,
  );

  @override
  Future<LinkMetadata> fetchMetadata(String url) async {
    try {
      // Ensure URL has protocol
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch URL: ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);
      
      // Extract metadata
      final title = _extractTitle(document, url);
      final description = _extractDescription(document);
      final imageUrl = _extractImage(document, url);

      return LinkMetadata(
        title: title,
        description: description,
        imageUrl: imageUrl,
      );
    } catch (e) {
      // Return basic metadata if fetch fails
      return LinkMetadata(
        title: _extractDomainFromUrl(url),
        description: url,
        imageUrl: null,
      );
    }
  }

  String _extractTitle(Document document, String url) {
    // Try Open Graph title
    final ogTitle = document.querySelector('meta[property="og:title"]');
    if (ogTitle != null && ogTitle.attributes['content']?.isNotEmpty == true) {
      return ogTitle.attributes['content']!;
    }

    // Try Twitter title
    final twitterTitle = document.querySelector('meta[name="twitter:title"]');
    if (twitterTitle != null && twitterTitle.attributes['content']?.isNotEmpty == true) {
      return twitterTitle.attributes['content']!;
    }

    // Try regular title tag
    final titleElement = document.querySelector('title');
    if (titleElement != null && titleElement.text.isNotEmpty) {
      return titleElement.text;
    }

    // Fallback to domain name
    return _extractDomainFromUrl(url);
  }

  String? _extractDescription(Document document) {
    // Try Open Graph description
    final ogDescription = document.querySelector('meta[property="og:description"]');
    if (ogDescription != null && ogDescription.attributes['content']?.isNotEmpty == true) {
      return ogDescription.attributes['content'];
    }

    // Try Twitter description
    final twitterDescription = document.querySelector('meta[name="twitter:description"]');
    if (twitterDescription != null && twitterDescription.attributes['content']?.isNotEmpty == true) {
      return twitterDescription.attributes['content'];
    }

    // Try meta description
    final metaDescription = document.querySelector('meta[name="description"]');
    if (metaDescription != null && metaDescription.attributes['content']?.isNotEmpty == true) {
      return metaDescription.attributes['content'];
    }

    return null;
  }

  String? _extractImage(Document document, String baseUrl) {
    // Try Open Graph image
    final ogImage = document.querySelector('meta[property="og:image"]');
    if (ogImage != null && ogImage.attributes['content']?.isNotEmpty == true) {
      return _makeAbsoluteUrl(ogImage.attributes['content']!, baseUrl);
    }

    // Try Twitter image
    final twitterImage = document.querySelector('meta[name="twitter:image"]');
    if (twitterImage != null && twitterImage.attributes['content']?.isNotEmpty == true) {
      return _makeAbsoluteUrl(twitterImage.attributes['content']!, baseUrl);
    }

    // Try to find first image in content
    final firstImg = document.querySelector('img');
    if (firstImg != null && firstImg.attributes['src']?.isNotEmpty == true) {
      return _makeAbsoluteUrl(firstImg.attributes['src']!, baseUrl);
    }

    return null;
  }

  String _makeAbsoluteUrl(String url, String baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    try {
      final base = Uri.parse(baseUrl);
      if (url.startsWith('//')) {
        return '${base.scheme}:$url';
      }
      if (url.startsWith('/')) {
        return '${base.scheme}://${base.host}$url';
      }
      return '${base.scheme}://${base.host}/${base.path}/$url';
    } catch (e) {
      return url;
    }
  }

  String _extractDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url;
    }
  }

  @override
  List<String> extractUrls(String text) {
    try {
      final matches = urlRegex.allMatches(text);
      final urls = matches.map((match) => match.group(0)!).toSet().toList();
      return urls;
    } catch (e) {
      throw const FormatException('Failed to extract URLs');
    }
  }
}

class LinkMetadata {
  final String title;
  final String? description;
  final String? imageUrl;

  LinkMetadata({
    required this.title,
    this.description,
    this.imageUrl,
  });
}
