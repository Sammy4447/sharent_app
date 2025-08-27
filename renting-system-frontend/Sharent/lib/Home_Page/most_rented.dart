import 'package:flutter/material.dart';
import 'package:sharent/Product/product_detail_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharent/Product/confirm_cart.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:another_flushbar/flushbar.dart';

class MostRented extends StatefulWidget {
  const MostRented({super.key});

  @override
  State<MostRented> createState() => _MostRentedState();
}

class _MostRentedState extends State<MostRented> {
  List<dynamic> mostRentedProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMostRentedProducts();
  }

  Future<void> _fetchMostRentedProducts() async {
    try {
      final uri = Uri.parse('http://10.0.2.2:5000/api/products/most-booked');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          mostRentedProducts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load most rented products');
      }
    } catch (e) {
      print('Error fetching most rented products: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mostRentedProducts.isEmpty) {
      return const Center(child: Text('No most rented products found'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 268,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mostRentedProducts.length,
            itemBuilder: (context, index) {
              final item = mostRentedProducts[index];
              final rawPath = item['image'] ?? '';
              final fixedPath = rawPath.replaceAll(r'\', '/');
              final imageUrl = 'http://10.0.2.2:5000/$fixedPath';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: item),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 60),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "NPR. ${item['rentPerDay']}/day",
                                style: const TextStyle(color: Colors.green),
                              ),
                              Text(
                                "Available: ${item['quantityAvailable']}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Booked: ${item['bookingsCount'] ?? 0} times",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              ElevatedButton(
                                onPressed: () async {
                                  String? userId =
                                  await UserPreferences.getUserId();

                                  if (userId == null) {
                                    Flushbar(
                                      message: 'Please log in to add items to your cart.',
                                      duration: const Duration(seconds: 3),
                                      flushbarPosition: FlushbarPosition.TOP,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: BorderRadius.circular(12),
                                      backgroundColor: Colors.purple,
                                      icon: const Icon(Icons.info_outline, color: Colors.white),
                                    ).show(context);

                                    return;
                                  }

                                  showAddToCartBottomSheet(
                                    context: context,
                                    productId: item['_id'],
                                    productName: item['name'],
                                    imageUrl:
                                    'http://10.0.2.2:5000/${item['image'].replaceAll("\\", "/")}',
                                    availableQuantity: item['quantityAvailable'],
                                    userId: userId,
                                  );
                                },
                                child: const Text('Add To Cart', style: TextStyle(color: Colors.white70),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size.fromHeight(30),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
