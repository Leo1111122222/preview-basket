import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException('فشل تسجيل الدخول');
      }

      // Update last login time in Firestore
      await _updateLastLogin(credential.user!.uid);

      // Get user data from Firestore with retry
      final userDoc = await _getFirestoreDocWithRetry(
        firestore.collection('users').doc(credential.user!.uid),
      );

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      } else {
        // Create user document if it doesn't exist
        final userModel = UserModel.fromFirebaseUser(credential.user!);
        await _setFirestoreDocWithRetry(
          firestore.collection('users').doc(credential.user!.uid),
          userModel.toJson(),
        );
        return userModel;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('حدث خطأ أثناء تسجيل الدخول');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException('فشل إنشاء الحساب');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      // Create user document in Firestore with retry
      final userModel = UserModel.fromFirebaseUser(
        firebaseAuth.currentUser!,
      );

      await _setFirestoreDocWithRetry(
        firestore.collection('users').doc(credential.user!.uid),
        userModel.toJson(),
      );

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('حدث خطأ أثناء إنشاء الحساب');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('حدث خطأ أثناء تسجيل الخروج');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }

      return null;
    } catch (e) {
      throw ServerException('حدث خطأ أثناء جلب بيانات المستخدم');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromJson(userDoc.data()!);
        }

        return UserModel.fromFirebaseUser(firebaseUser);
      } catch (e) {
        return null;
      }
    });
  }

  Future<void> _updateLastLogin(String userId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'lastLoginAt': Timestamp.now(),
      });
    } catch (e) {
      // Ignore error if document doesn't exist
    }
  }

  // Helper method to get Firestore document with retry
  Future<DocumentSnapshot<Map<String, dynamic>>> _getFirestoreDocWithRetry(
    DocumentReference<Map<String, dynamic>> docRef, {
    int maxRetries = 3,
  }) async {
    int retries = 0;
    while (retries < maxRetries) {
      try {
        return await docRef.get();
      } catch (e) {
        retries++;
        if (retries >= maxRetries) rethrow;
        await Future.delayed(Duration(seconds: retries));
      }
    }
    throw ServerException('فشل الاتصال بالخادم');
  }

  // Helper method to set Firestore document with retry
  Future<void> _setFirestoreDocWithRetry(
    DocumentReference<Map<String, dynamic>> docRef,
    Map<String, dynamic> data, {
    int maxRetries = 3,
  }) async {
    int retries = 0;
    while (retries < maxRetries) {
      try {
        await docRef.set(data);
        return;
      } catch (e) {
        retries++;
        if (retries >= maxRetries) rethrow;
        await Future.delayed(Duration(seconds: retries));
      }
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'operation-not-allowed':
        return 'العملية غير مسموحة';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
