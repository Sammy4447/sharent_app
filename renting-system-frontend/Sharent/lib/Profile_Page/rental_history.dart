import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:sharent/Product/confirm_cart.dart';
import 'package:sharent/Product/product_detail_page.dart';

class RentalHistory extends StatefulWidget {
  const RentalHistory({super.key});

  @override
  State<RentalHistory> createState() => _RentalHistoryState();
}

class _RentalHistoryState extends State<RentalHistory> {
  List<dynamic> rentalHistory = [];
  List<dynamic> filteredHistory = [];
  bool isLoading = true;
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchRentalHistory();
  }

  Future<void> _fetchRentalHistory() async {
    final token = await UserPreferences.getUserToken();
    final uri = Uri.parse('http://10.0.2.2:5000/api/rentals/my-rentals');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rentalHistory = data;
          filteredHistory = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load rental history');
      }
    } catch (e) {
      print('Error fetching rental history: $e');
      setState(() => isLoading = false);
    }
  }

  void filterHistory() {
    setState(() {
      filteredHistory = rentalHistory.where((item) {
        final product = item['productId'];
        final name = product['name'].toString().toLowerCase();
        final matchesSearch = name.contains(searchQuery.toLowerCase());

        final rentalStart = DateTime.tryParse(item['startDate'] ?? '') ?? DateTime.now();
        final rentalEnd = DateTime.tryParse(item['endDate'] ?? '') ?? DateTime.now();

        // If no filter dates selected, accept all
        if (startDate == null && endDate == null) {
          return matchesSearch;
        }

        // If only startDate selected, rental must end on or after startDate filter
        if (startDate != null && endDate == null) {
          return matchesSearch && rentalEnd.isAfter(startDate!.subtract(const Duration(days: 1)));
        }

        // If only endDate selected, rental must start on or before endDate filter
        if (startDate == null && endDate != null) {
          return matchesSearch && rentalStart.isBefore(endDate!.add(const Duration(days: 1)));
        }

        // If both dates selected, check if rental overlaps with filter range
        final overlap = rentalStart.isBefore(endDate!.add(const Duration(days: 1))) &&
            rentalEnd.isAfter(startDate!.subtract(const Duration(days: 1)));

        return matchesSearch && overlap;
      }).toList();
    });
  }

  String formatDate(String date) {
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        filterHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rental History", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFF9575CD)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: pickDateRange,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFADD8E6), Color(0xFFDDA0DD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search rentals...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    filterHistory();
                  });
                },
              ),
            ),

            // Show selected date range with clear filter button
            if (startDate != null && endDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    border: Border.all(color: Colors.deepPurple.shade200),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Filter: ${DateFormat('MMM d, yyyy').format(startDate!)} - ${DateFormat('MMM d, yyyy').format(endDate!)}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            startDate = null;
                            endDate = null;
                            filterHistory();
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                )

              ),

            Expanded(
              child: filteredHistory.isEmpty
                  ? const Center(
                  child: Text('No rental history found.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  final item = filteredHistory[index];
                  final product = item['productId'];
                  final imageUrl =
                      'http://10.0.2.2:5000/${product['image'].replaceAll("\\", "/")}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 60),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'Unknown',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(child: Text("Quantity: ${item['quantity']}")),
                                  Text("Rent: NPR${item['totalRent']} per day",
                                      style: const TextStyle(fontWeight: FontWeight.w500))
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(child: Text("From: ${formatDate(item['startDate'])}")),
                                  Text("Deposit: ₹${item['securityDeposit']}"),
                                ],
                              ),
                              Text("To: ${formatDate(item['endDate'])}"),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductDetailPage(product: item['productId']),
                                        ),
                                      );
                                    },
                                    child: const Text("View Product", style: TextStyle(decoration: TextDecoration.underline),),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final product = item['productId'];

                                      showAddToCartBottomSheet(
                                        context: context,
                                        productId: product['_id'],
                                        productName: product['name'] ?? 'Unknown',
                                        imageUrl:
                                        'http://10.0.2.2:5000/${product['image']?.replaceAll("\\", "/") ?? ''}',
                                        availableQuantity:
                                        product['quantityAvailable'] ?? 0,
                                        userId: await UserPreferences.getUserId(),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9575CD),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Re-rent",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
