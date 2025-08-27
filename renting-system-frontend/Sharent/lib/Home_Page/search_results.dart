import 'package:flutter/material.dart';
import 'package:sharent/home_content.dart';
import 'package:sharent/Product/product_detail_page.dart';
import 'package:sharent/Product/confirm_cart.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({super.key});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        final rawImagePath = item['image'] ?? '';
        final fixedPath = rawImagePath.replaceAll(r'\', '/');
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
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.black,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "NPR ${item['rentPerDay'] ?? 'N/A'}/day",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          String? userId = await UserPreferences.getUserId();

                          if (userId == null) {
                            // Show message or redirect to login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please log in to add items to your cart.')),
                            );
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
                          backgroundColor: Colors.purple[700],
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
        );
      },
    );
  }
}
