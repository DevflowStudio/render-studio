// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// 
// import '../rehmat.dart';
// 
// FirebaseAuth fauth = FirebaseAuth.instance;
// 
// class Auth {
// 
//   static bool get isLoggedIn => fauth.currentUser != null;
// 
//   static User get user => fauth.currentUser!;
// 
//   static Future<void> signInWithGoogle(BuildContext context) async {
//     bool success = false;
//     await Spinner.fullscreen(
//       context,
//       task: () async {
//         try {
//           // Trigger the authentication flow
//           final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
// 
//           if (googleUser == null) return;
// 
//           // Obtain the auth details from the request
//           final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
// 
//           // Create a new credential
//           final credential = GoogleAuthProvider.credential(
//             accessToken: googleAuth.accessToken,
//             idToken: googleAuth.idToken,
//           );
// 
//           // Once signed in, return the UserCredential
//           // ignore: unused_local_variable
//           UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//           success = true;
//         } catch (e) {
//           Alerts.snackbar(context, text: 'Failed to authenticate with Google');
//         }
//       }
//     );
//     if (success) onSignIn(context);
//   }
// 
//   static Future<void> signInWithApple(BuildContext context) async {
//     // To prevent replay attacks with the credential returned from Apple, we
//     // include a nonce in the credential request. When signing in with
//     // Firebase, the nonce in the id token returned by Apple, is expected to
//     // match the sha256 hash of `rawNonce`.
//     final rawNonce = Constants.generateNonce();
//     final nonce = Constants.sha256ofString(rawNonce);
//     bool success = false;
//     await Spinner.fullscreen(
//       context,
//       task: () async {
//         try {
//           // Request credential for the currently signed in Apple account.
//           final appleCredential = await SignInWithApple.getAppleIDCredential(
//             scopes: [
//               AppleIDAuthorizationScopes.email,
//               AppleIDAuthorizationScopes.fullName,
//             ],
//             nonce: nonce,
//           );
// 
//           // Create an `OAuthCredential` from the credential returned by Apple.
//           final oauthCredential = OAuthProvider("apple.com").credential(
//             idToken: appleCredential.identityToken,
//             rawNonce: rawNonce,
//           );
// 
//           // ignore: unused_local_variable
//           UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//           success = true;
//         } catch (e) {
//           return;
//         }
//       }
//     );
//     if (success) onSignIn(context);
//   }
// 
//   static Future<void> onSignIn(BuildContext context) async {
//     AppRouter.removeAllAndPush(context, page: Home());
//   }
// 
// }