import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/link_repository.dart';

class DeleteLinkUseCase {
  final LinkRepository repository;

  DeleteLinkUseCase(this.repository);

  Future<Either<Failure, void>> call(DeleteLinkParams params) async {
    return await repository.deleteLink(params.linkId, params.collectionId);
  }
}

class DeleteLinkParams extends Equatable {
  final String linkId;
  final String collectionId;

  const DeleteLinkParams({
    required this.linkId,
    required this.collectionId,
  });

  @override
  List<Object> get props => [linkId, collectionId];
}
