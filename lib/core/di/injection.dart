import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sync/sync_service.dart';
import '../sync/sync_service_v2.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/collections/data/datasources/collection_local_datasource.dart';
import '../../features/collections/data/repositories/collection_repository_impl.dart';
import '../../features/collections/domain/repositories/collection_repository.dart';
import '../../features/collections/domain/usecases/create_collection_usecase.dart';
import '../../features/collections/domain/usecases/delete_collection_usecase.dart';
import '../../features/collections/domain/usecases/get_all_collections_usecase.dart';
import '../../features/collections/presentation/bloc/collection_bloc.dart';
import '../../features/links/data/datasources/link_local_datasource.dart';
import '../../features/links/data/datasources/link_metadata_datasource.dart';
import '../../features/links/data/repositories/link_repository_impl.dart';
import '../../features/links/domain/repositories/link_repository.dart';
import '../../features/links/domain/usecases/add_links_from_text_usecase.dart';
import '../../features/links/domain/usecases/delete_link_usecase.dart';
import '../../features/links/domain/usecases/get_links_by_collection_usecase.dart';
import '../../features/links/presentation/bloc/link_bloc.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_theme_usecase.dart';
import '../../features/settings/domain/usecases/save_theme_usecase.dart';
import '../../features/settings/presentation/bloc/theme_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Firebase
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Data Sources - Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      firestore: getIt(),
    ),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );

  // Data Sources - Collections & Links
  getIt.registerLazySingleton<CollectionLocalDataSource>(
    () => CollectionLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<LinkLocalDataSource>(
    () => LinkLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<LinkMetadataDataSource>(
    () => LinkMetadataDataSourceImpl(),
  );
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(getIt()),
  );

  // Repositories - Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Repositories - Collections & Links
  getIt.registerLazySingleton<CollectionRepository>(
    () => CollectionRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<LinkRepository>(
    () => LinkRepositoryImpl(
      localDataSource: getIt(),
      metadataDataSource: getIt(),
      collectionDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt()),
  );

  // Use Cases - Auth
  getIt.registerLazySingleton(() => SignInUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUpUseCase(getIt()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));

  // Use Cases - Collections
  getIt.registerLazySingleton(() => GetAllCollectionsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateCollectionUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCollectionUseCase(getIt()));

  // Use Cases - Links
  getIt.registerLazySingleton(() => GetLinksByCollectionUseCase(getIt()));
  getIt.registerLazySingleton(() => AddLinksFromTextUseCase(getIt(), getIt()));
  getIt.registerLazySingleton(() => DeleteLinkUseCase(getIt()));

  // Use Cases - Settings
  getIt.registerLazySingleton(() => GetThemeUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveThemeUseCase(getIt()));

  // Sync Service (Old - Nested structure)
  getIt.registerLazySingleton(
    () => SyncService(
      firestore: getIt(),
      firebaseAuth: getIt(),
      collectionLocalDataSource: getIt(),
      linkLocalDataSource: getIt(),
    ),
  );

  // Sync Service V2 (New - Direct tables)
  getIt.registerLazySingleton(
    () => SyncServiceV2(
      firestore: getIt(),
      firebaseAuth: getIt(),
      collectionLocalDataSource: getIt(),
      linkLocalDataSource: getIt(),
    ),
  );

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      signInUseCase: getIt(),
      signUpUseCase: getIt(),
      signOutUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
    ),
  );
  getIt.registerFactory(
    () => CollectionBloc(
      getAllCollections: getIt(),
      createCollection: getIt(),
      deleteCollection: getIt(),
    ),
  );
  getIt.registerFactory(
    () => LinkBloc(
      getLinksByCollection: getIt(),
      addLinksFromText: getIt(),
      deleteLink: getIt(),
    ),
  );
  getIt.registerFactory(
    () => ThemeBloc(
      getThemeUseCase: getIt(),
      saveThemeUseCase: getIt(),
    ),
  );
}
