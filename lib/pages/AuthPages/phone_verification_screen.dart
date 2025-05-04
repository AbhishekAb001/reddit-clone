import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/services/auth_service.dart';
import 'package:reddit/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const PhoneVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _codeController = TextEditingController();
  final _authService = AuthService();
  bool _isVerifying = false;
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit code',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final userCredential = await _authService.signInWithPhoneNumber(
        widget.verificationId,
        _codeController.text,
      );

      if (userCredential != null) {
        Get.offAll(() => const LoadingScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500));
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.025),
              Center(
                child: Image.asset(
                  "assets/images/redit.png",
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                'Verify your phone number',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Enter the 6 digit code sent to\n${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              TextField(
                controller: _codeController,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Verification code',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.04,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              if (!_canResend)
                Text(
                  'Resend in ${_resendTimer.toString().padLeft(2, '0')}:${(0).toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.035,
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    // Implement resend logic here
                    setState(() {
                      _canResend = false;
                      _resendTimer = 30;
                    });
                    _startResendTimer();
                  },
                  child: Text(
                    'Resend code',
                    style: GoogleFonts.inter(
                      color: Colors.blue,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.06),
                        side: BorderSide(
                          color:
                              _isVerifying ? Colors.grey[800]! : Colors.white,
                        ),
                      ),
                    ),
                    child: _isVerifying
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.05,
                                height: screenWidth * 0.05,
                                child: CircularProgressIndicator(
                                  strokeWidth: screenWidth * 0.005,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Text(
                                'Verifying...',
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Continue',
                            style: GoogleFonts.inter(
                              fontSize: screenWidth * 0.04,
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
