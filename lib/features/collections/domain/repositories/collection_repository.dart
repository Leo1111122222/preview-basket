import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/collection.dart';

abstract class CollectionRepository {
  Future<Either<Failure, List<Collection>>> getAllCollections();
  Future<Either<Failure, Collection>> getCollectionById(String id);
  Future<Either<Failure, Collection>> createCollection(String name, String? description);
  Future<Either<Failure, Collection>> updateCollection(Collection collection);
  Future<Either<Failure, void>> deleteCollection(String id);
  Future<Either<Failure, void>> updateCollectionLock({
    required String collectionId,
    required bool isLocked,
    String? pin,
  });
}
