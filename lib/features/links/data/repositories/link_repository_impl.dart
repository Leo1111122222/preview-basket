import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../collections/data/datasources/collection_local_datasource.dart';
import '../../domain/entities/link_preview.dart';
import '../../domain/repositories/link_repository.dart';
import '../datasources/link_local_datasource.dart';
import '../datasources/link_metadata_datasource.dart';
import '../models/link_preview_model.dart';

class LinkRepositoryImpl implements LinkRepository {
  final LinkLocalDataSource localDataSource;
  final LinkMetadataDataSource metadataDataSource;
  final CollectionLocalDataSource collectionDataSource;
  final Uuid uuid = const Uuid();

  LinkRepositoryImpl({
    required this.localDataSource,
    required this.metadataDataSource,
    required this.collectionDataSource,
  });

  @override
  Future<Either<Failure, List<LinkPreview>>> getLinksByCollection(
    String collectionId,
  ) async {
    try {
      final links = await localDataSource.getLinksByCollection(collectionId);
      return Right(links.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LinkPreview>> addLink(
    String url,
    String collectionId,
  ) async {
    try {
      // Check if link already exists
      final existing = await localDataSource.getLinkByUrl(url, collectionId);
      if (existing != null) {
        return Left(CacheFailure('Link already exists in this collection'));
      }

      // Fetch metadata
      final metadata = await metadataDataSource.fetchMetadata(url);

      // Create link model
      final link = LinkPreviewModel(
        id: uuid.v4(),
        url: url,
        title: metadata.title,
        description: metadata.description,
        imageUrl: metadata.imageUrl,
        collectionId: collectionId,
        createdAt: DateTime.now(),
        isCached: true,
      );

      // Save link
      final saved = await localDataSource.addLink(link);

      // Increment collection link count
      await collectionDataSource.incrementLinkCount(collectionId);

      return Right(saved.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LinkPreview>>> addMultipleLinks(
    List<String> urls,
    String collectionId,
  ) async {
    try {
      final List<LinkPreview> addedLinks = [];
      
      for (final url in urls) {
        final result = await addLink(url, collectionId);
        result.fold(
          (failure) {
            // Skip if link already exists or failed
          },
          (link) => addedLinks.add(link),
        );
      }

      return Right(addedLinks);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLink(String id, String collectionId) async {
    try {
      await localDataSource.deleteLink(id);
      await collectionDataSource.decrementLinkCount(collectionId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LinkPreview>> fetchLinkMetadata(String url) async {
    try {
      final metadata = await metadataDataSource.fetchMetadata(url);
      
      final link = LinkPreview(
        id: uuid.v4(),
        url: url,
        title: metadata.title,
        description: metadata.description,
        imageUrl: metadata.imageUrl,
        collectionId: '',
        createdAt: DateTime.now(),
        isCached: false,
      );

      return Right(link);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
