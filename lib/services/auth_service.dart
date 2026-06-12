import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of User Auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      rethrow;
    }
  }

  // Google Sign-In helper for native platforms. Returns a credential if successful.
  Future<AuthCredential?> getGoogleCredential() async {
    try {
      if (kIsWeb) {
        throw UnsupportedError(
          'getGoogleCredential is not supported on Web. Use linkWithGoogle.',
        );
      }

      // For native platforms (Android, iOS, macOS)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      return GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } catch (e) {
      debugPrint('Error getting Google Credential: $e');
      rethrow;
    }
  }

  // Links Google account to the currently active user (handles Web/Native differences)
  Future<UserCredential> linkWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user signed in to link the credential to.',
      );
    }
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      return await user.linkWithPopup(googleProvider);
    } else {
      final credential = await getGoogleCredential();
      if (credential == null) {
        throw FirebaseAuthException(
          code: 'sign-in-canceled',
          message: 'Google Sign-In was canceled by the user.',
        );
      }
      return await user.linkWithCredential(credential);
    }
  }

  // Link credential to currently active anonymous user
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user signed in to link the credential to.',
      );
    }
    return await user.linkWithCredential(credential);
  }

  // Sign in directly with Google credential (if account already in use)
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  // Sign out and immediately re-login anonymously so user isn't left unauthenticated
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      }
      await _auth.signOut();
      await signInAnonymously();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}
