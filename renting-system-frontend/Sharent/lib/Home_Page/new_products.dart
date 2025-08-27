import 'package:flutter/material.dart';
import 'package:sharent/Product/product_detail_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharent/Product/confirm_cart.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:another_flushbar/flushbar.dart';


class NewProducts extends StatefulWidget {
  const NewProducts({super.key});

  @override
  State<NewProducts> createState() => _NewProductsState();
}

class _NewProductsState extends State<NewProducts> {
  List<dynamic> newProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNewProducts();
  }

  Future<void> _fetchNewProducts() async {
    try {
      final uri = Uri.parse('http://10.0.2.2:5000/api/products/newly-added');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          newProducts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load new products');
      }
    } catch (e) {
      print('Error fetching new products: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (newProducts.isEmpty) {
      return const Center(child: Text('No new products found'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 255,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: newProducts.length,
            itemBuilder: (context, index) {
              final item = newProducts[index];
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
                        // Image
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
                        // Name & Price
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
                                "Available: ${item['quantityAvailable']}",                                      style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  String? userId = await UserPreferences.getUserId();

                                  if (userId == null) {
                                    // Show message or redirect to login
                                    Flushbar(
                                      message: 'Please log in to add items to your cart.',
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: Colors.redAccent,
                                      flushbarPosition: FlushbarPosition.TOP,
                                      icon: const Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                      ),
                                      margin: const EdgeInsets.all(8),
                                      borderRadius: BorderRadius.circular(8),
                                    ).show(context);

                                    return;
                                  }

                                  showAddToCartBottomSheet(
                                    context: context,
                                    productId: item['_id'],
                                    productName: item['name'],
                                    imageUrl: 'http://10.0.2.2:5000/${item['image'].replaceAll("\\", "/")}',
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
