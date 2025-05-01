import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reddit/pages/home_screen.dart';
import 'package:reddit/pages/AuthPages/phone_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  String selectedCountryCode = '+91';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your phone number',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    final phoneNumber = selectedCountryCode + _phoneController.text.trim();

    await _authService.verifyPhoneNumber(
      phoneNumber,
      (String verificationId) {
        setState(() => _isLoading = false);
        Get.to(
          () => PhoneVerificationScreen(
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          ),
        );
      },
      (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        Get.snackbar(
          'Error',
          e.message ?? 'Failed to verify phone number',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
        );
      },
      (PhoneAuthCredential credential) async {
        setState(() => _isLoading = false);
        final userCredential = await _authService.signInWithPhoneNumber(
          credential.verificationId!,
          credential.smsCode!,
        );
        if (userCredential != null) {
          Get.offAll(() => HomeScreen());
        }
      },
      (String verificationId) {
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Reddit Logo
              Center(
                child: Image.asset(
                  "assets/images/redit.png",
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  color: Color(0xFFFF4500),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Title
              Text(
                "Sign up or log in with your\nphone number",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Phone number input row
              Row(
                children: [
                  // Country code selector
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1B),
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/india.jpg', // Make sure to add this asset
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.04,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          selectedCountryCode,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),

                  // Phone number input field
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                      ),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: screenWidth * 0.04,
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A1B),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.06,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.018,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Terms text
              Text(
                'Reddit will use your phone number for account verification and to personalize your ads and experience. By entering your phone number, you agree that Reddit may send you verification messages via either WhatsApp or SMS. SMS fees may apply.',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontSize: screenWidth * 0.035,
                ),
              ),

              // Learn more link
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Learn more',
                    style: GoogleFonts.inter(
                      color: Colors.blue,
                      fontSize: screenWidth * 0.035,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              Spacer(),

              // Continue button
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.06),
                        side: BorderSide(
                          color: _isLoading ? Colors.grey[800]! : Colors.white,
                        ),
                      ),
                    ),
                    child: Text(
                      _isLoading ? 'Sending code...' : 'Continue',
                      style: GoogleFonts.inter(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
