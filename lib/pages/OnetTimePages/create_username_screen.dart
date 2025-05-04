import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit/pages/OnetTimePages/interests_screen.dart';
import 'package:reddit/pages/PostPages/services/firestore_service.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateUsernameScreen extends StatefulWidget {
  final String uid;

  const CreateUsernameScreen({
    super.key,
    required this.uid,
  });

  @override
  State<CreateUsernameScreen> createState() => _CreateUsernameScreenState();
}

class _CreateUsernameScreenState extends State<CreateUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isValid = false;
  bool _isChecking = false;
  bool _isSaving = false;
  List<String> suggestedUsernames = [];
  Timer? _debounceTimer;
  String? _errorMessage;

  final List<String> _adjectives = [
    'Creative',
    'Swift',
    'Bright',
    'Clever',
    'Brave',
    'Wise',
    'Gentle',
    'Happy',
    'Lucky',
    'Calm',
    'Kind',
    'Smart',
    'Quick',
    'Bold',
    'Cool'
  ];

  final List<String> _nouns = [
    'Mind',
    'Runner',
    'Star',
    'Soul',
    'Heart',
    'Spirit',
    'Dream',
    'Light',
    'Wave',
    'Wind',
    'Cloud',
    'Moon',
    'Sun',
    'Tree',
    'Bird'
  ];

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
    _nameController.addListener(_onNameChanged);
    _generateInitialUsernames();
    _checkExistingUserData();
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _nameController.removeListener(_onNameChanged);
    _usernameController.dispose();
    _nameController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _generateInitialUsernames() {
    setState(() {
      suggestedUsernames = _generateRandomUsernames(3);
    });
  }

  List<String> _generateRandomUsernames(int count) {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final usernames = <String>[];

    for (var i = 0; i < count; i++) {
      final adjective = _adjectives[random.nextInt(_adjectives.length)];
      final noun = _nouns[random.nextInt(_nouns.length)];
      final number = (timestamp % 10000 + i).toString().padLeft(4, '0');
      usernames.add('${adjective}_${noun}_$number');
    }

    return usernames;
  }

  Future<void> _checkExistingUserData() async {
    try {
      final userData = await _firestoreService.getUserData(widget.uid);
      if (userData != null) {
        setState(() {
          if (userData['displayName'] != null) {
            _nameController.text = userData['displayName'];
          }
          if (userData['username'] != null) {
            _usernameController.text = userData['username'];
            _isValid = true;
          }
        });
      }
    } catch (e) {
      print('Error checking existing user data: $e');
    }
  }

  void _onNameChanged() {
    // Add any name validation logic here if needed
  }

  Future<void> _onUsernameChanged() async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final username = _usernameController.text.trim();

      if (username.isEmpty) {
        setState(() {
          _isValid = false;
          _isChecking = false;
          _errorMessage = 'Username cannot be empty';
        });
        return;
      }

      if (username.length < 3) {
        setState(() {
          _isValid = false;
          _isChecking = false;
          _errorMessage = 'Username must be at least 3 characters long';
        });
        return;
      }

      if (username.length > 20) {
        setState(() {
          _isValid = false;
          _isChecking = false;
          _errorMessage = 'Username must be less than 20 characters';
        });
        return;
      }

      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        setState(() {
          _isValid = false;
          _isChecking = false;
          _errorMessage =
              'Username can only contain letters, numbers, and underscores';
        });
        return;
      }

      final reservedWords = [
        'admin',
        'moderator',
        'reddit',
        'mod',
        'administrator'
      ];
      if (reservedWords.contains(username.toLowerCase())) {
        setState(() {
          _isValid = false;
          _isChecking = false;
          _errorMessage = 'This username is reserved';
        });
        return;
      }

      setState(() {
        _isChecking = true;
        _errorMessage = null;
      });

      try {
        final exists = await _firestoreService.checkUsernameExists(username);
        if (mounted) {
          setState(() {
            _isValid = !exists;
            _isChecking = false;
            _errorMessage = exists ? 'This username is already taken' : null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isValid = false;
            _isChecking = false;
            _errorMessage =
                'Error checking username availability. Please try again.';
          });
        }
      }
    });
  }

  void _generateMoreUsernames() {
    setState(() {
      suggestedUsernames = _generateRandomUsernames(3);
    });
  }

  Future<void> _saveUsername() async {
    if (!_isValid || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final exists = await _firestoreService
          .checkUsernameExists(_usernameController.text.trim());
      if (exists) {
        setState(() {
          _isValid = false;
          _isSaving = false;
          _errorMessage =
              'This username was just taken. Please choose another one.';
        });
        return;
      }

      await _firestoreService.updateUserData(widget.uid, {
        'username': _usernameController.text.trim(),
        'displayName': _nameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Get.offAll(
          () => InterestsScreen(uid: widget.uid),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to save username. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
        );
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
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.015),
                      Center(
                        child: Image.asset(
                          "assets/images/redit.png",
                          width: size.width * 0.1,
                          height: size.width * 0.1,
                          color: const Color(0xFFFF4500),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Text(
                        'Create your profile',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 24 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        'Add your name and choose a username for Reddit.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14 * textScaleFactor,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius:
                              BorderRadius.circular(size.width * 0.06),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: GoogleFonts.ibmPlexSans(
                            color: Colors.white,
                            fontSize: 16 * textScaleFactor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Your Name',
                            hintStyle: GoogleFonts.ibmPlexSans(
                              color: Colors.grey[600],
                              fontSize: 16 * textScaleFactor,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.015,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius:
                              BorderRadius.circular(size.width * 0.06),
                        ),
                        child: TextField(
                          controller: _usernameController,
                          style: GoogleFonts.ibmPlexSans(
                            color: Colors.white,
                            fontSize: 16 * textScaleFactor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: GoogleFonts.ibmPlexSans(
                              color: Colors.grey[600],
                              fontSize: 16 * textScaleFactor,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.015,
                            ),
                            suffixIcon: _isChecking
                                ? SizedBox(
                                    width: size.width * 0.05,
                                    height: size.width * 0.05,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(size.width * 0.03),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFFFF4500),
                                        ),
                                      ),
                                    ),
                                  )
                                : _isValid
                                    ? Icon(Icons.check,
                                        color: Colors.green,
                                        size: size.width * 0.06)
                                    : _usernameController.text.isNotEmpty
                                        ? Icon(Icons.close,
                                            color: Colors.red,
                                            size: size.width * 0.06)
                                        : null,
                          ),
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(top: size.height * 0.01),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.ibmPlexSans(
                              color: Colors.red,
                              fontSize: 14 * textScaleFactor,
                            ),
                          ),
                        ),
                      if (_isValid)
                        Padding(
                          padding: EdgeInsets.only(top: size.height * 0.01),
                          child: Text(
                            'Great name! It\'s not taken, so it\'s all yours.',
                            style: GoogleFonts.ibmPlexSans(
                              color: Colors.green,
                              fontSize: 14 * textScaleFactor,
                            ),
                          ),
                        ),
                      SizedBox(height: size.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Suggested usernames:',
                            style: GoogleFonts.ibmPlexSans(
                              color: Colors.grey[400],
                              fontSize: 14 * textScaleFactor,
                            ),
                          ),
                          TextButton(
                            onPressed: _generateMoreUsernames,
                            child: Text(
                              'Generate more',
                              style: GoogleFonts.ibmPlexSans(
                                color: Color(0xFFFF4500),
                                fontSize: 14 * textScaleFactor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      ...suggestedUsernames.map((username) => Padding(
                            padding:
                                EdgeInsets.only(bottom: size.height * 0.01),
                            child: InkWell(
                              onTap: () {
                                _usernameController.text = username;
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04,
                                  vertical: size.height * 0.015,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.06),
                                ),
                                child: Text(
                                  username,
                                  style: GoogleFonts.ibmPlexSans(
                                    color: Colors.grey[300],
                                    fontSize: 14 * textScaleFactor,
                                  ),
                                ),
                              ),
                            ),
                          )),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      size.height * 0.02,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: _isValid ? _saveUsername : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isValid ? Color(0xFFFF4500) : Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.06),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: size.width * 0.05,
                            height: size.width * 0.05,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Continue',
                            style: GoogleFonts.ibmPlexSans(
                              color: Colors.white,
                              fontSize: 16 * textScaleFactor,
                              fontWeight: FontWeight.bold,
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
