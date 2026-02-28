import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/collection.dart';

class CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onLockToggle;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
    required this.onDelete,
    this.onLockToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.folder,
                      size: 32.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                    if (collection.isLocked)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock,
                            size: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (collection.description != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        collection.description!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${collection.linkCount} links',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatDate(collection.updatedAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20.sp),
                onSelected: (value) {
                  if (value == 'lock' && onLockToggle != null) {
                    onLockToggle!();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'lock',
                    child: Row(
                      children: [
                        Icon(
                          collection.isLocked ? Icons.lock_open : Icons.lock,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(collection.isLocked ? 'فتح القفل' : 'قفل المجلد'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        const Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
