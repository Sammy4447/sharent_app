import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:another_flushbar/flushbar.dart';


void showAddToCartBottomSheet({
  required BuildContext context,
  required String productId,
  required String productName,
  required String imageUrl,
  required int availableQuantity,
  required String? userId,
}) {
  int selectedQuantity = 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Available: $availableQuantity",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text("Quantity", style: TextStyle(fontSize: 20)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: selectedQuantity > 1
                              ? () => setState(() => selectedQuantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$selectedQuantity', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: selectedQuantity < availableQuantity
                              ? () => setState(() => selectedQuantity++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Are you sure to proceed?",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        if (userId == null) {
                          Flushbar(
                            message: "Please log in to add to cart.",
                            duration: const Duration(seconds: 3),
                            flushbarPosition: FlushbarPosition.TOP,
                            margin: const EdgeInsets.all(16),
                            borderRadius: BorderRadius.circular(12),
                            backgroundColor: Colors.purple.shade400,
                            icon: const Icon(Icons.info_outline, color: Colors.white),
                          ).show(context);

                          return;
                        }

                        try {
                          final token = await UserPreferences.getUserToken();

                          final response = await http.post(
                            Uri.parse('http://10.0.2.2:5000/api/cart/add'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: json.encode({
                              'productId': productId,
                              'quantity': selectedQuantity,
                            }),
                          );
                          print('Status Code: ${response.statusCode}');
                          print('Response Body: ${response.body}');

                          if (response.statusCode == 200) {
                            Flushbar(
                              message: "Added to cart successfully!",
                              duration: const Duration(seconds: 3),
                              flushbarPosition: FlushbarPosition.TOP,
                              margin: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(12),
                              backgroundColor: Colors.green.shade600,
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                            ).show(context);

                          } else {
                            Flushbar(
                              message: "Failed to add to cart.",
                              duration: const Duration(seconds: 3),
                              flushbarPosition: FlushbarPosition.TOP,
                              margin: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(12),
                              backgroundColor: Colors.red.shade500,
                              icon: const Icon(Icons.error_outline, color: Colors.white),
                            ).show(context);

                          }
                        } catch (e) {
                          Flushbar(
                            message: "Error: ${e.toString()}",
                            duration: const Duration(seconds: 5),
                            flushbarPosition: FlushbarPosition.TOP,
                            margin: const EdgeInsets.all(16),
                            borderRadius: BorderRadius.circular(12),
                            backgroundColor: Colors.red.shade500,
                            icon: const Icon(Icons.error_outline, color: Colors.white),
                          ).show(context);

                        }
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );
}
