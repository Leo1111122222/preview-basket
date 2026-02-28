import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/collection.dart';
import '../../domain/usecases/create_collection_usecase.dart';
import '../../domain/usecases/delete_collection_usecase.dart';
import '../../domain/usecases/get_all_collections_usecase.dart';

part 'collection_event.dart';
part 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final GetAllCollectionsUseCase getAllCollections;
  final CreateCollectionUseCase createCollection;
  final DeleteCollectionUseCase deleteCollection;

  CollectionBloc({
    required this.getAllCollections,
    required this.createCollection,
    required this.deleteCollection,
  }) : super(CollectionInitial()) {
    on<LoadCollectionsEvent>(_onLoadCollections);
    on<CreateCollectionEvent>(_onCreateCollection);
    on<DeleteCollectionEvent>(_onDeleteCollection);
  }

  Future<void> _onLoadCollections(
    LoadCollectionsEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(CollectionLoading());

    final result = await getAllCollections();

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (collections) => emit(CollectionLoaded(collections)),
    );
  }

  Future<void> _onCreateCollection(
    CreateCollectionEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(CollectionCreating());

    final result = await createCollection(
      CreateCollectionParams(
        name: event.name,
        description: event.description,
      ),
    );

    await result.fold(
      (failure) async => emit(CollectionError(failure.message)),
      (collection) async {
        emit(CollectionCreated(collection));
        // Reload collections after creation
        final reloadResult = await getAllCollections();
        reloadResult.fold(
          (failure) => emit(CollectionError(failure.message)),
          (collections) => emit(CollectionLoaded(collections)),
        );
      },
    );
  }

  Future<void> _onDeleteCollection(
    DeleteCollectionEvent event,
    Emitter<CollectionState> emit,
  ) async {
    final result = await deleteCollection(event.collectionId);

    await result.fold(
      (failure) async => emit(CollectionError(failure.message)),
      (_) async {
        // Reload collections after deletion
        final reloadResult = await getAllCollections();
        reloadResult.fold(
          (failure) => emit(CollectionError(failure.message)),
          (collections) => emit(CollectionLoaded(collections)),
        );
      },
    );
  }
}
