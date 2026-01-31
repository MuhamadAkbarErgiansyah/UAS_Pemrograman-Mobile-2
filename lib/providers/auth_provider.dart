import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../data/models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  UserModel? _userModel;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  User? get currentUser => _user; // Alias for user
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _user = user;
        _userModel = await _authService.getUserData(user.uid);
        _status = AuthStatus.authenticated;

        // Save session
        await SessionService.saveSession(
          userId: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        );
      } else {
        _user = null;
        _userModel = null;
        _status = AuthStatus.unauthenticated;

        // Clear session
        await SessionService.clearSession();
      }
      notifyListeners();
    });
  }

  Future<bool> signInWithEmail(String email, String password,
      {bool rememberMe = false}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithEmail(email, password);

      // Save session with remember me preference
      await SessionService.saveSession(
        userId: result.user!.uid,
        email: result.user!.email ?? '',
        displayName: result.user!.displayName,
        rememberMe: rememberMe,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle({bool rememberMe = true}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithGoogle();
      if (result != null) {
        // Save session after successful Google sign-in (always remember for Google)
        await SessionService.saveSession(
          userId: result.user!.uid,
          email: result.user!.email ?? '',
          displayName: result.user!.displayName,
          rememberMe: rememberMe,
        );
        return true;
      }

      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Google sign-in cancelled';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to sign in with Google: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to send reset email';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await SessionService.clearSession();
    _status = AuthStatus.unauthenticated;
    _user = null;
    _userModel = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status =
          _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'An error occurred. Please try again';
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
  }) async {
    if (_user == null) return false;

    try {
      _status = AuthStatus.loading;
      notifyListeners();

      // If userModel is null, create a new one
      final currentUserModel = _userModel ??
          UserModel(
            id: _user!.uid,
            email: _user!.email ?? '',
            displayName: _user!.displayName,
            photoUrl: _user!.photoURL,
            createdAt: DateTime.now(),
          );

      final updatedUser = currentUserModel.copyWith(
        displayName: displayName ?? currentUserModel.displayName,
        photoUrl: photoUrl ?? currentUserModel.photoUrl,
        phone: phone ?? currentUserModel.phone,
        updatedAt: DateTime.now(),
      );

      await _authService.updateUserData(updatedUser);

      // Reload user data from Firestore to ensure consistency
      _userModel = await _authService.getUserData(_user!.uid);

      // Also update Firebase Auth display name
      if (displayName != null && displayName.isNotEmpty) {
        await _user!.updateDisplayName(displayName);
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
