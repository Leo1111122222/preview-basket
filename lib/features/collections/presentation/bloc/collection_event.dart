part of 'collection_bloc.dart';

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadCollectionsEvent extends CollectionEvent {}

class CreateCollectionEvent extends CollectionEvent {
  final String name;
  final String? description;

  const CreateCollectionEvent({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

class DeleteCollectionEvent extends CollectionEvent {
  final String collectionId;

  const DeleteCollectionEvent(this.collectionId);

  @override
  List<Object> get props => [collectionId];
}
