import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/link_preview.dart';

class LinkPreviewCard extends StatelessWidget {
  final LinkPreview link;
  final VoidCallback onDelete;

  const LinkPreviewCard({
    super.key,
    required this.link,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchUrl(link.url),
        onLongPress: () => _showOptions(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - YouTube-like 16:9 ratio
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: link.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: link.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image,
                          size: 48.sp,
                          color: Colors.grey,
                        ),
                      )
                    : Icon(
                        Icons.link,
                        size: 48.sp,
                        color: Colors.grey,
                      ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    link.title ?? 'No title',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Description
                  if (link.description != null) ...[
                    Text(
                      link.description!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                  ],
                  // Domain
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        size: 14.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          _getDomain(link.url),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Drag handle for reordering
                      Icon(
                        Icons.drag_handle,
                        size: 20.sp,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Open'),
              onTap: () {
                Navigator.pop(context);
                _launchUrl(link.url);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy URL'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: link.url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                Share.share(link.url);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
