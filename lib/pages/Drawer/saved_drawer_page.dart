import 'package:flutter/material.dart';

class SavedDrawerPage extends StatelessWidget {
  const SavedDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[500],
            tabs: const [
              Tab(text: 'Posts'),
              Tab(text: 'Comments'),
              Tab(text: 'Likes'),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        body: TabBarView(
          children: [
            // Posts Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    radius: screenWidth * 0.12,
                    child: Icon(Icons.pets, size: screenWidth * 0.12, color: Colors.grey[400]),
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    'Wow, such empty',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ],
              ),
            ),
            // Comments Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    radius: screenWidth * 0.12,
                    child: Icon(Icons.pets, size: screenWidth * 0.12, color: Colors.grey[400]),
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    'Wow, such empty',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ],
              ),
            ),
            // Likes Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    radius: screenWidth * 0.12,
                    child: Icon(Icons.favorite, size: screenWidth * 0.12, color: Colors.grey[400]),
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    'Wow, such empty',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
