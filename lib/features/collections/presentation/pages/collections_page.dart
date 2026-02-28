import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/sync_service_v2.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../links/presentation/pages/links_page.dart';
import '../../data/datasources/collection_local_datasource.dart';
import '../bloc/collection_bloc.dart';
import '../widgets/collection_card.dart';
import '../widgets/create_collection_dialog.dart';
import '../widgets/lock_collection_dialog.dart';
import '../widgets/unlock_collection_dialog.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<CollectionBloc>()..add(LoadCollectionsEvent()),
        ),
        BlocProvider(
          create: (_) => getIt<AuthBloc>(),
        ),
      ],
      child: const _CollectionsPageContent(),
    );
  }
}

class _CollectionsPageContent extends StatelessWidget {
  const _CollectionsPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المعاينات'),
        centerTitle: true,
        actions: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                  (route) => false,
                );
              }
            },
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog(context);
                } else if (value == 'sync') {
                  _showSyncDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'sync',
                  child: Row(
                    children: [
                      Icon(Icons.sync),
                      SizedBox(width: 8),
                      Text('مزامنة البيانات'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocConsumer<CollectionBloc, CollectionState>(
        listener: (context, state) {
          if (state is CollectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CollectionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Collection created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CollectionLoaded) {
            if (state.collections.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No collections yet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap + to create your first collection',
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
                context.read<CollectionBloc>().add(LoadCollectionsEvent());
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.collections.length,
                itemBuilder: (context, index) {
                  final collection = state.collections[index];
                  return CollectionCard(
                    collection: collection,
                    onTap: () => _handleCollectionTap(context, collection),
                    onDelete: () {
                      _showDeleteDialog(context, collection.id);
                    },
                    onLockToggle: () {
                      _showLockDialog(context, collection);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(SignOutEvent());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مزامنة البيانات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر نوع المزامنة:'),
            SizedBox(height: 8.h),
            const Text(
              '• تنزيل: جلب البيانات من السحابة\n'
              '• رفع (دمج): إضافة البيانات المحلية للسحابة\n'
              '• رفع (استبدال): حذف السحابة ورفع المحلي',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _syncFromFirebase(context);
            },
            child: const Text('تنزيل من السحابة'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _syncToFirebase(context, replaceAll: false);
            },
            child: const Text('رفع (دمج)'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _showReplaceConfirmDialog(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('رفع (استبدال)'),
          ),
        ],
      ),
    );
  }

  void _showReplaceConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد الاستبدال'),
          ],
        ),
        content: const Text(
          'سيتم حذف جميع البيانات الموجودة في السحابة واستبدالها بالبيانات المحلية.\n\n'
          'هذه العملية لا يمكن التراجع عنها!\n\n'
          'هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _syncToFirebase(context, replaceAll: true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('نعم، استبدل'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncFromFirebase(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري التنزيل من السحابة...'),
          duration: Duration(seconds: 2),
        ),
      );

      final syncService = getIt<SyncServiceV2>();
      await syncService.fullSyncFromFirebase();

      if (context.mounted) {
        context.read<CollectionBloc>().add(LoadCollectionsEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التنزيل بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التنزيل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncToFirebase(BuildContext context, {bool replaceAll = false}) async {
    try {
      // Get current user info
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم تسجيل الدخول!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Log User ID for easy access
      AppLogger.info('🔑 USER ID: ${user.uid}');
      AppLogger.info('📧 USER EMAIL: ${user.email}');
      AppLogger.info('🔗 FIREBASE PATH: collections/ (direct table)');
      AppLogger.info('🔄 REPLACE MODE: $replaceAll');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            replaceAll 
              ? 'جاري استبدال البيانات في السحابة...\nUser: ${user.email}'
              : 'جاري الرفع للسحابة...\nUser: ${user.email}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      final syncService = getIt<SyncServiceV2>();
      await syncService.fullSyncToFirebase(replaceAll: replaceAll);

      // Verify data was uploaded
      final snapshot = await FirebaseFirestore.instance
          .collection('collections')
          .where('userId', isEqualTo: user.uid)
          .get();

      AppLogger.info('✅ COLLECTIONS UPLOADED: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        AppLogger.info('   📁 ${doc.data()['name']} (${doc.data()['linkCount']} links)');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              replaceAll
                ? 'تم الاستبدال بنجاح!\n'
                  'المجموعات: ${snapshot.docs.length}\n'
                  'User ID: ${user.uid.substring(0, 8)}...'
                : 'تم الرفع بنجاح!\n'
                  'المجموعات: ${snapshot.docs.length}\n'
                  'User ID: ${user.uid.substring(0, 8)}...',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('❌ SYNC ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الرفع: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CollectionBloc>(),
        child: const CreateCollectionDialog(),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String collectionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Collection'),
        content: const Text(
          'Are you sure you want to delete this collection? All links will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CollectionBloc>().add(
                    DeleteCollectionEvent(collectionId),
                  );
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleCollectionTap(BuildContext context, collection) async {
    // Check if collection is locked
    if (collection.isLocked) {
      showDialog(
        context: context,
        builder: (dialogContext) => UnlockCollectionDialog(
          correctPin: collection.lockPin!,
          onUnlocked: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LinksPage(collection: collection),
              ),
            );
            if (context.mounted) {
              context.read<CollectionBloc>().add(LoadCollectionsEvent());
            }
          },
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LinksPage(collection: collection),
        ),
      );
      if (context.mounted) {
        context.read<CollectionBloc>().add(LoadCollectionsEvent());
      }
    }
  }

  void _showLockDialog(BuildContext context, collection) {
    showDialog(
      context: context,
      builder: (dialogContext) => LockCollectionDialog(
        isCurrentlyLocked: collection.isLocked,
        onConfirm: (isLocked, pin) async {
          try {
            final localDataSource = getIt<CollectionLocalDataSource>();
            final model = await localDataSource.getCollectionById(collection.id);
            final updated = model.copyWith(
              isLocked: isLocked,
              lockPin: pin,
            );
            await localDataSource.updateCollection(updated);

            if (context.mounted) {
              context.read<CollectionBloc>().add(LoadCollectionsEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isLocked ? 'تم قفل المجلد' : 'تم فتح القفل'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشلت العملية: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
