import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../collections/domain/entities/collection.dart';
import '../bloc/link_bloc.dart';
import '../widgets/add_links_dialog.dart';
import '../widgets/link_preview_card.dart';

class LinksPage extends StatelessWidget {
  final Collection collection;

  const LinksPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LinkBloc>()..add(LoadLinksEvent(collection.id)),
      child: _LinksPageContent(collection: collection),
    );
  }
}

class _LinksPageContent extends StatelessWidget {
  final Collection collection;
  
  const _LinksPageContent({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        actions: [
          BlocBuilder<LinkBloc, LinkState>(
            builder: (context, state) {
              if (state is LinkLoaded && state.links.isNotEmpty) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'copy_all') {
                      _copyAllLinks(context, state.links);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'copy_all',
                      child: Row(
                        children: [
                          Icon(Icons.copy_all),
                          SizedBox(width: 8),
                          Text('نسخ جميع الروابط'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_link),
            onPressed: () => _showAddLinksDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<LinkBloc, LinkState>(
        listener: (context, state) {
          if (state is LinkError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is LinksAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.links.length} link(s) added'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LinkLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LinkAdding) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    'Fetching link previews...',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
            );
          }

          if (state is LinkLoaded) {
            if (state.links.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.link_off,
                      size: 80.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No links yet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap + to add links',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<LinkBloc>().add(LoadLinksEvent(collection.id));
              },
              child: ReorderableListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.links.length,
                onReorder: (oldIndex, newIndex) {
                  // سيتم تنفيذ إعادة الترتيب لاحقاً
                },
                itemBuilder: (context, index) {
                  final link = state.links[index];
                  return Padding(
                    key: ValueKey(link.id),
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: LinkPreviewCard(
                      link: link,
                      onDelete: () {
                        context.read<LinkBloc>().add(
                              DeleteLinkEvent(
                                linkId: link.id,
                                collectionId: collection.id,
                              ),
                            );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLinksDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLinksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<LinkBloc>(),
        child: AddLinksDialog(collectionId: collection.id),
      ),
    );
  }

  void _copyAllLinks(BuildContext context, List links) {
    if (links.isEmpty) return;

    // تجميع جميع الروابط مع فاصل
    final allLinks = links.map((link) => link.url).join('\n\n');

    // نسخ للحافظة
    Clipboard.setData(ClipboardData(text: allLinks));

    // إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ ${links.length} رابط'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: ''));
          },
        ),
      ),
    );
  }
}
