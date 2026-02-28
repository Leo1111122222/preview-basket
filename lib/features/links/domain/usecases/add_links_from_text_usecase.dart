import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/link_metadata_datasource.dart';
import '../entities/link_preview.dart';
import '../repositories/link_repository.dart';

class AddLinksFromTextUseCase {
  final LinkRepository repository;
  final LinkMetadataDataSource metadataDataSource;

  AddLinksFromTextUseCase(this.repository, this.metadataDataSource);

  Future<Either<Failure, List<LinkPreview>>> call(AddLinksParams params) async {
    try {
      // Extract URLs from text
      final urls = metadataDataSource.extractUrls(params.text);

      if (urls.isEmpty) {
        return Left(ValidationFailure('No URLs found in the text'));
      }

      // Add all links
      return await repository.addMultipleLinks(urls, params.collectionId);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

class AddLinksParams extends Equatable {
  final String text;
  final String collectionId;

  const AddLinksParams({
    required this.text,
    required this.collectionId,
  });

  @override
  List<Object> get props => [text, collectionId];
}
