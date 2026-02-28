import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/collection.dart';
import '../repositories/collection_repository.dart';

class CreateCollectionUseCase {
  final CollectionRepository repository;

  CreateCollectionUseCase(this.repository);

  Future<Either<Failure, Collection>> call(CreateCollectionParams params) async {
    if (params.name.trim().isEmpty) {
      return Left(ValidationFailure('Collection name cannot be empty'));
    }
    return await repository.createCollection(params.name, params.description);
  }
}

class CreateCollectionParams extends Equatable {
  final String name;
  final String? description;

  const CreateCollectionParams({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}
