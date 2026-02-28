part of 'link_bloc.dart';

abstract class LinkState extends Equatable {
  const LinkState();

  @override
  List<Object> get props => [];
}

class LinkInitial extends LinkState {}

class LinkLoading extends LinkState {}

class LinkAdding extends LinkState {}

class LinkLoaded extends LinkState {
  final List<LinkPreview> links;

  const LinkLoaded(this.links);

  @override
  List<Object> get props => [links];
}

class LinksAdded extends LinkState {
  final List<LinkPreview> links;

  const LinksAdded(this.links);

  @override
  List<Object> get props => [links];
}

class LinkError extends LinkState {
  final String message;

  const LinkError(this.message);

  @override
  List<Object> get props => [message];
}
