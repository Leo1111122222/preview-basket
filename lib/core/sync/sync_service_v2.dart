import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../features/collections/data/datasources/collection_local_datasource.dart';
import '../../features/collections/data/models/collection_model.dart';
import '../../features/links/data/datasources/link_local_datasource.dart';
import '../../features/links/data/models/link_preview_model.dart';
import '../utils/logger.dart';

/// نظام المزامنة الجديد - جداول مباشرة
/// collections/ و links/ بدلاً من users/{userId}/collections/
class SyncServiceV2 {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;
  final CollectionLocalDataSource collectionLocalDataSource;
  final LinkLocalDataSource linkLocalDataSource;

  SyncServiceV2({
    required this.firestore,
    required this.firebaseAuth,
    required this.collectionLocalDataSource,
    required this.linkLocalDataSource,
  });

  String? get _currentUserId => firebaseAuth.currentUser?.uid;

  // ============ COLLECTIONS ============

  /// رفع المجموعات إلى Firebase (جدول collections مباشر)
  Future<void> syncCollectionsToFirebase() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        AppLogger.warning('No user logged in, skipping sync');
        return;
      }

      final localCollections = await collectionLocalDataSource.getAllCollections();
      AppLogger.info('Syncing ${localCollections.length} collections to Firebase');

      for (final collection in localCollections) {
        await _retryOperation(() async {
          final collectionWithUser = collection.copyWith(userId: userId);
          await firestore
              .collection('collections')
              .doc(collection.id)
              .set(collectionWithUser.toFirestore(), SetOptions(merge: true));
        });

        AppLogger.info('✅ Synced collection: ${collection.name}');
      }
    } catch (e) {
      AppLogger.error('Error syncing collections to Firebase: $e');
      rethrow;
    }
  }

  /// تنزيل المجموعات من Firebase
  Future<void> syncCollectionsFromFirebase() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        AppLogger.warning('No user logged in, skipping sync');
        return;
      }

      final snapshot = await firestore
          .collection('collections')
          .where('userId', isEqualTo: userId)
          .get();

      AppLogger.info('Found ${snapshot.docs.length} collections in Firebase');

      for (final doc in snapshot.docs) {
        final collection = CollectionModel.fromFirestore(doc.data());
        await collectionLocalDataSource.updateCollection(collection);
        AppLogger.info('✅ Downloaded collection: ${collection.name}');
      }
    } catch (e) {
      AppLogger.error('Error syncing collections from Firebase: $e');
      rethrow;
    }
  }

  /// حذف مجموعة من Firebase
  Future<void> deleteCollectionFromFirebase(String collectionId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      // حذف جميع الروابط المرتبطة
      final linksSnapshot = await firestore
          .collection('links')
          .where('collectionId', isEqualTo: collectionId)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in linksSnapshot.docs) {
        await doc.reference.delete();
      }

      // حذف المجموعة
      await firestore.collection('collections').doc(collectionId).delete();

      AppLogger.info('✅ Deleted collection $collectionId from Firebase');
    } catch (e) {
      AppLogger.error('Error deleting collection from Firebase: $e');
    }
  }

  // ============ LINKS ============

  /// رفع الروابط إلى Firebase (جدول links مباشر)
  Future<void> syncLinksToFirebase(String collectionId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        AppLogger.warning('No user logged in, skipping sync');
        return;
      }

      final localLinks = await linkLocalDataSource.getLinksByCollection(collectionId);
      AppLogger.info('Syncing ${localLinks.length} links to Firebase');

      for (final link in localLinks) {
        await _retryOperation(() async {
          final linkWithUser = link.copyWith(userId: userId);
          await firestore
              .collection('links')
              .doc(link.id)
              .set(linkWithUser.toFirestore(), SetOptions(merge: true));
        });

        AppLogger.info('✅ Synced link: ${link.title ?? link.url}');
      }
    } catch (e) {
      AppLogger.error('Error syncing links to Firebase: $e');
      rethrow;
    }
  }

  /// تنزيل الروابط من Firebase
  Future<void> syncLinksFromFirebase(String collectionId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        AppLogger.warning('No user logged in, skipping sync');
        return;
      }

      final snapshot = await firestore
          .collection('links')
          .where('collectionId', isEqualTo: collectionId)
          .where('userId', isEqualTo: userId)
          .get();

      AppLogger.info('Found ${snapshot.docs.length} links in Firebase');

      for (final doc in snapshot.docs) {
        final link = LinkPreviewModel.fromFirestore(doc.data());
        await linkLocalDataSource.addLink(link);
        AppLogger.info('✅ Downloaded link: ${link.title ?? link.url}');
      }
    } catch (e) {
      AppLogger.error('Error syncing links from Firebase: $e');
      rethrow;
    }
  }

  /// حذف رابط من Firebase
  Future<void> deleteLinkFromFirebase(String linkId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await firestore.collection('links').doc(linkId).delete();

      AppLogger.info('✅ Deleted link $linkId from Firebase');
    } catch (e) {
      AppLogger.error('Error deleting link from Firebase: $e');
    }
  }

  // ============ DELETE ALL ============

  /// حذف جميع بيانات المستخدم من Firebase
  Future<void> deleteAllUserDataFromFirebase() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        AppLogger.warning('No user logged in, skipping delete');
        return;
      }

      AppLogger.info('🗑️ Deleting all user data from Firebase...');

      // حذف جميع الروابط
      final linksSnapshot = await firestore
          .collection('links')
          .where('userId', isEqualTo: userId)
          .get();

      AppLogger.info('Deleting ${linksSnapshot.docs.length} links...');
      for (final doc in linksSnapshot.docs) {
        await doc.reference.delete();
      }

      // حذف جميع المجموعات
      final collectionsSnapshot = await firestore
          .collection('collections')
          .where('userId', isEqualTo: userId)
          .get();

      AppLogger.info('Deleting ${collectionsSnapshot.docs.length} collections...');
      for (final doc in collectionsSnapshot.docs) {
        await doc.reference.delete();
      }

      AppLogger.info('✅ All user data deleted from Firebase');
    } catch (e) {
      AppLogger.error('❌ Error deleting user data from Firebase: $e');
      rethrow;
    }
  }

  // ============ FULL SYNC ============

  /// مزامنة كاملة: تنزيل من Firebase
  Future<void> fullSyncFromFirebase() async {
    try {
      AppLogger.info('🔄 Starting full sync FROM Firebase...');

      await syncCollectionsFromFirebase();

      final localCollections = await collectionLocalDataSource.getAllCollections();
      for (final collection in localCollections) {
        await syncLinksFromFirebase(collection.id);
      }

      AppLogger.info('✅ Full sync FROM Firebase completed');
    } catch (e) {
      AppLogger.error('❌ Error during full sync from Firebase: $e');
      rethrow;
    }
  }

  /// مزامنة كاملة: رفع إلى Firebase (مع استبدال)
  Future<void> fullSyncToFirebase({bool replaceAll = false}) async {
    try {
      AppLogger.info('🔄 Starting full sync TO Firebase...');

      // إذا كان replaceAll = true، احذف كل شيء أولاً
      if (replaceAll) {
        AppLogger.info('🗑️ Replacing mode: Deleting old data first...');
        await deleteAllUserDataFromFirebase();
      }

      await syncCollectionsToFirebase();

      final localCollections = await collectionLocalDataSource.getAllCollections();
      for (final collection in localCollections) {
        await syncLinksToFirebase(collection.id);
      }

      AppLogger.info('✅ Full sync TO Firebase completed');
    } catch (e) {
      AppLogger.error('❌ Error during full sync to Firebase: $e');
      rethrow;
    }
  }

  // ============ HELPERS ============

  /// إعادة المحاولة عند الفشل
  Future<T> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int retries = 0;
    while (retries < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        retries++;
        if (retries >= maxRetries) {
          rethrow;
        }
        AppLogger.warning('Retry attempt $retries/$maxRetries after error: $e');
        await Future.delayed(delay * retries);
      }
    }
    throw Exception('Operation failed after $maxRetries retries');
  }
}
