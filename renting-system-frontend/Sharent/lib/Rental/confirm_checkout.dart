import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharent/Rental/terms_and_conditions.dart';
import 'package:another_flushbar/flushbar.dart';

class ConfirmCheckoutSheet extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String userId;
  final Function(DateTime, DateTime) onConfirm;

  const ConfirmCheckoutSheet({
    required this.items,
    required this.userId,
    required this.onConfirm,
    super.key,
  });

  @override
  State<ConfirmCheckoutSheet> createState() => _ConfirmCheckoutSheetState();
}

class _ConfirmCheckoutSheetState extends State<ConfirmCheckoutSheet> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? now.add(const Duration(days: 1))
        : (startDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 2)));

    final firstDate = isStart
        ? now.add(const Duration(days: 1))
        : (startDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 2)));

    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.deepPurple,
          colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
        ),
        child: child!,
      ),
    );

    if (newDate != null) {
      setState(() {
        if (isStart) {
          startDate = newDate;
          if (endDate != null && !endDate!.isAfter(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = newDate;
        }
      });
    }
  }

  int calculateNumberOfDays() {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays;
  }

  double calculateTotalRent() {
    final days = calculateNumberOfDays();
    if (days <= 0) return 0;

    double total = 0;
    for (var item in widget.items) {
      final rent = (item['rentPerDay'] ?? 0).toDouble();
      final qty = (item['quantity'] ?? 1);
      total += rent * qty * days;
    }
    return total;
  }

  double calculateSecurityDeposit() {
    double totalRent = calculateTotalRent();
    return totalRent * 0.3;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    // for (var item in widget.items) {
    //   print('Confirm Page - Product ID: ${item['productId']}, Name: ${item['name']}');
    // }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Rent Duration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),

            // Start Date
            _dateRow(
              label: 'Start Date',
              value: startDate != null ? dateFormat.format(startDate!) : 'Tap to select',
              onTap: () => pickDate(context, true),
            ),
            const SizedBox(height: 16),

            // End Date
            _dateRow(
              label: 'End Date',
              value: endDate != null ? dateFormat.format(endDate!) : 'Tap to select',
              onTap: () => pickDate(context, false),
            ),

            const SizedBox(height: 10),

            if (startDate != null && endDate != null)
              Text(
                "Total Days: ${calculateNumberOfDays()}",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),

            const SizedBox(height: 24),

            // List of items with quantity and rent
            Text(
              "Items Selected:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.items.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 10, thickness: 0.5, color: Colors.grey),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final itemName = item['name'] ?? 'Item';
                  final qty = item['quantity'] ?? 1;
                  final rentPerDay = item['rentPerDay'] ?? 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart_checkout, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: $qty',
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'NPR ${qty * rentPerDay} / day',
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            if (startDate != null && endDate != null)
              Text(
                "Total Rent: Rs. ${calculateTotalRent().toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.deepPurple,
                ),
              ),

            const SizedBox(height: 20),

            // Proceed Button
            ElevatedButton.icon(
              onPressed: () {
                if (startDate == null || endDate == null) {
                  Flushbar(
                    message: 'Please select both dates',
                    duration: const Duration(seconds: 3),
                    flushbarPosition: FlushbarPosition.TOP,
                    margin: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: Colors.purple.shade400,
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                  ).show(context);
                } else if (!endDate!.isAfter(startDate!)) {
                  Flushbar(
                    message: 'Return date must be after start date',
                    duration: const Duration(seconds: 3),
                    flushbarPosition: FlushbarPosition.TOP,
                    margin: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: Colors.purple.shade400,
                    icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
                  ).show(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TermsAndConditionsPage(
                        items: widget.items,
                        startDate: startDate!,
                        endDate: endDate!,
                        totalRent: calculateTotalRent(),
                        securityDeposit: calculateSecurityDeposit(),
                        userId: widget.userId,
                        onConfirmed: () {
                          widget.onConfirm(startDate!, endDate!);
                        },
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Proceed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                )),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 15, color: Colors.deepPurple)),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 18, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}
