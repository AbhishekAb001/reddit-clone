import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  text: 'Messages',
                  height: screenHeight * 0.06,
                ),
                Tab(
                  text: 'Threads',
                  height: screenHeight * 0.06,
                ),
                Tab(
                  text: 'Requests',
                  height: screenHeight * 0.06,
                ),
              ],
              labelStyle: GoogleFonts.inter(fontSize: screenWidth * 0.035),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Messages Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.reddit,
                          size: screenWidth * 0.25,
                          color: Colors.white,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          'This feature is coming soon!',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'We are working hard to bring you\nthis exciting feature.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Threads Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.reddit,
                          size: screenWidth * 0.25,
                          color: Colors.white,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          'This feature is coming soon!',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Requests Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.reddit,
                          size: screenWidth * 0.25,
                          color: Colors.white,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          'This feature is coming soon!',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          width: screenWidth * 0.14,
          height: screenWidth * 0.14,
          child: FloatingActionButton(
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'This feature is coming soon!',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(10),
              );
            },
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.add,
              size: screenWidth * 0.06,
            ),
          ),
        ),
      ),
    );
  }
}
