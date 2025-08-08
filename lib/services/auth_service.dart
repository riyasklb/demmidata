import 'package:firebase_auth/firebase_auth.dart';
import '../authentication/bloc/auth_bloc.dart';
import '../authentication/bloc/auth_event.dart';
import '../authentication/bloc/auth_state.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static final AuthBloc authBloc = AuthBloc();
  
  static Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? UserEntity(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      ) : null;
    });
  }
  
  static UserEntity? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    ) : null;
  }
  
  static Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

class UserEntity {
  final String id;
  final String email;
  final String displayName;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
  });
}
