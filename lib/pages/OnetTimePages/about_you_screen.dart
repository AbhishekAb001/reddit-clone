import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/pages/HomePages/Navigation_screen.dart';
import 'package:reddit/widgets/loading_screen.dart';
import 'package:reddit/services/firestore_service.dart';
import 'package:reddit/pages/OnetTimePages/interests_screen.dart';

class AboutYouScreen extends StatefulWidget {
  final String uid;

  const AboutYouScreen({
    super.key,
    required this.uid,
  });

  @override
  State<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  String? _selectedGender;
  final _firestoreService = FirestoreService();
  bool _isSaving = false;

  final List<String> _genderOptions = [
    'Man',
    'Woman',
    'Non-binary',
    'I prefer not to say',
  ];

  Future<void> _saveAndContinue() async {
    if (_selectedGender == null) return;

    setState(() => _isSaving = true);

    try {
      await _firestoreService.updateUserData(widget.uid, {
        'gender': _selectedGender,
        'hasCompletedOnboarding': true,
      });
      Get.offAll(
        () => InterestsScreen(uid: widget.uid),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save your preferences. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white, size: size.width * 0.06),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.offAll(
                () => const LoadingScreen(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500),
              );
            },
            child: Text(
              'Skip',
              style: GoogleFonts.ibmPlexSans(
                color: Colors.white,
                fontSize: 16 * textScaleFactor,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/redit.png',
                width: size.width * 0.1,
                height: size.width * 0.1,
                color: const Color(0xFFFF4500),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              'About you',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 24 * textScaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Tell us about yourself to improve your recommendations and ads.',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 16 * textScaleFactor,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.04),
            Text(
              'How do you identify?',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 16 * textScaleFactor,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.02),
            ...List.generate(
              _genderOptions.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedGender = _genderOptions[index];
                    });
                  },
                  child: Container(
                    width: size.width * 0.8,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size.width * 0.1),
                      border: Border.all(
                        color: _selectedGender == _genderOptions[index]
                            ? const Color(0xFFFF4500)
                            : Colors.grey[800]!,
                        width: 2,
                      ),
                      color: _selectedGender == _genderOptions[index]
                          ? const Color(0xFFFF4500)
                          : Colors.grey[900],
                    ),
                    child: Text(
                      _genderOptions[index],
                      style: GoogleFonts.ibmPlexSans(
                        color: _selectedGender == _genderOptions[index]
                            ? Colors.white
                            : Colors.grey[300],
                        fontSize: 16 * textScaleFactor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: size.height * 0.06,
              child: ElevatedButton(
                onPressed: _selectedGender != null && !_isSaving
                    ? _saveAndContinue
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.1),
                  ),
                  disabledBackgroundColor: Colors.grey[800],
                ),
                child: Text(
                  _isSaving ? 'Saving...' : 'Continue',
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.white,
                    fontSize: 16 * textScaleFactor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
