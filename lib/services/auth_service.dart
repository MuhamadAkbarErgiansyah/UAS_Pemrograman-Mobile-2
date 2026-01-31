import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lazy initialization of GoogleSignIn to avoid web crash
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
    );
    return _googleSignIn!;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    bool isAdmin = false,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);
    await _createUserDocument(credential.user!, displayName, isAdmin: isAdmin);

    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For web, use signInWithPopup
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        // Always show account picker
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
        });

        final userCredential = await _auth.signInWithPopup(googleProvider);

        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _createUserDocument(
            userCredential.user!,
            userCredential.user!.displayName,
          );
        }

        return userCredential;
      }

      // For mobile platforms
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocument(
          userCredential.user!,
          userCredential.user!.displayName,
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createUserDocument(User user, String? displayName,
      {bool isAdmin = false}) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: displayName ?? user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    final data = userModel.toFirestore();
    data['isAdmin'] = isAdmin;
    data['role'] = isAdmin ? 'admin' : 'user';

    await _firestore.collection('users').doc(user.uid).set(data);
  }

  /// Check if user is admin
  Future<bool> checkIfAdmin(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('isAdmin', isEqualTo: true)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  /// Get all admins
  Future<List<UserModel>> getAllAdmins() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('isAdmin', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  /// Get all users (non-admin)
  Future<List<UserModel>> getAllUsers() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('isAdmin', isNotEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  Future<UserModel?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? phone,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{'updatedAt': Timestamp.now()};

    if (displayName != null) {
      updates['displayName'] = displayName;
      await user.updateDisplayName(displayName);
    }
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
      await user.updatePhotoURL(photoUrl);
    }

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUserData(UserModel userModel) async {
    // Use set with merge to create document if it doesn't exist
    await _firestore
        .collection('users')
        .doc(userModel.id)
        .set(userModel.toFirestore(), SetOptions(merge: true));

    final user = currentUser;
    if (user != null) {
      if (userModel.displayName != null) {
        await user.updateDisplayName(userModel.displayName);
      }
      if (userModel.photoUrl != null) {
        await user.updatePhotoURL(userModel.photoUrl);
      }
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await googleSignIn.signOut();
      } catch (e) {
        // Ignore Google Sign-Out errors
      }
    }
    await _auth.signOut();
  }
}
