import 'package:zedu/core/core.dart';

/// The OpenGraph fields a page advertises, or null when it has none.
class LinkPreviewData {
  const LinkPreviewData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
  });

  final String title;
  final String description;
  final String imageUrl;
  final String url;

  bool get isEmpty =>
      title.isEmpty && description.isEmpty && imageUrl.isEmpty;
}

/// Fetches OpenGraph metadata for [url]. Tests replace this to avoid the
/// network.
@visibleForTesting
Future<LinkPreviewData> Function(String url) linkPreviewFetcher =
    _fetchLinkPreview;

final Map<String, LinkPreviewData> _previewCache = {};

Future<LinkPreviewData> _fetchLinkPreview(String url) async {
  final cached = _previewCache[url];
  if (cached != null) return cached;

  final dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      headers: const {'User-Agent': 'Zedu Desktop link preview'},
    ),
  );
  try {
    final response = await dio.get<String>(url);
    final data = _parseOpenGraph(url, response.data ?? '');
    _remember(url, data);
    return data;
  } catch (error) {
    final data = const LinkPreviewData(
      title: '',
      description: '',
      imageUrl: '',
      url: '',
    );
    _remember(url, data);
    return data;
  }
}

void _remember(String url, LinkPreviewData data) {
  if (_previewCache.length >= 50) _previewCache.clear();
  _previewCache[url] = data;
}

String _decodeHtml(String value) => value
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'");

String _metaContent(String html, String property) {
  for (final match in RegExp(
    r'<meta[^>]+>',
    caseSensitive: false,
  ).allMatches(html)) {
    final tag = match.group(0)!;
    final hasProperty = RegExp(
      '(property|name)\\s*=\\s*["\']$property["\']',
      caseSensitive: false,
    ).hasMatch(tag);
    if (!hasProperty) continue;
    final content = RegExp(
      "content\\s*=\\s*[\"']([^\"']*)[\"']",
      caseSensitive: false,
    ).firstMatch(tag)?.group(1);
    if (content != null && content.isNotEmpty) return _decodeHtml(content);
  }
  return '';
}

String _tagText(String html, String tag) {
  final match = RegExp(
    '<$tag[^>]*>(.*?)</$tag>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(html);
  if (match == null) return '';
  return _decodeHtml(match.group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').trim());
}

LinkPreviewData _parseOpenGraph(String url, String html) {
  final title = _metaContent(html, 'og:title').isNotEmpty
      ? _metaContent(html, 'og:title')
      : _tagText(html, 'title');
  final description = _metaContent(html, 'og:description').isNotEmpty
      ? _metaContent(html, 'og:description')
      : _metaContent(html, 'description');
  var image = _metaContent(html, 'og:image');
  if (image.isNotEmpty && image.startsWith('/')) {
    final base = Uri.parse(url);
    image = base.replace(path: image).toString();
  }
  return LinkPreviewData(
    title: title.trim(),
    description: description.trim(),
    imageUrl: image,
    url: url,
  );
}

/// Unfurls [url] into an OpenGraph preview card. Renders nothing until the
/// metadata arrives, and nothing at all when the page advertises none or the
/// fetch fails, so messages without previews look exactly as before.
class LinkPreviewCard extends StatefulWidget {
  const LinkPreviewCard({super.key, required this.url});

  final String url;

  @override
  State<LinkPreviewCard> createState() => _LinkPreviewCardState();
}

class _LinkPreviewCardState extends State<LinkPreviewCard> {
  LinkPreviewData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await linkPreviewFetcher(widget.url);
    if (!mounted || data.isEmpty) return;
    setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) return const SizedBox.shrink();

    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => openMessageLink(widget.url),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        data.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Uri.parse(data.url).host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                      if (data.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          data.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
