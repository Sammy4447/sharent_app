import 'package:flutter/material.dart';
import 'package:sharent/cart_page.dart';
import 'package:sharent/Product/confirm_cart.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';


class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    loadCartCount();
  }

  Future<void> loadCartCount() async {
    final count = await getCartItemCount();
    setState(() {
      cartCount = count;
    });
  }

  Future<int> getCartItemCount() async {
    final userId = await UserPreferences.getUserId();
    final token = await UserPreferences.getUserToken();

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/cart/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>;
      return items.length; // Count of distinct product entries
    }
    return 0;
  }


  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFF9575CD)),
        ),
        title: Text(
          product['category'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 2, end: 4),
            showBadge: cartCount > 0,
            badgeContent: Text(
              '$cartCount',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ).then((_) => loadCartCount()); // Reload after coming back
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81D4FA), Color(0xFF9575CD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: NetworkImage(
                        'http://10.0.2.2:5000/${product['image'].replaceAll("\\", "/")}'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "NPR. ${product['rentPerDay']}/day",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "- - - - - - - - - - - - - - - - - - - - - - - - - -",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "In Stock: ${product['stock']}  |  Available: ${product['quantityAvailable']}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rented: ${product['bookingsCount']} times",
                      // "Rented: ${product['bookingsCount']} times   |  ⭐ ${product['averageRating']}   |   (${product['totalReviews']} reviews)",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Description:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                      product['description'] ?? 'No description available.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String? userId = await UserPreferences.getUserId();

          if (userId == null) {
            Flushbar(
              message: 'Please log in to add items to your cart.',
              duration: const Duration(seconds: 3),
              flushbarPosition: FlushbarPosition.TOP,
              margin: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(12),
              backgroundColor: Colors.red.shade600,
              icon: const Icon(Icons.error_outline, color: Colors.white),
            ).show(context);

            return;
          }

          showAddToCartBottomSheet(
            context: context,
            productId: product['_id'],
            productName: product['name'],
            imageUrl:
            'http://10.0.2.2:5000/${product['image'].replaceAll("\\", "/")}',
            availableQuantity: product['quantityAvailable'],
            userId: userId,
          );
        },
        backgroundColor: Colors.white70,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add to Cart'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
