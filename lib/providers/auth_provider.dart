// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';

class authProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  User? get firebaseUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // --- Apple (unchanged) ---
  Future<User?> signInWithApple() async {
    final cred = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );

    final oauth = OAuthProvider('apple.com').credential(
      idToken: cred.identityToken,
      accessToken: cred.authorizationCode,
    );

    final userCred = await _auth.signInWithCredential(oauth);

    final name = [
      cred.givenName ?? '',
      cred.familyName ?? '',
    ].where((s) => s.isNotEmpty).join(' ');
    if (name.isNotEmpty) {
      await userCred.user?.updateDisplayName(name);
    }

    notifyListeners();
    return userCred.user;
  }

  // --- Google (updated to new API) ---
  Future<User?> signInWithGoogle() async {
    try {
      // Web: use Firebase popup directly
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        final userCred = await _auth.signInWithPopup(provider);
        notifyListeners();
        return userCred.user;
      }

      // Mobile/Desktop: google_sign_in v7-style flow
      final signIn = GoogleSignIn.instance;

      // Initialize (set clientId/serverClientId if you use them)
      await signIn.initialize(
        // clientId: 'YOUR_IOS_OR_MACOS_CLIENT_ID.apps.googleusercontent.com',
        // serverClientId: 'YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com',
      );

      // Try silent auth first (returns null if no previous session)
      GoogleSignInAccount? account =
      await signIn.attemptLightweightAuthentication();

      // If not signed in, run interactive flow
      account ??= await signIn.authenticate();

      // If user canceled, account will be null
      if (account == null) return null;

      // Get Google ID token (v7 exposes idToken via account.authentication)
      final idToken = (await account.authentication).idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message: 'Google ID token was null.',
        );
      }

      // Build Firebase credential (accessToken is optional in v7)
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      print(credential);

      final userCred = await _auth.signInWithCredential(credential);
      notifyListeners();
      return userCred.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Best effort: also sign out from Google so chooser shows next time
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      await _auth.signOut();
    } finally {
      notifyListeners();
    }
  }
}
