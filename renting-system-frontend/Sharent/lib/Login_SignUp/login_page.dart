import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharent/Login_SignUp/signup_page.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:another_flushbar/flushbar.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> _loginUser() async {
    final url = Uri.parse('http://10.0.2.2:5000/api/auth/login');

    final body = jsonEncode({
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("Login status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        String parseUserIdFromJwt(String token) {
          final parts = token.split('.');
          if (parts.length != 3) throw Exception('Invalid token');

          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final payloadMap = json.decode(decoded);

          return payloadMap['userId'] ?? '';
        }

        final userId = parseUserIdFromJwt(token);
        final user = data['user'] ?? {};

        final userName = "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}";
        final userEmail = user['email'] ?? '';

        print("UserID: $userId");
        print("Token: $token");

        await UserPreferences.saveFullUserInfo(
          userId: userId,
          token: token,
          firstName: user["firstName"],
          lastName: user["lastName"],
          email: user["email"],
          phone: user["phone"],
          address: user["address"],
        );

        final savedUserId = await UserPreferences.getUserId();
        final savedToken = await UserPreferences.getUserToken();
        print("Saved userId: $savedUserId");
        print("Saved token: $savedToken");



        await Flushbar(
          message: 'Login successful!',
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green.shade600,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }


      else {
        final data = jsonDecode(response.body);
        Flushbar(
          message: data['message'] ?? 'Login failed',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade600,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);

      }
    } catch (e) {
      Flushbar(
        message: 'Error: $e',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade700,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF81D4FA), Color(0xFF9575CD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Back button
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),

                ),
              ),
              // Login Form
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text('Welcome To Sharent!', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 30),

                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                          ),
                          const SizedBox(height: 26),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() => _obscureText = !_obscureText);
                                },
                              ),
                            ),
                            validator: (value) =>
                            value!.isEmpty ? 'Please enter your password' : null,
                          ),
                          const SizedBox(height: 30),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _loginUser();
                              }
                            },
                            child: const Text('Login'),
                          ),
                          const SizedBox(height: 20),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUpPage()),
                              );
                            },
                            child: const Text("Don't have an account? Sign Up"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
