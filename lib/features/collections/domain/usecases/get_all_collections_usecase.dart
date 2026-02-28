import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/collection.dart';
import '../repositories/collection_repository.dart';

class GetAllCollectionsUseCase {
  final CollectionRepository repository;

  GetAllCollectionsUseCase(this.repository);

  Future<Either<Failure, List<Collection>>> call() async {
    return await repository.getAllCollections();
  }
}
