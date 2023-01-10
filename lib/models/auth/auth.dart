import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../rehmat.dart';

class AuthState extends ChangeNotifier {

  final fauth.FirebaseAuth auth;
  AuthState._(this.auth) {
    auth.authStateChanges().listen((fauth.User? user) {
      notifyListeners();
    });
  }

  static AuthState of(BuildContext context, {
    bool listen = false
  }) => Provider.of<AuthState>(context, listen: listen);

  static AuthState get instance {
    AuthState authState = AuthState._(fauth.FirebaseAuth.instance);
    return authState;
  }

  bool get isLoggedIn => auth.currentUser != null;

  fauth.User? get user => auth.currentUser;

  Future<void> signOut() => auth.signOut();

  Future<void> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = fauth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await auth.signInWithCredential(credential);
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'signInWithGoogle failed');
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = Constants.generateNonce();
    final nonce = Constants.sha256ofString(rawNonce);
    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = fauth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      await auth.signInWithCredential(oauthCredential);
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'signInWithApple failed');
      rethrow;
    }
  }

}