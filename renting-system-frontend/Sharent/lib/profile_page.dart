import 'package:flutter/material.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:sharent/Profile_Page/privacy_policy.dart';
import 'package:sharent/Profile_Page/about_us.dart';
import 'package:sharent/Profile_Page/rental_history.dart';
import 'package:sharent/Profile_Page/edit_profile.dart';
import 'package:sharent/Profile_Page/help_and_support.dart';
import 'package:sharent/Profile_Page/delete_account.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final name = await UserPreferences.getUserName();
    final email = await UserPreferences.getUserEmail();

    if (name == null || email == null) {
      // Not logged in — redirect to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      setState(() {
        userName = name;
        userEmail = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFF9575CD)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFADD8E6), Color(0xFFDDA0DD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadUserData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName ?? "Loading...",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userEmail ?? "Loading...",
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 30),

                  _buildProfileOption(
                    icon: Icons.edit,
                    label: "Edit Profile",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfile()),
                      );
                      await loadUserData();
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.history,
                    label: "Rental History",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RentalHistory()),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.privacy_tip_outlined,
                    label: "Privacy Policy",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                      );                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.info_outline,
                    label: "About Us",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutUsPage()),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.help,
                    label: "Help and Support",
                    onTap: () {Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpSupportPage()),
                    );
                                          },
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    label: "Logout",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm Logout"),
                            content: Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: Text("Logout"),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog first
                                  UserPreferences.clearUserInfo();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                        (route) => false,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox( height: 30,),
                  TextButton.icon(
                    onPressed: _confirmDeleteAccount,
                    icon: Icon(Icons.delete_forever, color: Colors.red),
                    label: Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                        decorationThickness: 2,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Account Deletion?'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeleteAccountPage()),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
