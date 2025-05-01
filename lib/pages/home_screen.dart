import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reddit/model/raddial_post.dart';
import 'package:get/get.dart';
import 'package:reddit/pages/answers_screen.dart';
import 'package:reddit/pages/create_post_screen.dart';
import 'package:reddit/pages/chat_screen.dart';
import 'package:reddit/pages/inbox_screen.dart';
import 'package:reddit/pages/AuthPages/login_screen.dart';
import 'package:reddit/controller/profile_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ProfileController _profileController = Get.put(ProfileController());

  final List<RedditPost> posts = [
    RedditPost(
      subreddit: "r/bollywoodcirclejerk",
      timeAgo: "4d",
      views: "170k views",
      title: "Akshay making non-stop comeback for the last 5 years",
      imageUrl:
          "https://m.media-amazon.com/images/M/MV5BODI4NDY1NzkyM15BMl5BanBnXkFtZTgwNzM3MDM0OTE@._V1_.jpg", // Replace with actual image URL
      upvotes: 5500,
      comments: 42,
      shares: 388,
    ),
    // Add more posts as needed
  ];

  Future<void> _logout() async {
    await _profileController.clearUserData();
    Get.offAll(() => LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      // Left drawer for communities
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Your Communities',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              trailing: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ),
            ListTile(
              leading: Icon(Icons.add, color: Colors.white),
              title: Text(
                'Create a community',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
            _buildCommunityTile(
              'r/BollyBlindsNGossip',
              FontAwesomeIcons.reddit,
            ),
            _buildCommunityTile('r/europe', FontAwesomeIcons.globe),
            _buildCommunityTile('r/IndiaTech', FontAwesomeIcons.laptop),
            _buildCommunityTile('r/pcmasterrace', FontAwesomeIcons.computer),
            _buildCommunityTile('r/pune', FontAwesomeIcons.locationDot),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: Colors.grey),
              title: Text(
                'Custom Feeds',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.all_inclusive, color: Colors.grey),
              title: Text('All', style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
      ),
      // Right drawer for settings
      endDrawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[800],
                    child: Icon(FontAwesomeIcons.user, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Obx(() => Text(
                        'u/${_profileController.username.value}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Online Status: On',
                        style: GoogleFonts.inter(color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() => _buildProfileTile(
                '${_profileController.karma.value} Karma',
                FontAwesomeIcons.star)),
            Obx(() => _buildProfileTile(
                '${_profileController.redditAge.value} Reddit age',
                FontAwesomeIcons.clock)),
            _buildProfileTile('Profile', FontAwesomeIcons.user),
            _buildProfileTile('Create a community', FontAwesomeIcons.plus),
            _buildProfileTile('Reddit Premium', FontAwesomeIcons.crown),
            _buildProfileTile('Contributor Program', FontAwesomeIcons.trophy),
            _buildProfileTile('Saved', FontAwesomeIcons.bookmark),
            _buildProfileTile('History', FontAwesomeIcons.clockRotateLeft),
            _buildProfileTile('Settings', FontAwesomeIcons.gear),
            Divider(color: Colors.grey[800]),
            ListTile(
              leading:
                  Icon(FontAwesomeIcons.rightFromBracket, color: Colors.red),
              title: Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.bars, color: Colors.white, size: 20),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFFF4500),
              radius: screenWidth * 0.04,
              child: Image.network(
                'https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png',
                width: screenWidth * 0.05,
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'reddit',
              style: GoogleFonts.inter(
                color: Color(0xFFFF4500),
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: CircleAvatar(
              radius: screenWidth * 0.04,
              backgroundColor: Colors.grey[800],
              child: Icon(FontAwesomeIcons.user, color: Colors.white, size: 16),
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(post);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              // Home
              break;
            case 1:
              Get.to(() => AnswersScreen());
              break;
            case 2:
              Get.to(() => CreatePostScreen());
              break;
            case 3:
              Get.to(() => ChatScreen());
              break;
            case 4:
              Get.to(() => InboxScreen());
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_outlined),
            label: 'Answers',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.inbox),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                    child: Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Inbox',
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(RedditPost post) {
    return Card(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          ListTile(
            dense: true,
            leading: Text(
              'Because you\'ve shown interest in a similar community',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Icon(Icons.more_vert, color: Colors.grey),
          ),
          // Subreddit info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
                SizedBox(width: 8),
                Text(
                  post.subreddit,
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                Text(
                  ' • ${post.timeAgo} • ${post.views}',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Join'),
                ),
              ],
            ),
          ),
          // Post title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              post.title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Post image
          Image.network(
            post.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Post actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  Icons.arrow_upward,
                  post.upvotes.toString(),
                  Icons.arrow_downward,
                ),
                _buildActionButton(
                  Icons.mode_comment_outlined,
                  post.comments.toString(),
                ),
                _buildActionButton(Icons.share, post.shares.toString()),
              ],
            ),
          ),
          Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String count, [
    IconData? secondIcon,
  ]) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        SizedBox(width: 4),
        Text(count, style: GoogleFonts.inter(color: Colors.grey)),
        if (secondIcon != null) ...[
          SizedBox(width: 4),
          Icon(secondIcon, color: Colors.grey, size: 20),
        ],
      ],
    );
  }

  Widget _buildCommunityTile(String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(name, style: GoogleFonts.inter(color: Colors.white)),
      trailing: Icon(Icons.star_border, color: Colors.grey),
    );
  }

  Widget _buildProfileTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white)),
    );
  }
}
