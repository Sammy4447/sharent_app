import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Color(0xFF9575CD)),
          ),
          title: const Text("About Us", style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "About Sharent"),
              Tab(text: "Our Team"),
            ],
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
          child: const SafeArea(
            child: TabBarView(
              children: [
                _AboutSharentTab(),
                _DevelopersTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutSharentTab extends StatelessWidget {
  const _AboutSharentTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          SizedBox(height: 20),
          Text(
            "Welcome to Sharent!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            "Sharent is a next-gen peer-to-peer rental platform designed to make renting clothes, gadgets, books, tools, and more as simple as shopping online. "
                "\n\nWhether you're looking to borrow a DSLR for a trip, rent a traditional dress for a festival, Sharent helps connect us with the people who need things — safely, easily, and affordably."
                "\n\nWith secure user accounts, cart and checkout system, rental history tracking, and smart filters, our app is built to deliver a premium rental experience with maximum transparency. Every product listing comes with clear pricing, rental durations, deposit information, and an easy-to-use rental process."
                "\n\nJoin our mission to reduce consumer waste, promote sharing, and make ownership optional. Together, let's build a smarter and more sustainable future.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 30),
          Text(
            " Our Mission:\nEmpowering smart sharing through rentals and reducing global waste, one item at a time.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 30),

          Icon(Icons.recycling, size: 64, color: Colors.green),
          SizedBox(height: 10),
          Text(
            "Reduce. Reuse. Rent.",
            style: TextStyle(
              fontSize: 18,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _DevelopersTab extends StatelessWidget {
  const _DevelopersTab();

  final List<Map<String, String>> developers = const [

    {
      "name": "Sameer Bhatt",
      "role": "System Analyst",
      "email": "sameer@example.com",
      "whatsapp": "+9779800000004",
      "image": "assets/devs/sameer.png",
    },
    {
      "name": "Prabha Joshi",
      "role": "UI/UX Designer",
      "email": "prabha@example.com",
      "whatsapp": "+9779800000003",
      "image": "assets/devs/prabha.jpg",
    },
    {
      "name": "Menuka Paneru",
      "role": "Backend Developer",
      "email": "menuka@example.com",
      "whatsapp": "+9779800000002",
      "image": "assets/devs/menuka.jpg",
    },
    {
      "name": "Ravi Bhatt",
      "role": "Frontend Developer",
      "email": "ravi@example.com",
      "whatsapp": "+9779800000001",
      "image": "assets/devs/ravi.jpg" ,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      itemCount: developers.length,
      itemBuilder: (context, index) {
        final dev = developers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 90,
                backgroundImage: AssetImage(dev["image"]!),
              ),
              const SizedBox(height: 12),
              Text(
                dev["name"]!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                dev["role"]!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email, color: Colors.black, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    dev["email"]!,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    dev["whatsapp"]!,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
