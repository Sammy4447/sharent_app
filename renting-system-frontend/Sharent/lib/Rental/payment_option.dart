import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharent/Login_SignUp/user_preferences.dart';

class PaymentOptionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRent;
  final double securityDeposit;
  final String userId;
  final VoidCallback onPaymentConfirmed;

  const PaymentOptionsPage({
    super.key,
    required this.items,
    required this.startDate,
    required this.endDate,
    required this.totalRent,
    required this.securityDeposit,
    required this.userId,
    required this.onPaymentConfirmed,
  });

  @override
  State<PaymentOptionsPage> createState() => _PaymentOptionsPageState();
}

class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
  String? selectedPaymentMethod;
  final List<String> paymentMethods = ['Esewa', 'Khalti', 'Cash on Delivery'];
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // For locations
  List<dynamic> locations = [];
  String? selectedDistrict;
  String? selectedCity;
  List<String> citiesForSelectedDistrict = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    final token = await UserPreferences.getUserToken();
    print("Token: $token");
    if (token == null) {
      print("No token available");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/locations'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Locations fetch status: ${response.statusCode}");
      print("Locations fetch body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Locations fetched: ${data['locations']}");
        setState(() {
          locations = data['locations'] ?? [];
        });
      } else {
        print("Failed to fetch locations");
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  void _onDistrictChanged(String? district) {
    if (district == null) return;
    setState(() {
      selectedDistrict = district;
      selectedCity = null;
      final loc = locations.firstWhere(
            (loc) => loc['district'] == district,
        orElse: () => null,
      );
      if (loc != null && loc['cities'] is List<dynamic>) {
        citiesForSelectedDistrict = List<String>.from(loc['cities']);
      } else {
        citiesForSelectedDistrict = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalDays = widget.endDate.difference(widget.startDate).inDays;
    final double grandTotal = widget.totalRent + widget.securityDeposit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Your Order'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF2ECFF),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Order Summary"),
              ...widget.items.map((item) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                      "Qty: ${item['quantity']} • NPR ${item['rentPerDay']} / day"),
                ),
              )),
              const SizedBox(height: 10),
              _summaryRow("Rent Duration:", "$totalDays days"),
              _summaryRow(
                  "Total Rent:", "NPR ${widget.totalRent.toStringAsFixed(2)}"),
              _summaryRow("Security Deposit:",
                  "NPR ${widget.securityDeposit.toStringAsFixed(2)}"),
              _summaryRow("Grand Total:", "NPR. ${grandTotal.toStringAsFixed(2)}",
                  bold: true),
              const SizedBox(height: 25),
              _sectionTitle("Delivery Information"),
              const SizedBox(height: 8),
              _inputField("Phone Number", phoneController, TextInputType.phone),
              const SizedBox(height: 12),
              _inputField("Delivery Address", addressController,
                  TextInputType.multiline,
                  maxLines: 3),
              const SizedBox(height: 16),

              // District Dropdown
              Text(
                'Select District',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple.shade700),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedDistrict,
                items: locations
                    .map((loc) => DropdownMenuItem<String>(
                  value: loc['district'],
                  child: Text(loc['district']),
                ))
                    .toList(),
                onChanged: _onDistrictChanged,
                decoration: InputDecoration(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a district';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // City Dropdown
              Text(
                'Select City',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple.shade700),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedCity,
                items: citiesForSelectedDistrict
                    .map((city) => DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                ))
                    .toList(),
                onChanged: (city) {
                  setState(() {
                    selectedCity = city;
                  });
                },
                decoration: InputDecoration(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a city';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),
              _sectionTitle("Payment Method"),
              ...paymentMethods.map((method) {
                final isCOD = method == 'Cash on Delivery';
                return IgnorePointer(
                  ignoring: !isCOD,
                  child: RadioListTile<String>(
                    value: method,
                    groupValue: selectedPaymentMethod,
                    title: Text(
                      method,
                      style: TextStyle(
                        color: isCOD ? Colors.black : Colors.grey,
                      ),
                    ),
                    activeColor: isCOD ? Colors.deepPurple : Colors.grey,
                    onChanged: isCOD
                        ? (value) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    }
                        : null,
                  ),
                );
              }).toList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 36),
        child: ElevatedButton.icon(
          onPressed: _handleConfirm,
          icon: const Icon(Icons.payment),
          label: const Text('Confirm Payment & Place Order'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: bold ? Colors.deepPurple : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      TextInputType type,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    if (selectedPaymentMethod == null ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedDistrict == null ||
        selectedCity == null) {
      Flushbar(
        message: 'Please fill all fields and select a payment method.',
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.info_outline, color: Colors.white),
      ).show(context);
      return;
    }
    final token = await UserPreferences.getUserToken();

    final order = {
      "startDate": widget.startDate.toIso8601String(),
      "endDate": widget.endDate.toIso8601String(),
      "termsAgreed": true,
      "phone": phoneController.text,
      "address": addressController.text,
      "district": selectedDistrict,
      "city": selectedCity,
      "products": widget.items.map((item) {
        print("Sending productId: ${item['productId']}, quantity: ${item['quantity']}");
        return {
          "productId": item["productId"],
          "quantity": item["quantity"],
        };
      }).toList(),
    };

    try {
      print("Order payload: ${jsonEncode(order)}");
      print("Full items list: ${widget.items}");

      final res = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/rentals/rent"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(order),
      );

      if (res.statusCode == 201) {
        widget.onPaymentConfirmed();

        if (context.mounted) {
          Flushbar(
            message: 'Order placed successfully via $selectedPaymentMethod!',
            duration: const Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(12),
            backgroundColor: Colors.green.shade600,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          ).show(context);

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.popUntil(context, (route) => route.isFirst);
          });
        }
      } else {
        final responseBody = jsonDecode(res.body);
        final errorMessage = responseBody['message'] ?? 'Unknown error';

        Flushbar(
          message: errorMessage,
          duration: const Duration(seconds: 4),
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.red.shade600,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        ).show(context);


      }
    } catch (e) {
      if (context.mounted) {
        Flushbar(
          message: 'Error placing order: $e',
          duration: const Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.red.shade500,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        ).show(context);
      }
    }
  }
}
