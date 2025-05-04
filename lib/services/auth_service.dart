import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:reddit/services/shared_preferences_service.dart';
import 'package:reddit/services/firestore_service.dart';
import 'package:reddit/pages/OnetTimePages/create_username_screen.dart';
import 'package:reddit/widgets/loading_screen.dart';
import 'dart:developer';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferencesService _prefs = SharedPreferencesService();
  final FirestoreService _firestore = FirestoreService();

  AuthService() {
    _prefs.init();
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log('Error during email/password sign in: ${e.message}');
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user);
      return userCredential;
    } catch (e) {
      log('Error during Google sign in: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to sign in with Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Phone Authentication
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(FirebaseAuthException) onVerificationFailed,
    Function(PhoneAuthCredential) onVerificationCompleted,
    Function(String) onCodeAutoRetrievalTimeout,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: (FirebaseAuthException e) {
        log('Error during phone verification: ${e.message}');
        onVerificationFailed(e);
      },  
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential?> signInWithPhoneNumber(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log('Error during phone number sign in: ${e.message}');
      Get.snackbar(
        'Error',
        e.message ?? 'Failed to verify phone number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log('Error during user creation: ${e.message}');
      Get.snackbar(
        'Error',
        e.message ?? 'An error occurred during sign up',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Save user data to shared preferences and Firestore
  Future<void> _saveUserData(User? user) async {
    if (user != null) {
      // Save to SharedPreferences
      await _prefs.setLoggedIn(true);
      await _prefs.setUserId(user.uid);
      if (user.phoneNumber != null) {
        await _prefs.setUserPhone(user.phoneNumber!);
      }

      // Save to Firestore
      await _firestore.saveUserData(
        uid: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
        displayName: user.displayName,
        photoURL: user.photoURL,
      );

      // Check if user has completed onboarding (username creation)
      final userData = await _firestore.getUserData(user.uid);
      final hasCompletedOnboarding =
          userData?['hasCompletedOnboarding'] ?? false;

      if (!hasCompletedOnboarding) {
        Get.to(
          () => CreateUsernameScreen(uid: user.uid),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        Get.offAll(
          () => const LoadingScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
    }
  }
}












// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:kfc_app/view/auth/otp_screen.dart';
// import 'package:kfc_app/view/home/home_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';


// class AuthController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late String _verificationId;

//   Future<void> sendOTP(String phoneNumber) async {
//     await _auth.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await _auth.signInWithCredential(credential);
//         await _setLoginStatus(true);
//         Get.offAll(() => HomePage());
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         Get.snackbar("Error", e.message ?? "Verification Failed");
//       },
//       codeSent: (String verId, int? resendToken) {
//         _verificationId = verId;
//         Get.to(() => OTPScreen());
//       },
//       codeAutoRetrievalTimeout: (String verId) {
//         _verificationId = verId;
//       },
//     );
//   }

//   Future<void> verifyOTP(String otp) async {
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: otp,
//       );
//       await _auth.signInWithCredential(credential);
//       await _setLoginStatus(true);
//       Get.offAll(() => HomePage());
//     } catch (e) {
//       Get.snackbar("Error", "Invalid OTP");
//     }
//   }

//   Future<void> logout() async {
//     await _auth.signOut();
//     await _setLoginStatus(false);
//     Get.offAllNamed('/login');
//   }

//   Future<void> _setLoginStatus(bool status) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', status);
//   }

//   Future<bool> isLoggedIn() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('isLoggedIn') ?? false;
//   }
// }