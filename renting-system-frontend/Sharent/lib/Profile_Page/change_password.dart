import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:another_flushbar/flushbar.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:sharent/profile_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final oldController = TextEditingController();
  final newController = TextEditingController();

  bool isLoading = false;
  bool oldPasswordVisible = false;
  bool newPasswordVisible = false;

  Future<void> changePassword() async {
    final oldPwd = oldController.text.trim();
    final newPwd = newController.text.trim();
    final token = await UserPreferences.getUserToken();

    if (oldPwd.isEmpty || newPwd.isEmpty) {
      _showFlushbar("Please fill in all fields", false);
      return;
    }

    setState(() => isLoading = true);

    final response = await http.put(
      Uri.parse('http://10.0.2.2:5000/api/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'oldPassword': oldPwd,
        'password': newPwd,
      }),
    );

    setState(() => isLoading = false);

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      _showFlushbar("✅ Password changed successfully!", true);

      // Navigate to ProfilePage after short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      });
    } else {
      _showFlushbar("❌ ${data['message'] ?? 'Failed to update password'}", false);
    }
  }

  void _showFlushbar(String message, bool isSuccess) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: oldController,
                obscureText: !oldPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Old Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      oldPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        oldPasswordVisible = !oldPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newController,
                obscureText: !newPasswordVisible,
                decoration: InputDecoration(
                  labelText: "New Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        newPasswordVisible = !newPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : changePassword,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Update Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
