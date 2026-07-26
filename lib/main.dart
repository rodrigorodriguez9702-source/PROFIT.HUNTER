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
      body: SafeArea(
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes),
            label: 'Hunts',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department),
            label: 'Deals',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: 'Flips',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
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
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text('Casual Hunter'),
        SizedBox(height: 24),

        StatCard(
          title: 'Potential Profit',
          value: '\$365',
        ),
        StatCard(
          title: 'Active Hunts',
          value: '0 / 2',
        ),
        StatCard(
          title: 'Deals Found',
          value: '3',
        ),

        SizedBox(height: 24),

        Text(
          'Top Opportunities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        DealCard(
          title: 'Milwaukee M18 Fuel Kit',
          buyPrice: 120,
          resalePrice: 260,
          hunterScore: 94,
        ),

        DealCard(
          title: 'DeWalt 20V Tool Bundle',
          buyPrice: 100,
          resalePrice: 240,
          hunterScore: 95,
        ),
      ],
    );
  }
}

class HuntsPage extends StatelessWidget {
  const HuntsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: '🎯 My Hunts',
      description:
          'Casual Hunter includes up to 2 saved hunts.\n\n'
          'Upgrade to Avid Hunter for unlimited hunts and all features.',
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
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),

        SizedBox(height: 8),

        Text('AI-ranked sample opportunities'),

        SizedBox(height: 20),

        DealCard(
          title: 'Milwaukee M18 Fuel Kit',
          buyPrice: 120,
          resalePrice: 260,
          hunterScore: 94,
        ),

        DealCard(
          title: 'Solid Wood Dresser',
          buyPrice: 50,
          resalePrice: 225,
          hunterScore: 91,
        ),

        DealCard(
          title: 'DeWalt 20V Tool Bundle',
          buyPrice: 100,
          resalePrice: 240,
          hunterScore: 95,
        ),
      ],
    );
  }
}

class FlipsPage extends StatelessWidget {
  const FlipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: '📦 My Flips',
      description:
          'Track what you paid, expenses, selling price, and your realized profit.',
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: '⚙️ Settings',
      description:
          'Current plan: Casual Hunter\n\n'
          'Saved Hunts: 2 maximum\n\n'
          'Avid Hunter: Unlimited hunts and all premium features.',
    );
  }
}

class SimplePage extends StatelessWidget {
  const SimplePage({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          style: const TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
  });

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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DealCard extends StatelessWidget {
  const DealCard({
    super.key,
    required this.title,
    required this.buyPrice,
    required this.resalePrice,
    required this.hunterScore,
  });

  final String title;
  final double buyPrice;
  final double resalePrice;
  final int hunterScore;

  @override
  Widget build(BuildContext context) {
    final profit = resalePrice - buyPrice;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Buy: \$${buyPrice.toStringAsFixed(0)}',
            ),

            Text(
              'Estimated resale: \$${resalePrice.toStringAsFixed(0)}',
            ),

            Text(
              'Estimated profit: +\$${profit.toStringAsFixed(0)}',
            ),

            Text(
              'Hunter Score: $hunterScore/100',
            ),
          ],
        ),
      ),
    );
  }
}
