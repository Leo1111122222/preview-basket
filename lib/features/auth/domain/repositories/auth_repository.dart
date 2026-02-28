import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, void>> resetPassword(String email);

  Stream<User?> get authStateChanges;
}
