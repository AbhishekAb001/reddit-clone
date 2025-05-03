import 'package:flutter/material.dart';

class HistoryDrawerPage extends StatelessWidget {
  const HistoryDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.history, size: screenWidth * 0.07),
            title: Text('Visited r/mumbai',
                style: TextStyle(fontSize: screenWidth * 0.045)),
            subtitle:
                Text('1d ago', style: TextStyle(fontSize: screenWidth * 0.035)),
          ),
          ListTile(
            leading: Icon(Icons.history, size: screenWidth * 0.07),
            title: Text('Visited r/india',
                style: TextStyle(fontSize: screenWidth * 0.045)),
            subtitle:
                Text('2d ago', style: TextStyle(fontSize: screenWidth * 0.035)),
          ),
        ],
      ),
    );
  }
}
