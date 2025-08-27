import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFF9575CD)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFADD8E6), Color(0xFFDDA0DD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SectionTitle("1. Introduction"),
                        SectionText(
                          "Sharent values your privacy. This policy explains how we collect, use, and protect your personal data while using our services.",
                        ),
                        SectionTitle("2. Data We Collect"),
                        SectionText(
                          "- Name, email, phone number\n"
                              "- Address and delivery information\n"
                              "- Rental history and cart items\n"
                              "- Payment method (not stored directly)\n"
                              "- Device and app usage data\n"
                              "- Location (if you permit it)",
                        ),
                        SectionTitle("3. How We Use Your Data"),
                        SectionText(
                          "- To create and manage your account\n"
                              "- To process rentals and deliveries\n"
                              "- To improve app experience and performance\n"
                              "- To provide customer support\n"
                              "- For marketing (with your consent)",
                        ),
                        SectionTitle("4. Sharing of Your Data"),
                        SectionText(
                          "We never sell your data. We may share your data with:\n"
                              "- Delivery partners for fulfilling orders\n"
                              "- Legal authorities when required\n"
                              "- Third-party analytics tools (anonymized)",
                        ),
                        SectionTitle("5. Data Storage & Security"),
                        SectionText(
                          "- We use secure servers and encryption methods\n"
                              "- Only authorized staff can access your data\n"
                              "- We retain data only as long as necessary",
                        ),
                        SectionTitle("6. Your Rights"),
                        SectionText(
                          "- Access, update, or delete your profile info\n"
                              "- Request data deletion\n"
                              "- Opt out of marketing emails\n"
                              "- Request a copy of your stored data",
                        ),
                        SectionTitle("7. Policy Updates"),
                        SectionText(
                          "We may update this policy to stay compliant with laws or improve transparency. You will be notified of major changes.",
                        ),

                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Last Updated: August 6, 2025",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}

class SectionText extends StatelessWidget {
  final String text;
  const SectionText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
    );
  }
}
