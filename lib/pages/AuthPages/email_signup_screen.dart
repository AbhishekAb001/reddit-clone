import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/pages/AuthPages/email_login_screen.dart';
import 'package:reddit/pages/AuthPages/phone_login_screen.dart';
import 'package:reddit/pages/home_screen.dart';
import 'package:reddit/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailSignUpScreen extends StatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  State<EmailSignUpScreen> createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password should be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isEmailLoading = true);
    try {
      await _authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      Get.to(() => EmailLoginScreen(), transition: Transition.rightToLeft);
    } catch (e) {
      String errorMessage = 'An error occurred';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'This email is already registered';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Please enter a valid email address';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password should be at least 6 characters';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Please check your internet connection';
      }
      log(e.toString());

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isEmailLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: screenWidth * 0.06,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/redit.png",
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "Hi new friend,",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "Welcome to Reddit",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "Create an account to get started now",
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                _buildSocialButton(
                  icon: Icons.phone_android_outlined,
                  text: "Continue with phone number",
                  onTap: () {
                    Get.to(
                      () => PhoneLoginScreen(),
                      transition: Transition.rightToLeft,
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildSocialButton(
                  icon: FontAwesomeIcons.google,
                  text:
                      _isGoogleLoading
                          ? "Signing in..."
                          : "Continue with Google",
                  onTap:
                      _isGoogleLoading
                          ? () {}
                          : () async {
                            setState(() => _isGoogleLoading = true);
                            try {
                              final userCredential =
                                  await _authService.signInWithGoogle();
                              if (userCredential != null) {
                                log(
                                  'Google Sign-In successful: ${userCredential.user?.email}',
                                );
                                if (mounted) {
                                  Get.to(
                                    () => HomeScreen(),
                                    transition: Transition.rightToLeft,
                                  );
                                }
                              }
                            } catch (e) {
                              log('Google Sign-In error: $e');
                              String errorMessage =
                                  'Failed to sign in with Google';

                              if (e.toString().contains(
                                'network-request-failed',
                              )) {
                                errorMessage =
                                    'Please check your internet connection';
                              } else if (e.toString().contains(
                                'sign_in_canceled',
                              )) {
                                errorMessage = 'Sign in was canceled';
                              } else if (e.toString().contains(
                                    'List<Object?>',
                                  ) ||
                                  e.toString().contains('PigeonUserDetails')) {
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                if (currentUser != null) {
                                  log(
                                    'User authenticated despite error, proceeding',
                                  );
                                  if (mounted) {
                                    Get.offAllNamed('/home');
                                  }
                                  return;
                                }
                              }

                              if (mounted) {
                                Get.snackbar(
                                  'Error',
                                  errorMessage,
                                  snackPosition: SnackPosition.BOTTOM,
                                  colorText: Colors.white,
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isGoogleLoading = false);
                              }
                            }
                          },
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[800])),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ),
                      child: Text(
                        'OR',
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[800])),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                TextField(
                  controller: _emailController,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.04,
                    ),
                    filled: true,
                    fillColor: Color(0xFF1A1A1B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.018,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                TextField(
                  controller: _passwordController,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                  ),
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.04,
                    ),
                    filled: true,
                    fillColor: Color(0xFF1A1A1B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.018,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                        size: screenWidth * 0.05,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.18),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.03,
                    ),
                    children: [
                      TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'User Agreement',
                        style: TextStyle(
                          color: Color(0xFFFF4500),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' and acknowledge that you understand the ',
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Color(0xFFFF4500),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isEmailLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isEmailLoading
                              ? Color(0xFF343536)
                              : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                    child: Text(
                      _isEmailLoading ? 'Signing in...' : 'Sign up',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
