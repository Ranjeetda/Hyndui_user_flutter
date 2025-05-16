import 'package:flutter/material.dart';
import 'package:lmm_user/resource/app_colors.dart';
import 'package:lmm_user/resource/image_paths.dart';
import 'package:lmm_user/resource/pref_utils.dart';
import 'package:lmm_user/ui/profile/profile_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../book_screen/booking_history.dart';
import '../explore_routes/explore_routes.dart';
import '../help_support_screen/help_support_screen.dart';
import '../selection_screen/selection_screen.dart';
import '../suggest_screen/suggest_routes_page.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen();

  @override
  _ProfileSettingsScreen createState() => _ProfileSettingsScreen();
}

class _ProfileSettingsScreen extends State<ProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.settings,
              text: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.pin,
              text: 'Create M-Pin',
              onTap: () {
                showMpinDialog(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              text: 'Booking History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookingHistory()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              text: 'Explore Routes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExploreRoutes()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              text: 'Suggest Route',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SuggestRoutesPage()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              text: 'Help & Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HelpSupportScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              text: 'Logout',
              onTap: () {
                PrefUtils.setLoggedIn(false);
                Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        child: SelectionScreen(),
                        type: PageTransitionType.fade,
                        duration: const Duration(milliseconds: 900),
                        reverseDuration: (const Duration(milliseconds: 900))),
                        (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isVisible = true,
  }) {
    if (!isVisible) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_right, color: Colors.black),
        onTap: onTap,
      ),
    );
  }

  Future<void> showMpinDialog(BuildContext context) async {
    final TextEditingController mpinController = TextEditingController();
    final TextEditingController confirmMpinController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icons
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 80,
                        width: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Image.asset(ImagePaths.appLogo),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Header
                const Text(
                  "Create MPin number",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),

                const SizedBox(height: 12),

                // MPIN Field
                TextField(
                  controller: mpinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: "Enter (6 digit pin number)",
                    counterText: "",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Confirm MPIN Field
                TextField(
                  controller: confirmMpinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: "Please re-enter pin number",
                    counterText: "",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Add logic here
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(fontSize: 16,color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondarycolor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "No",
                          style: TextStyle(fontSize: 16,color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
