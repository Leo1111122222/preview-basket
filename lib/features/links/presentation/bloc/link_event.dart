part of 'link_bloc.dart';

abstract class LinkEvent extends Equatable {
  const LinkEvent();

  @override
  List<Object> get props => [];
}

class LoadLinksEvent extends LinkEvent {
  final String collectionId;

  const LoadLinksEvent(this.collectionId);

  @override
  List<Object> get props => [collectionId];
}

class AddLinksFromTextEvent extends LinkEvent {
  final String text;
  final String collectionId;

  const AddLinksFromTextEvent({
    required this.text,
    required this.collectionId,
  });

  @override
  List<Object> get props => [text, collectionId];
}

class DeleteLinkEvent extends LinkEvent {
  final String linkId;
  final String collectionId;

  const DeleteLinkEvent({
    required this.linkId,
    required this.collectionId,
  });

  @override
  List<Object> get props => [linkId, collectionId];
}
