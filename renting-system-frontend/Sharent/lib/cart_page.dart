import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharent/Product/confirm_delete_cart.dart';
import 'package:sharent/Product/product_detail_page.dart';
import 'package:sharent/Rental/confirm_checkout.dart';
import 'package:sharent/Rental/terms_and_conditions.dart';
import 'package:another_flushbar/flushbar.dart';



class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  Set<String> selectedProductIds = {};
  bool isLoading = true;
  String? userId;

  Map<String, int> currentQuantities = {};
  Map<String, int> maxAllowedQuantities = {};

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    userId = await UserPreferences.getUserId();
    if (userId == null) {
      // Handle no user id: show login or empty cart
      setState(() {
        cartItems = [];
        isLoading = false;
      });
      return;
    }
    final token = await UserPreferences.getUserToken();

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/cart/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final fetchedItems = decoded['items'];

      for (var item in fetchedItems) {
        final productId = item['productId']['_id'];
        final quantity = item['quantity'];

        currentQuantities[productId] = quantity;

        final availableQty = item['productId']['quantityAvailable'] ?? 1;
        maxAllowedQuantities[productId] = availableQty;
        await saveMaxQuantity(productId, availableQty);

      }

      setState(() {
        cartItems = fetchedItems;
        isLoading = false;
      });
    } else {
      setState(() {
        cartItems = [];
        isLoading = false;
      });
      debugPrint("Failed to load cart: ${response.body}");
    }
  }

  void increaseQuantity(String productId) {
    final currentQty = currentQuantities[productId] ?? 1;
    final maxQty = maxAllowedQuantities[productId] ?? 1;

    if (currentQty < maxQty) {
      setState(() {
        currentQuantities[productId] = currentQty + 1;
      });
      updateQuantity(productId, currentQty + 1);
    } else {
      Flushbar(
        message: 'Cannot exceed the selected quantity.',
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      ).show(context);
    }
  }

  void decreaseQuantity(String productId) {
    final currentQty = currentQuantities[productId] ?? 1;
    if (currentQty > 1) {
      setState(() {
        currentQuantities[productId] = currentQty - 1;
      });
      updateQuantity(productId, currentQty - 1);
    }
  }

  Future<void> updateQuantity(String productId, int newQty) async {
    final token = await UserPreferences.getUserToken();
    final response = await http.put(
      Uri.parse('http://10.0.2.2:5000/api/cart/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'productId': productId, 'quantity': newQty}),
    );

    if (response.statusCode == 200) {
      setState(() {
        currentQuantities[productId] = newQty;
      });
    }
  }

  Future<void> deleteSelectedItems() async {
    final token = await UserPreferences.getUserToken();

    for (final id in selectedProductIds) {
      final request = http.Request(
        'DELETE',
        Uri.parse('http://10.0.2.2:5000/api/cart/remove'),
      );

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.body = jsonEncode({'productId': id});
      await request.send();
    }

    selectedProductIds.clear();
    fetchCart();
  }

  double calculateTotalRent() {
    double total = 0;
    for (var item in cartItems) {
      final product = item['productId'];
      final productId = product['_id'];

      if (selectedProductIds.contains(productId)) {
        final rent = product['rentPerDay'] ?? 0;
        final qty = currentQuantities[productId] ?? 1;
        total += rent * qty;
      }
    }
    return total;
  }

  Future<void> saveMaxQuantity(String productId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maxQty_$productId', quantity);
  }

  Future<int?> getSavedMaxQuantity(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('maxQty_$productId');
  }

  void proceedToCheckout() {
    final selectedItems = cartItems.where((item) {
      final productId = item['productId']['_id'];
      return selectedProductIds.contains(productId);

    }).map((item) {
      final product = item['productId'];
      final productId = product['_id'];
      final rent = product['rentPerDay'] ?? 0;
      final qty = currentQuantities[productId] ?? 1;
      return {
        'productId': product['_id'],
        'name': product['name'],
        'rentPerDay': rent,
        'quantity': qty,
      };
    }).toList();

    if (userId == null) {
      // User not logged in or userId not available
      // Show a message or redirect to login
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ConfirmCheckoutSheet(
        items: selectedItems,
        userId: userId!,
        onConfirm: (startDate, endDate) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TermsAndConditionsPage(
                userId: userId!,
                items: selectedItems,
                startDate: startDate,
                endDate: endDate,
                totalRent: calculateTotalRent(),
                securityDeposit: calculateTotalRent() * 0.3,
                onConfirmed: fetchCart,
              ),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFF9575CD)),
        ),
        actions: [
          const Text("All", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          StatefulBuilder(
            builder: (context, setStateInner) => Checkbox(
              value: selectedProductIds.length == cartItems.length && cartItems.isNotEmpty,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedProductIds = {
                      for (var item in cartItems) item['productId']['_id']
                    };
                  } else {
                    selectedProductIds.clear();
                  }
                });
                setStateInner(() {});
              },
              checkColor: Colors.black,
              fillColor: MaterialStateProperty.all<Color>(Colors.white70),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete selected',
            onPressed: selectedProductIds.isEmpty
                ? null
                : () {
              DeleteConfirmationSheet.show(
                context: context,
                onConfirm: () {
                  deleteSelectedItems();
                },
              );
            },
          ),

        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81D4FA), Color(0xFF9575CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cartItems.isEmpty
            ? const Center(
          child: Text(
            "Your cart is empty.",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchCart,
                color: Colors.deepPurple,
                backgroundColor: Colors.white,
                displacement: 40,
                strokeWidth: 3.5,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final product = item['productId'];
                    final productId = product['_id'];
                    final isSelected = selectedProductIds.contains(productId);
                    final currentQty = currentQuantities[productId] ?? 1;
                    final maxQty = maxAllowedQuantities[productId] ?? 1;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gesture area: Left + Middle
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailPage(product: product),
                                  ),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: product['image'] != null
                                          ? Image.network(
                                        "http://10.0.2.2:5000/${product['image']}".replaceAll('\\', '/'),
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Middle: Product Info
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'] ?? 'Unnamed Product',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'NPR ${product['rentPerDay']} per day',
                                          style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Available: ${product['quantityAvailable'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Right: Checkbox + Quantity Selector (non-clickable container)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selectedProductIds.add(productId);
                                    } else {
                                      selectedProductIds.remove(productId);
                                    }
                                  });
                                },
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: currentQty > 1 ? () => decreaseQuantity(productId) : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Text(
                                    '$currentQty',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    onPressed: currentQty < maxQty ? () => increaseQuantity(productId) : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );

                  },
                ),
              ),
            ),


            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, -1),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: NPR ${calculateTotalRent().toStringAsFixed(2)} per day',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: selectedProductIds.isEmpty
                        ? null
                        : () {
                      final selectedItems = cartItems.where((item) {
                        final productId = item['productId']['_id'];
                        return selectedProductIds.contains(productId);
                      }).map((item) {
                        final product = item['productId'];
                        final productId = product['_id'];
                        final rent = product['rentPerDay'] ?? 0;
                        final qty = currentQuantities[productId] ?? 1;
                        final available = product['quantityAvailable'] ?? 0;

                        return {
                          'productId': productId,
                          'name': product['name'],
                          'rentPerDay': rent,
                          'quantity': qty,
                          'available': available,
                        };
                      }).toList();

                      // Validation: check for 0 availability
                      final hasZeroAvailable = selectedItems.any((item) => item['available'] == 0);

                      if (hasZeroAvailable) {
                        Flushbar(
                          message: "Some selected items are out of stock and cannot be checked out.",
                          duration: const Duration(seconds: 3),
                          flushbarPosition: FlushbarPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(12),
                          backgroundColor: Colors.redAccent,
                          icon: const Icon(Icons.error_outline, color: Colors.white),
                        ).show(context);
                        return;
                      }

                      // Validation: check if selected quantity > available quantity
                      final hasQtyExceed = selectedItems.any((item) => item['quantity'] > item['available']);

                      if (hasQtyExceed) {
                        Flushbar(
                          message: "Selected quantity exceeds available stock for some items.",
                          duration: const Duration(seconds: 3),
                          flushbarPosition: FlushbarPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(12),
                          backgroundColor: Colors.redAccent,
                          icon: const Icon(Icons.error_outline, color: Colors.white),
                        ).show(context);
                        return;
                      }

                      // If all validations pass, proceed to show bottom sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => ConfirmCheckoutSheet(
                          items: selectedItems,
                          userId: userId!,
                          onConfirm: (startDate, endDate) {
                            Navigator.pop(context);
                            print("Checkout from $startDate to $endDate");
                            print("Items: $selectedItems");
                          },
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.blueGrey,
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                  )


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
