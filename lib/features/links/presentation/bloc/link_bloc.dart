import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/link_preview.dart';
import '../../domain/usecases/add_links_from_text_usecase.dart';
import '../../domain/usecases/delete_link_usecase.dart';
import '../../domain/usecases/get_links_by_collection_usecase.dart';

part 'link_event.dart';
part 'link_state.dart';

class LinkBloc extends Bloc<LinkEvent, LinkState> {
  final GetLinksByCollectionUseCase getLinksByCollection;
  final AddLinksFromTextUseCase addLinksFromText;
  final DeleteLinkUseCase deleteLink;

  LinkBloc({
    required this.getLinksByCollection,
    required this.addLinksFromText,
    required this.deleteLink,
  }) : super(LinkInitial()) {
    on<LoadLinksEvent>(_onLoadLinks);
    on<AddLinksFromTextEvent>(_onAddLinksFromText);
    on<DeleteLinkEvent>(_onDeleteLink);
  }

  Future<void> _onLoadLinks(
    LoadLinksEvent event,
    Emitter<LinkState> emit,
  ) async {
    emit(LinkLoading());

    final result = await getLinksByCollection(event.collectionId);

    result.fold(
      (failure) => emit(LinkError(failure.message)),
      (links) => emit(LinkLoaded(links)),
    );
  }

  Future<void> _onAddLinksFromText(
    AddLinksFromTextEvent event,
    Emitter<LinkState> emit,
  ) async {
    emit(LinkAdding());

    final result = await addLinksFromText(
      AddLinksParams(
        text: event.text,
        collectionId: event.collectionId,
      ),
    );

    await result.fold(
      (failure) async => emit(LinkError(failure.message)),
      (links) async {
        emit(LinksAdded(links));
        // Reload links after adding
        final reloadResult = await getLinksByCollection(event.collectionId);
        reloadResult.fold(
          (failure) => emit(LinkError(failure.message)),
          (allLinks) => emit(LinkLoaded(allLinks)),
        );
      },
    );
  }

  Future<void> _onDeleteLink(
    DeleteLinkEvent event,
    Emitter<LinkState> emit,
  ) async {
    final result = await deleteLink(
      DeleteLinkParams(
        linkId: event.linkId,
        collectionId: event.collectionId,
      ),
    );

    await result.fold(
      (failure) async => emit(LinkError(failure.message)),
      (_) async {
        // Reload links after deletion
        final reloadResult = await getLinksByCollection(event.collectionId);
        reloadResult.fold(
          (failure) => emit(LinkError(failure.message)),
          (links) => emit(LinkLoaded(links)),
        );
      },
    );
  }
}
