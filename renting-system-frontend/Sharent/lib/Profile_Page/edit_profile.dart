import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:sharent/Profile_Page/change_password.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  final Map<String, bool> isEditing = {
    'firstName': false,
    'lastName': false,
    'phone': false,
    'address': false,
  };

  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? oldPassword;
  String? newPassword;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final fName = await UserPreferences.getFirstName();
    final lName = await UserPreferences.getLastName();
    final mail = await UserPreferences.getUserEmail();
    final ph = await UserPreferences.getPhone();
    final addr = await UserPreferences.getAddress();

    setState(() {
      firstName = fName;
      lastName = lName;
      email = mail;
      phone = ph;
      address = addr;
    });
  }

  Future<void> updateProfile() async {
    final token = await UserPreferences.getUserToken();
    final userId = await UserPreferences.getUserId();

    final Map<String, dynamic> payload = {
      if (firstName != null && firstName!.isNotEmpty) 'firstName': firstName,
      if (lastName != null && lastName!.isNotEmpty) 'lastName': lastName,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (newPassword != null && newPassword!.isNotEmpty) 'password': newPassword,
      if (newPassword != null && newPassword!.isNotEmpty && oldPassword != null) 'oldPassword': oldPassword,
    };

    setState(() => isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final updatedUser = data['user'];
        await UserPreferences.saveFullUserInfo(
          userId: updatedUser['_id'] ?? userId ?? '',
          token: token ?? '',
          firstName: updatedUser['firstName'] ?? firstName ?? '',
          lastName: updatedUser['lastName'] ?? lastName ?? '',
          email: updatedUser['email'] ?? email ?? '',
          phone: updatedUser['phone'] ?? phone ?? '',
          address: updatedUser['address'] ?? address ?? '',
        );

        await Flushbar(
          message: "✅ ${data['message']}",
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green.shade600,
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        ).show(context);

        Navigator.pop(context);
      } else {
        Flushbar(
          message: "❌ ${data['message'] ?? 'Update failed'}",
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.shade600,
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        ).show(context);
      }
    } catch (e) {
      Flushbar(
        message: "❌ Something went wrong.",
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.shade600,
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
    }
    setState(() => isLoading = false);
  }

  Widget buildEditableField(String label, String? value, String key, void Function(String) onChanged) {
    final isFieldEditing = isEditing[key]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: isFieldEditing
                ? TextFormField(
              initialValue: value,
              decoration: InputDecoration(labelText: label),
              onChanged: onChanged,
            )
                : ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(value ?? '-', style: const TextStyle(color: Colors.black87)),
            ),
          ),
          IconButton(
            icon: Icon(isFieldEditing ? Icons.check : Icons.edit, color: Colors.deepPurple),
            onPressed: () => setState(() => isEditing[key] = !isEditing[key]!),
          ),
        ],
      ),
    );
  }

  Widget buildFieldBox(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFF9575CD)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(

        child: Container(
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFADD8E6), Color(0xFFDDA0DD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20,),
              buildFieldBox(buildEditableField('First Name', firstName, 'firstName', (val) => firstName = val)),
              buildFieldBox(buildEditableField('Last Name', lastName, 'lastName', (val) => lastName = val)),

              buildFieldBox(
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(email ?? '-', style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.lock_outline, color: Colors.grey),
                ),
              ),

              buildFieldBox(buildEditableField('Phone', phone, 'phone', (val) => phone = val)),
              buildFieldBox(buildEditableField('Address', address, 'address', (val) => address = val)),

              const Divider(height: 32),

              TextButton(
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Password Change'),
                      content: const Text('Are you sure you want to change your password?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                          child: const Text('Yes', style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                    );
                  }
                },
                child: const Text(
                  "Change Password",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),


              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
                child: const Text("Apply Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              SizedBox(height: 60,)
            ],
          ),
        ),

      ),
    );
  }
}
