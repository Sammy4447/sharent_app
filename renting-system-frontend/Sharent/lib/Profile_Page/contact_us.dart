import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:sharent/Profile_Page/faq.dart';


class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await UserPreferences.getUserToken();
    setState(() {
      _token = token;
    });
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    if (_token == null) {
      Flushbar(
        message: "User token not found. Please log in again.",
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade400,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    setState(() => _isSending = true);

    try {
      final url = Uri.parse('http://10.0.2.2:5000/api/contact');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'message': _messageController.text.trim()}),
      );

      setState(() => _isSending = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _messageController.clear();
        Flushbar(
          message: "Message sent successfully!",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green.shade600,
          margin: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to send message.';
        Flushbar(
          message: error,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade600,
          margin: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.error_outline, color: Colors.white),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);      }
    } catch (e) {
      setState(() => _isSending = false);
      Flushbar(
        message: 'Error: $e',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFF9575CD)),
        ),
      ),
      body: _token == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFADD8E6), Color(0xFFDDA0DD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'We’re here to help you! \nWhether you have questions about renting, your account, or need assistance, send us a message below. Our dedicated support team will respond promptly to ensure you have a great Sharent experience.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 30),

                // Glassy card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _messageController,
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your message';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Your Message',
                            prefixIcon: const Icon(Icons.message_outlined),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSending
                                ? null
                                : () async {
                              // Show confirmation dialog first
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm'),
                                  content: const Text('Are you sure you want to send this message?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Send'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                _sendMessage();
                              }
                            },
                            icon: _isSending
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.send),
                            label: Text(_isSending ? 'Sending...' : 'Send Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),

                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Your privacy matters.\nAll messages are securely handled and used only to assist you better. We never share your personal information without your consent.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                // const SizedBox(height: 40),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                const Text(
                  'Other Ways to Reach Us',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                contactInfoTile(Icons.email, 'support@sharent.app'),
                contactInfoTile(Icons.phone, '+977-9800000000'),
                contactInfoTile(Icons.location_on, 'Kanchanpur, Nepal'),
                const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Have a quick question?\nCheck out our FAQs — many common questions are answered there instantly.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FAQPage()));
                  },
                  icon: Icon(Icons.question_answer_outlined, color: Colors.red,),
                  label: Text("FAQs", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline, decorationColor: Colors.red,),),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget contactInfoTile(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
