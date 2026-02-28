import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../features/collections/data/datasources/collection_local_datasource.dart';
import '../../features/collections/data/models/collection_model.dart';
import '../../features/links/data/datasources/link_local_datasource.dart';
import '../../features/links/data/models/link_preview_model.dart';
import '../utils/logger.dart';

class SyncService {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;
  final CollectionLocalDataSource collectionLocalDataSource;
  final LinkLocalDataSource linkLocalDataSource;

  SyncService({
    required this.firestore,
    required this.firebaseAuth,
    required this.collectionLocalDataSource,
    required this.linkLocalDataSource,
  });

  // Sync Collections from Local to Firebase
  Future<void> syncCollectionsToFirebase() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        AppLogger.warning('No user logged in, skipping sync');
        return;
      }

      final localCollections = await collectionLocalDataSource.getAllCollections();

      for (final collection in localCollections) {
        await _retryOperation(() async {
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('collections')
              .doc(collection.id)
              .set({
            'id': collection.id,
            'name': collection.name,
            'description': collection.description,
            'linkCount': collection.linkCount,
            'createdAt': Timestamp.fromDate(collection.createdAt),
            'updatedAt': Timestamp.fromDate(collection.updatedAt),
          }, SetOptions(merge: true));
        });

        AppLogger.info('Synced collection ${collection.id} to Firebase');
      }
    } catch (e) {
      AppLogger.error('Error syncing collections to Firebase: $e');
      rethrow;
    }
  }

  // Sync Collections from Firebase to Local
  Future<void> syncCollectionsFromFirebase() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return;

      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final collection = CollectionModel(
          id: data['id'] as String,
          name: data['name'] as String,
          description: data['description'] as String?,
          linkCount: data['linkCount'] as int,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );

        // Use updateCollection to save the complete model
        // This will create or update the collection
        await collectionLocalDataSource.updateCollection(collection);
        AppLogger.info('Synced collection ${collection.id} from Firebase');
      }
    } catch (e) {
      AppLogger.error('Error syncing collections from Firebase: $e');
    }
  }

  // Sync Links from Local to Firebase
  Future<void> syncLinksToFirebase(String collectionId) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return;

      final localLinks = await linkLocalDataSource.getLinksByCollection(collectionId);

      for (final link in localLinks) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('collections')
            .doc(collectionId)
            .collection('links')
            .doc(link.id)
            .set({
          'id': link.id,
          'url': link.url,
          'title': link.title,
          'description': link.description,
          'imageUrl': link.imageUrl,
          'collectionId': link.collectionId,
          'createdAt': Timestamp.fromDate(link.createdAt),
        }, SetOptions(merge: true));

        AppLogger.info('Synced link ${link.id} to Firebase');
      }
    } catch (e) {
      AppLogger.error('Error syncing links to Firebase: $e');
    }
  }

  // Sync Links from Firebase to Local
  Future<void> syncLinksFromFirebase(String collectionId) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return;

      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .doc(collectionId)
          .collection('links')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final link = LinkPreviewModel(
          id: data['id'] as String,
          url: data['url'] as String,
          title: data['title'] as String?,
          description: data['description'] as String?,
          imageUrl: data['imageUrl'] as String?,
          collectionId: data['collectionId'] as String,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );

        await linkLocalDataSource.addLink(link);
        AppLogger.info('Synced link ${link.id} from Firebase');
      }
    } catch (e) {
      AppLogger.error('Error syncing links from Firebase: $e');
    }
  }

  // Full Sync: Download all data from Firebase
  Future<void> fullSyncFromFirebase() async {
    try {
      await syncCollectionsFromFirebase();
      
      final localCollections = await collectionLocalDataSource.getAllCollections();
      for (final collection in localCollections) {
        await syncLinksFromFirebase(collection.id);
      }

      AppLogger.info('Full sync from Firebase completed');
    } catch (e) {
      AppLogger.error('Error during full sync from Firebase: $e');
    }
  }

  // Full Sync: Upload all data to Firebase
  Future<void> fullSyncToFirebase() async {
    try {
      await syncCollectionsToFirebase();
      
      final localCollections = await collectionLocalDataSource.getAllCollections();
      for (final collection in localCollections) {
        await syncLinksToFirebase(collection.id);
      }

      AppLogger.info('Full sync to Firebase completed');
    } catch (e) {
      AppLogger.error('Error during full sync to Firebase: $e');
    }
  }

  // Delete Collection from Firebase
  Future<void> deleteCollectionFromFirebase(String collectionId) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return;

      // Delete all links in the collection
      final linksSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .doc(collectionId)
          .collection('links')
          .get();

      for (final doc in linksSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the collection
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .doc(collectionId)
          .delete();

      AppLogger.info('Deleted collection $collectionId from Firebase');
    } catch (e) {
      AppLogger.error('Error deleting collection from Firebase: $e');
    }
  }

  // Delete Link from Firebase
  Future<void> deleteLinkFromFirebase(String collectionId, String linkId) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return;

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .doc(collectionId)
          .collection('links')
          .doc(linkId)
          .delete();

      AppLogger.info('Deleted link $linkId from Firebase');
    } catch (e) {
      AppLogger.error('Error deleting link from Firebase: $e');
    }
  }

  // Helper method to retry operations
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
