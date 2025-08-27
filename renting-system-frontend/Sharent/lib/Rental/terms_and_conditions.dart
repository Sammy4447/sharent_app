import 'package:flutter/material.dart';
import 'package:sharent/Rental/payment_option.dart';

class TermsAndConditionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRent;
  final double securityDeposit;
  final String userId;
  final VoidCallback onConfirmed;

  const TermsAndConditionsPage({
    super.key,
    required this.items,
    required this.startDate,
    required this.endDate,
    required this.totalRent,
    required this.securityDeposit,
    required this.userId,
    required this.onConfirmed,
  });

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    // for (var item in widget.items) {
    //   print('Confirm Page - Product ID: ${item['productId']}, Name: ${item['name']}');
    // }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB39DDB), Color(0xFF9575CD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEE5FF), Color(0xFFE1D5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please read the terms carefully:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      '''
• You are responsible for the rented items during the rental period.

• Late returns may incur additional charges.

• Damaged or lost items must be compensated by the renter.

• Always inspect item condition upon delivery.

• Items must be returned clean and in working condition.

• Rental terms may vary by product.
                      ''',
                      style: TextStyle(
                        fontSize: 15.5,
                        color: Colors.grey.shade900,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: isAgreed,
                      activeColor: Colors.deepPurple,
                      onChanged: (value) {
                        setState(() {
                          isAgreed = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "I agree to the Terms and Conditions.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isAgreed
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentOptionsPage(
                            items: widget.items,
                            startDate: widget.startDate,
                            endDate: widget.endDate,
                            totalRent: widget.totalRent,
                            securityDeposit: widget.securityDeposit,
                            userId: widget.userId,
                            onPaymentConfirmed: () {
                              widget.onConfirmed();
                              Navigator.pop(context); // Close Payment Page
                              Navigator.pop(context); // Close Terms Page
                            },
                          ),
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      disabledBackgroundColor:
                      Colors.deepPurple.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Continue"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
