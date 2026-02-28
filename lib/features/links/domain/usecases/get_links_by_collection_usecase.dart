import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/link_preview.dart';
import '../repositories/link_repository.dart';

class GetLinksByCollectionUseCase {
  final LinkRepository repository;

  GetLinksByCollectionUseCase(this.repository);

  Future<Either<Failure, List<LinkPreview>>> call(String collectionId) async {
    return await repository.getLinksByCollection(collectionId);
  }
}
