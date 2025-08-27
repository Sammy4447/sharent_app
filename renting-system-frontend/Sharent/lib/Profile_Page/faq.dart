import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'What is Sharent?',
      'answer':
      'Sharent is a rental platform where users can borrow or lend items like clothes, electronics, tools, and more.'
    },
    {
      'question': 'How does Sharent work?',
      'answer':
      'You browse products, select rental dates, add items to cart, and complete payment. Return items on time to get your deposit back.'
    },
    {
      'question': 'Do I need an account to rent items?',
      'answer': 'Yes. You must create and log into an account to rent or list items.'
    },
    {
      'question': 'How can I edit my profile?',
      'answer':
      'Go to the Profile tab and tap "Edit Profile" to update your name, phone, address, or password.'
    },
    {
      'question': 'What if I forget my password?',
      'answer':
      'If you’ve forgotten your password, please contact our support team directly through WhatsApp or email. '
      'We currently do not have an automated password reset system. Our team will verify your identity and help you regain access to your account.'
      '\nContacts are provided in Contact Us Page inside Help and Support'
    },
    {
      'question': 'How do I edit/delete my data after placing a rental-order?',
      'answer':
      'To update your delivery data after placing a rental, please contact our support team as soon as possible within 6 hours of placing the rental order. Once the order is in transit, changes may not be possible.'
    },
    {
      'question': 'How is the total rent calculated?',
      'answer':
      'Total = (Rent per day × Number of days) + Security Deposit. Refunds apply after proper return.'
    },
    {
      'question': 'How do I contact support?',
      'answer':
      'Go to Help & Support and choose Contact Us to reach our customer service team.'
    },

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("FAQs", style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return Card(
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      children: [
                        Container(
                          color: Colors.white10,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10),
                            child: Text(
                              faq['answer']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
