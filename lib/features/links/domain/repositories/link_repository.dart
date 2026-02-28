import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/link_preview.dart';

abstract class LinkRepository {
  Future<Either<Failure, List<LinkPreview>>> getLinksByCollection(String collectionId);
  Future<Either<Failure, LinkPreview>> addLink(String url, String collectionId);
  Future<Either<Failure, List<LinkPreview>>> addMultipleLinks(
    List<String> urls,
    String collectionId,
  );
  Future<Either<Failure, void>> deleteLink(String id, String collectionId);
  Future<Either<Failure, LinkPreview>> fetchLinkMetadata(String url);
}
