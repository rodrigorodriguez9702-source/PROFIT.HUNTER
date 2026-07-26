import 'package:flutter/material.dart';

void main() {
  runApp(const ProfitHunterApp());
}

class ProfitHunterApp extends StatelessWidget {
  const ProfitHunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profit Hunter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  static const pages = [
    DashboardPage(),
    HuntsPage(),
    DealsPage(),
    FlipsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.track_changes), label: 'Hunts'),
          NavigationDestination(icon: Icon(Icons.local_fire_department), label: 'Deals'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Flips'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          '🔥 PROFIT HUNTER',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 6),
        Text('Casual Hunter'),
        SizedBox(height: 24),
        _StatCard(title: 'Potential Profit', value: '\$365'),
        _StatCard(title: 'Active Hunts', value: '0 / 2'),
        _StatCard(title: 'Deals Found', value: '3'),
        SizedBox(height: 20),
        Text(
          'Top Opportunities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        _DealCard(
          title: 'Milwaukee M18 Fuel Kit',
          buy: 120,
          resale: 260,
          score: 94,
        ),
        _DealCard(
          title: 'DeWalt 20V Tool Bundle',
          buy: 100,
          resale: 240,
          score: 95,
        ),
      ],
    );
  }
}

class HuntsPage extends StatelessWidget {
  const HuntsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: '🎯 My Hunts',
      body: 'Create up to 2 saved hunts as a Casual Hunter.',
    );
  }
}

class DealsPage extends StatelessWidget {
  const DealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          '🔥 Deal Feed',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 16),
        _DealCard(
          title: 'Milwaukee M18 Fuel Kit',
          buy: 120,
          resale: 260,
          score: 94,
        ),
        _DealCard(
          title: 'Solid Wood Dresser',
          buy: 50,
          resale: 225,
          score: 91,
        ),
      ],
    );
  }
}

class FlipsPage extends StatelessWidget {
  const FlipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: '📦 My Flips',
      body: 'Track purchases, sale prices, expenses, and realized profit.',
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: '⚙️ Settings',
      body: 'Plan: Casual Hunter\nSaved Hunts: 2 maximum\nAvid Hunter: unlimited hunts and all premium features.',
    );
  }
}

class _SimplePage extends StatelessWidget {
  const _SimplePage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Text(body, style: const TextStyle(fontSize: 17)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.title,
    required this.buy,
    required this.resale,
    required this.score,
  });

  final String title;
  final double buy;
  final double resale;
  final int score;

  @override
  Widget build(BuildContext context) {
    final profit = resale - buy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Buy: \$${buy.toStringAsFixed(0)}'),
            Text('Estimated resale: \$${resale.toStringAsFixed(0)}'),
            Text('Estimated profit: +\$${profit.toStringAsFixed(0)}'),
            Text('Hunter Score: $score/100'),
          ],
        ),
      ),
    );
  }
}
