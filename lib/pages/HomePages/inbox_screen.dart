import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:reddit/model/notification.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late double screenWidth;
  late double screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(
                    text: 'Notifications',
                    icon: Icon(Icons.notifications, size: screenWidth * 0.06),
                  ),
                  Tab(
                    text: 'Messages',
                    icon: Icon(Icons.message, size: screenWidth * 0.06),
                  ),
                ],
                labelStyle: GoogleFonts.inter(fontSize: screenWidth * 0.04),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Notifications tab
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

                    // Messages tab
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotification(
    String title,
    String subtitle,
    String time,
    IconData icon, {
    bool showDivider = false,
    required String notificationId,
  }) {
    return Dismissible(
      key: Key(notificationId),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: screenWidth * 0.04),
        child:
            Icon(Icons.delete, color: Colors.white, size: screenWidth * 0.06),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {},
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: screenWidth * 0.05,
              backgroundColor: Colors.grey[800],
              child: Icon(icon, color: Colors.white, size: screenWidth * 0.04),
            ),
            title: Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: screenWidth * 0.04,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: screenWidth * 0.035,
              ),
            ),
            trailing: Text(
              time,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
          if (showDivider) Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }
}
