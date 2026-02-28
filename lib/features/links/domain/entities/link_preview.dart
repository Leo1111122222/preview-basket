import 'package:equatable/equatable.dart';

class LinkPreview extends Equatable {
  final String id;
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String collectionId;
  final DateTime createdAt;
  final bool isCached;

  const LinkPreview({
    required this.id,
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    required this.collectionId,
    required this.createdAt,
    this.isCached = false,
  });

  @override
  List<Object?> get props => [
        id,
        url,
        title,
        description,
        imageUrl,
        collectionId,
        createdAt,
        isCached,
      ];
}
