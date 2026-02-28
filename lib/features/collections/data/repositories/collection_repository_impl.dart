import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_local_datasource.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionLocalDataSource localDataSource;

  CollectionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Collection>>> getAllCollections() async {
    try {
      final collections = await localDataSource.getAllCollections();
      return Right(collections.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Collection>> getCollectionById(String id) async {
    try {
      final collection = await localDataSource.getCollectionById(id);
      return Right(collection.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Collection>> createCollection(
    String name,
    String? description,
  ) async {
    try {
      final collection = await localDataSource.createCollection(name, description);
      return Right(collection.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Collection>> updateCollection(Collection collection) async {
    try {
      final model = await localDataSource.getCollectionById(collection.id);
      final updated = model.copyWith(
        name: collection.name,
        description: collection.description,
      );
      final result = await localDataSource.updateCollection(updated);
      return Right(result.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String id) async {
    try {
      await localDataSource.deleteCollection(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollectionLock({
    required String collectionId,
    required bool isLocked,
    String? pin,
  }) async {
    try {
      final model = await localDataSource.getCollectionById(collectionId);
      final updated = model.copyWith(
        isLocked: isLocked,
        lockPin: pin,
      );
      await localDataSource.updateCollection(updated);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
