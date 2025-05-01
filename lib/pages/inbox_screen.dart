import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text('Inbox', style: GoogleFonts.inter(color: Colors.white)),
          bottom: TabBar(
            tabs: [Tab(text: 'Notifications'), Tab(text: 'Messages')],
            labelStyle: GoogleFonts.inter(),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
        ),
        body: ListView(
          children: [
            _buildNotification(
              'Achievement unlocked!',
              'Check out your newest achievement',
              '1h',
              FontAwesomeIcons.trophy,
            ),
            _buildNotification(
              'A new beginning',
              'Congrats on your new streak! Click to learn more',
              '13h',
              FontAwesomeIcons.fire,
              showDivider: true,
            ),
          ],
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
  }) {
    return Dismissible(
      key: Key(title),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            title: Text(title, style: GoogleFonts.inter(color: Colors.white)),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.inter(color: Colors.grey),
            ),
            trailing: Text(time, style: GoogleFonts.inter(color: Colors.grey)),
          ),
          if (showDivider) Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }
}
