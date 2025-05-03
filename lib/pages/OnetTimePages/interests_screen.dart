import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/pages/OnetTimePages/about_you_screen.dart';
import 'package:reddit/services/firestore_service.dart';
import 'package:reddit/widgets/loading_screen.dart';

class InterestsScreen extends StatefulWidget {
  final String uid;

  const InterestsScreen({
    super.key,
    required this.uid,
  });

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedInterests = {};
  final _firestoreService = FirestoreService();

  final Map<String, List<String>> _categories = {
    '📈 Popular': [
      'Bollywood gossip',
      'mumbai',
      'OffMyChestIndia',
      'Cricket',
      'JEENEETards',
      'ipl',
      'developersIndia',
      'CreditCardsIndia',
    ],
    '🌎 Places & Travel': [
      'nagpur',
      'Places in Asia',
      'IndiaSpeaks',
      'india',
      'Travel & Holiday',
      'Places in Europe',
      'Places in the Middle East',
    ],
    '⚡ Pop Culture': [
      'Celebrities',
      'TeenIndia',
      'BollyGoodVibes',
      'IndianTeens',
      'InstaCelebsGossip',
      'Generations & Nostalgia',
      'Creators',
    ],
    '✏️ Q&As & Stories': [
      'Q&As',
      'Am I the A**hole',
      'Stories & Confessions',
      'Ask Reddit',
      'AskIndia',
      'AskIndianWomen',
      'Best of Reddit',
    ],
    '🎬 Movies & TV': [
      'Movie News & Discussion',
      'bollywoodcirclejerk',
      'BollywoodFashion',
      'bollywoodmemes',
      'sharktankindia',
      'Reality TV',
      'Cooking Shows',
    ],
  };

  Future<void> _saveAndContinue() async {
    if (_selectedInterests.isEmpty) return;

    try {
      await _firestoreService.saveUserInterests(
        widget.uid,
        _selectedInterests.toList(),
      );
      Get.offAll(
        () => const LoadingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save interests. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
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
              Get.to(
                () => AboutYouScreen(uid: widget.uid),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/redit.png',
                    width: size.width * 0.1,
                    height: size.width * 0.1,
                    color: const Color(0xFFFF4500),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Interests',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 24 * textScaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Pick things you\'d like to see in your home feed.',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 16 * textScaleFactor,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories.keys.elementAt(index);
                final interests = _categories[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.height * 0.01),
                      child: Text(
                        category,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 18 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: size.width * 0.02,
                      runSpacing: size.width * 0.02,
                      children: interests.map((interest) {
                        final isSelected =
                            _selectedInterests.contains(interest);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedInterests.remove(interest);
                              } else {
                                _selectedInterests.add(interest);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF4500)
                                  : Colors.grey[900],
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.05),
                            ),
                            child: Text(
                              interest,
                              style: GoogleFonts.ibmPlexSans(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[300],
                                fontSize: 14 * textScaleFactor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              children: [
                Text(
                  '${_selectedInterests.length} of 1 selected',
                  style: GoogleFonts.ibmPlexSans(
                    color: Colors.grey[400],
                    fontSize: 14 * textScaleFactor,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                    onPressed:
                        _selectedInterests.isNotEmpty ? _saveAndContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.06),
                      ),
                      disabledBackgroundColor: Colors.grey[800],
                    ),
                    child: Text(
                      'Continue',
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
        ],
      ),
    );
  }
}
