import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avatar_plus/avatar_plus.dart';
import 'package:reddit/controller/profile_controller.dart';

class CreateAvatarPage extends StatefulWidget {
  const CreateAvatarPage({super.key});

  @override
  State<CreateAvatarPage> createState() => _CreateAvatarPageState();
}

class _CreateAvatarPageState extends State<CreateAvatarPage> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final List<String> _avatarSeeds = List.generate(12,
      (index) => 'Redditor${DateTime.now().millisecondsSinceEpoch + index}');
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Avatar'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Pick an avatar you like! You can change it later.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _avatarSeeds.length,
                itemBuilder: (context, index) {
                  final seed = _avatarSeeds[index];
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isSelected ? Colors.orange : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: AvatarPlus(
                        seed,
                        height: screenWidth / 4,
                        width: screenWidth / 4,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _selectedIndex == null
                  ? null
                  : () async {
                      final selectedSeed = _avatarSeeds[_selectedIndex!];
                      // Save the selected avatar seed as the user's photoUrl
                      await _profileController.updatePhotoUrl(selectedSeed);
                      Get.back(result: selectedSeed);
                      Get.snackbar(
                          'Avatar Updated', 'Your avatar has been updated!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white);
                    },
              child: const Text('Save Avatar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
