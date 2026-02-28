import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/collection_repository.dart';

class UpdateCollectionLockUseCase {
  final CollectionRepository repository;

  UpdateCollectionLockUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String collectionId,
    required bool isLocked,
    String? pin,
  }) async {
    return await repository.updateCollectionLock(
      collectionId: collectionId,
      isLocked: isLocked,
      pin: pin,
    );
  }
}
