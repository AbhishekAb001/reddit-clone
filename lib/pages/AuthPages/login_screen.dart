import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/AuthPages/email_login_screen.dart';
import 'package:reddit/pages/AuthPages/phone_login_screen.dart';
import 'package:reddit/pages/HomePages/Navigation_screen.dart';
import 'package:reddit/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _receiveEmails = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithGoogle();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.height * 0.04,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox.shrink(),
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/redit.png",
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        "Log in to Reddit",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.09,
                      ),
                      _buildLoginButton(
                        icon: Icons.phone_android_outlined,
                        text: "Continue with phone number",
                        onTap: () {
                          Get.to(
                            () => PhoneLoginScreen(),
                            transition: Transition.rightToLeft,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildLoginButton(
                        icon: FontAwesomeIcons.google,
                        text: _isLoading
                            ? "Signing in..."
                            : "Continue with Google",
                        onTap: _isLoading ? () {} : () => _handleGoogleSignIn(),
                      ),
                      const SizedBox(height: 12),
                      _buildLoginButton(
                        icon: Icons.person_outline,
                        text: "Use email or username",
                        onTap: () {
                          Get.to(
                            () => EmailLoginScreen(),
                            transition: Transition.rightToLeft,
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            children: [
                              const TextSpan(
                                text: "By continuing, you agree to our ",
                              ),
                              TextSpan(
                                text: "User Agreement",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    " and acknowledge that you understand the ",
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: "."),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.8,
                            child: Checkbox(
                              value: _receiveEmails,
                              onChanged: (value) {
                                setState(() {
                                  _receiveEmails = value ?? false;
                                });
                              },
                              side: BorderSide(color: Colors.grey[600]!),
                              fillColor: WidgetStateProperty.resolveWith(
                                (states) =>
                                    states.contains(WidgetState.selected)
                                        ? Colors.grey[800]
                                        : Colors.transparent,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "I agree to receive emails about cool stuff on Reddit.",
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Divider(color: Colors.grey[800], thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.inter(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Sign up",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
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
            // color: Colors.grey[900],
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
