import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cache user ID locally
      await localDataSource.cacheUserId(userModel.id);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Cache user ID locally
      await localDataSource.cacheUserId(userModel.id);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel == null) return const Right(null);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    // TODO: Implement password reset
    return Left(ServerFailure('لم يتم تنفيذ هذه الميزة بعد'));
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      if (userModel == null) return null;
      return userModel.toEntity();
    });
  }
}
