import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'more_pages/aboutus_page.dart';
import 'more_pages/exportdata_page.dart';
import 'more_pages/myprofile_page.dart';
import 'more_pages/notificationsettings_page.dart';
import 'more_pages/researchstudy_page.dart';

const kBrandBlue = Color(0xFF1E40AF);
const kBackgroundWhite = Color(0xFFFAFAFA); // Slightly off-white for contrast

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user email safely
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "No Email Found";

    return Scaffold(
      backgroundColor: kBackgroundWhite,
      appBar: AppBar(
        title: const Text(
          "Health Monitor",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. MY ACCOUNT CARD (Brand Color Gradient) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E40AF),
                    Color(0xFF3B82F6),
                  ], // Keep the blue brand identity
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. MENU ITEMS ---
            // Colors are softer to match the "White Theme" aesthetic
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              iconColor: kBrandBlue,
              iconBgColor: const Color(0xFFEFF6FF), // Very pale blue
              title: "My Profile",
              subtitle: "View and edit your information",
              destination: const MyProfilePage(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.science_outlined,
              iconColor: Colors.purple,
              iconBgColor: const Color(0xFFFAF5FF), // Very pale purple
              title: "Research Study",
              subtitle: "Study Code: 123456",
              destination: const ResearchStudyPage(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              iconColor: Colors.teal,
              iconBgColor: const Color(0xFFF0FDFA), // Very pale teal
              title: "About Us",
              subtitle: "Learn more about this app",
              destination: const AboutUsPage(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_none,
              iconColor: Colors.orange,
              iconBgColor: const Color(0xFFFFF7ED), // Very pale orange
              title: "Notification Settings",
              subtitle: "Manage your notifications",
              destination: const NotificationSettingsPage(),
            ),
            _buildMenuItem(
              context,
              icon: Icons.download_outlined,
              iconColor: const Color(0xFF4F46E5),
              iconBgColor: const Color(0xFFEEF2FF),
              title: "Export My Data",
              subtitle: "Download your health data",
              destination: const ExportDataPage(),
            ),

            const SizedBox(height: 8),

            // --- 3. LOG OUT BUTTON ---
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 24),
                ),
                title: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(
                  "Sign out of your account",
                  style: TextStyle(color: Colors.red.shade300, fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () => _handleLogout(context),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Health Monitor v1.0.0",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Menu Items
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required Widget destination,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Subtle shadow for the white theme
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      // AuthGate will handle the redirection automatically
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error signing out: $e")));
      }
    }
  }
}
