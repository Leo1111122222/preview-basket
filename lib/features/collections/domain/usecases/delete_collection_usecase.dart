import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/collection_repository.dart';

class DeleteCollectionUseCase {
  final CollectionRepository repository;

  DeleteCollectionUseCase(this.repository);

  Future<Either<Failure, void>> call(String collectionId) async {
    return await repository.deleteCollection(collectionId);
  }
}
