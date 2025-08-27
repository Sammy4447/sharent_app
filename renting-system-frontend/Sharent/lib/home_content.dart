import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sharent/Home_Page/build_offer_card.dart';
import 'package:sharent/Home_Page/category_home.dart';
import 'package:sharent/profile_page.dart';
import 'package:sharent/Login_SignUp/user_preferences.dart';
import 'package:sharent/Home_Page/most_rented.dart';
import 'package:sharent/Home_Page/new_products.dart';
import 'package:sharent/Home_Page/explore.dart';
import 'package:sharent/Home_Page/search_results.dart';
import 'package:sharent/Login_SignUp/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final TextEditingController _searchController = TextEditingController();
List<dynamic> searchResults = [];
bool isLoading = false;
bool hasSearched = false;

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text;
      setState(() {
        hasSearched = query.isNotEmpty;
      });
      _searchProducts(name: query);
    });
  }

  Future<void> _searchProducts({String? name}) async {
    setState(() {
      isLoading = true;
      searchResults = [];
    });

    try {
      final uri = Uri.http('10.0.2.2:5000', '/api/search', {
        if (name != null && name.isNotEmpty) 'name': name,
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          searchResults = data;
        });
      } else {
        print("Error: \${response.statusCode}");
      }
    } catch (e) {
      print("Exception: \$e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    await _searchProducts(
      name: hasSearched ? _searchController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF81D4FA), Color(0xFF9575CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', height: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search products...',
                          icon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final token = await UserPreferences.getUserToken();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => token != null && token.isNotEmpty
                              ? const ProfilePage()
                              : const LoginPage(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (hasSearched)
                        searchResults.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "No results found.",
                              style: TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                        )
                            : SearchResults()
                      else
                        DefaultSections(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget DefaultSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Offers
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              OfferCard(text: "Enjoy 25% off your first rental"),
              OfferCard(text: "Refer & Earn 50 points"),
              OfferCard(text: "Festive Combo Offers 🎉"),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(title: "Categories"),
        const SizedBox(height: 10),
        const CategoryHome(),
        const SizedBox(height: 20),
        SectionHeader(title: "Most Rented"),
        const SizedBox(height: 10),
        const MostRented(),
        const SizedBox(height: 20),
        SectionHeader(title: "New Products"),
        const SizedBox(height: 10),
        const NewProducts(),
        const SizedBox(height: 20),
        SectionHeader(title: "Explore"),
        const SizedBox(height: 10),
        const ExploreSection(),
      ],
    );
  }

  Widget SectionHeader({required String title}) {
    return Row(
      children: [
        Container(width: 6, height: 20, color: Colors.red),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
