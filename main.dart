import 'package:flutter/material.dart';

void main() => runApp(const ProfitHunterApp());

enum HunterPlan { casual, avid }

class Hunt {
  Hunt(this.name, this.maxPrice, this.minProfit);
  final String name;
  final double maxPrice;
  final double minProfit;
}

class Deal {
  Deal({
    required this.title,
    required this.source,
    required this.price,
    required this.resale,
    required this.score,
    this.model,
    this.sku,
  });
  final String title;
  final String source;
  final double price;
  final double resale;
  final int score;
  final String? model;
  final String? sku;
colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  double get profit => resale - price;
}

class Flip {
  Flip(this.name, this.bought, this.sold, this.expenses);
  final String name;
  final double bought;
  final double sold;
  final double expenses;
  double get profit => sold - bought - expenses;
}

class ProfitHunterApp extends StatefulWidget {
  const ProfitHunterApp({super.key});
  @override
  State<ProfitHunterApp> createState() => _ProfitHunterAppState();
}

class _ProfitHunterAppState extends State<ProfitHunterApp> {
  HunterPlan plan = HunterPlan.casual;
  final hunts = <Hunt>[];
  final flips = <Flip>[];
  final deals = <Deal>[
    Deal(title: 'Milwaukee M18 Fuel Kit', source: 'Sample Marketplace', price: 120, resale: 260, score: 94, model: 'M18 FUEL'),
    Deal(title: 'Solid Wood Dresser', source: 'Sample Local Listing', price: 50, resale: 225, score: 91),
    Deal(title: 'DeWalt 20V Tool Bundle', source: 'Sample Marketplace', price: 100, resale: 240, score: 95),
  ];

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
      home: Shell(
        plan: plan,
        hunts: hunts,
        deals: deals,
        flips: flips,
        onUpgrade: () => setState(() => plan = HunterPlan.avid),
        onAddHunt: (h) => setState(() => hunts.add(h)),
        onAddFlip: (f) => setState(() => flips.add(f)),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.plan,
    required this.hunts,
    required this.deals,
    required this.flips,
    required this.onUpgrade,
    required this.onAddHunt,
    required this.onAddFlip,
  });

  final HunterPlan plan;
  final List<Hunt> hunts;
  final List<Deal> deals;
  final List<Flip> flips;
  final VoidCallback onUpgrade;
  final ValueChanged<Hunt> onAddHunt;
  final ValueChanged<Flip> onAddFlip;

  mainAxisAlignment: MainAxisAlignment.center,
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Dashboard(hunts: widget.hunts, deals: widget.deals, flips: widget.flips, plan: widget.plan),
      HuntsScreen(plan: widget.plan, hunts: widget.hunts, onUpgrade: widget.onUpgrade, onAdd: widget.onAddHunt),
      DealsScreen(deals: widget.deals, onAddFlip: widget.onAddFlip),
      FlipsScreen(flips: widget.flips),
      SettingsScreen(plan: widget.plan, onUpgrade: widget.onUpgrade),
    ];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.track_changes), label: 'Hunts'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department), label: 'Deals'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Flips'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
      if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
    ]),
  );
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.hunts, required this.deals, required this.flips, required this.plan});
  final List<Hunt> hunts;
  final List<Deal> deals;
  final List<Flip> flips;
  final HunterPlan plan;

  @override
  Widget build(BuildContext context) {
    final potential = deals.fold<double>(0, (s, d) => s + d.profit);
    final realized = flips.fold<double>(0, (s, f) => s + f.profit);
    return ListView(children: [
      PageTitle('🔥 PROFIT HUNTER', subtitle: plan == HunterPlan.avid ? 'Avid Hunter' : 'Casual Hunter'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          StatCard(label: 'Potential Profit', value: '\$${potential.toStringAsFixed(0)}'),
          StatCard(label: 'Active Hunts', value: '${hunts.length}'),
          StatCard(label: 'Deals Found', value: '${deals.length}'),
          StatCard(label: 'Realized Profit', value: '\$${realized.toStringAsFixed(0)}'),
        ]),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Text('Top Opportunities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      ...deals.take(2).map((d) => DealCard(deal: d)),
    ]);
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 42) / 2,
    child: Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      ]),
    )),
  );
}

class HuntsScreen extends StatelessWidget {
  const HuntsScreen({super.key, required this.plan, required this.hunts, required this.onUpgrade, required this.onAdd});
  final HunterPlan plan;
  final List<Hunt> hunts;
  final VoidCallback onUpgrade;
  final ValueChanged<Hunt> onAdd;

  @override
  Widget build(BuildContext context) {
    final canAdd = plan == HunterPlan.avid || hunts.length < 2;
    return ListView(children: [
      PageTitle('🎯 My Hunts', subtitle: plan == HunterPlan.casual ? '${hunts.length}/2 Casual Hunter hunts used' : 'Unlimited hunts'),
      ...hunts.map((h) => ListTile(
        leading: const CircleAvatar(child: Icon(Icons.track_changes)),
        title: Text(h.name),
        subtitle: Text('Max \$${h.maxPrice.toStringAsFixed(0)} • Goal \$${h.minProfit.toStringAsFixed(0)}+ profit'),
        trailing: const Chip(label: Text('ACTIVE')),
      )),
      Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          icon: Icon(canAdd ? Icons.add : Icons.lock),
          label: Text(canAdd ? 'Create Hunt' : 'Unlock Unlimited Hunts'),
          onPressed: () {
            if (!canAdd) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UpgradeScreen(onUpgrade: onUpgrade)));
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CreateHuntScreen(onSave: onAdd)));
            }
          },
        ),
      ),
    ]);
  }
}

class CreateHuntScreen extends StatefulWidget {
  const CreateHuntScreen({super.key, required this.onSave});
  final ValueChanged<Hunt> onSave;
  @override
  State<CreateHuntScreen> createState() => _CreateHuntScreenState();
}

class _CreateHuntScreenState extends State<CreateHuntScreen> {
  final item = TextEditingController();
  final maxPrice = TextEditingController(text: '150');
  final minProfit = TextEditingController(text: '75');
  final model = TextEditingController();
  final sku = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Hunt')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      TextField(controller: item, decoration: const InputDecoration(labelText: 'What are you hunting?', hintText: 'Milwaukee tools')),
      const SizedBox(height: 12),
      TextField(controller: model, decoration: const InputDecoration(labelText: 'Model number (optional)')),
      const SizedBox(height: 12),
      TextField(controller: sku, decoration: const InputDecoration(labelText: 'SKU / UPC (optional)')),
      const SizedBox(height: 12),
      TextField(controller: maxPrice, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Maximum buy price', prefixText: '\$')),
      const SizedBox(height: 12),
      TextField(controller: minProfit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minimum profit goal', prefixText: '\$')),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () {
          if (item.text.trim().isEmpty) return;
          widget.onSave(Hunt(
            item.text.trim(),
            double.tryParse(maxPrice.text) ?? 0,
            double.tryParse(minProfit.text) ?? 0,
          ));
          Navigator.pop(context);
        },
        child: const Text('START HUNT'),
      ),
    ]),
  );
}

class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key, required this.deals, required this.onAddFlip});
  final List<Deal> deals;
  final ValueChanged<Flip> onAddFlip;
  @override
  Widget build(BuildContext context) => ListView(children: [
    const PageTitle('🔥 Deal Feed', subtitle: 'AI-ranked sample opportunities'),
    ...deals.map((d) => DealCard(
      deal: d,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DealDetails(deal: d, onAddFlip: onAddFlip))),
    )),
  ]);
}

class DealCard extends StatelessWidget {
  const DealCard({super.key, required this.deal, this.onTap});
  final Deal deal;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(deal.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Chip(label: Text('${deal.score}/100')),
          ]),
          Text(deal.source),
          const SizedBox(height: 10),
          Text('Buy \$${deal.price.toStringAsFixed(0)}  •  Resale \$${deal.resale.toStringAsFixed(0)}'),
          Text('Estimated profit +\$${deal.profit.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    ),
  );
}

class DealDetails extends StatelessWidget {
  const DealDetails({super.key, required this.deal, required this.onAddFlip});
  final Deal deal;
  final ValueChanged<Flip> onAddFlip;
  @override
  Widget build(BuildContext context) {
    final roi = deal.price == 0 ? 0 : (deal.profit / deal.price) * 100;
    return Scaffold(
      appBar: AppBar(title: const Text('Deal Analysis')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(deal.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(deal.source),
        const SizedBox(height: 20),
        StatCard(label: 'Hunter Score', value: '${deal.score}/100'),
        const SizedBox(height: 10),
        Card(child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Seller price: \$${deal.price.toStringAsFixed(0)}'),
            Text('Estimated resale: \$${deal.resale.toStringAsFixed(0)}'),
            Text('Estimated profit: +\$${deal.profit.toStringAsFixed(0)}'),
            Text('Estimated ROI: ${roi.toStringAsFixed(0)}%'),
            if (deal.model != null) Text('Model: ${deal.model}'),
            if (deal.sku != null) Text('SKU: ${deal.sku}'),
          ]),
        )),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: const Icon(Icons.inventory_2),
          label: const Text('ADD TO MY FLIPS'),
          onPressed: () {
            onAddFlip(Flip(deal.title, deal.price, deal.resale, 0));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to My Flips')));
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: const Text('OPEN LISTING'),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marketplace deep link will be connected in a later integration.')),
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('CONTACT SELLER'),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seller contact will open the marketplace-supported messaging flow.')),
          ),
        ),
      ]),
    );
  }
}

class FlipsScreen extends StatelessWidget {
  const FlipsScreen({super.key, required this.flips});
  final List<Flip> flips;
  @override
  Widget build(BuildContext context) {
    final total = flips.fold<double>(0, (s, f) => s + f.profit);
    return ListView(children: [
      PageTitle('📦 My Flips', subtitle: 'Realized profit: \$${total.toStringAsFixed(0)}'),
      if (flips.isEmpty)
        const Padding(padding: EdgeInsets.all(24), child: Text('No flips yet. Add a deal from the Deal Feed.')),
      ...flips.map((f) => ListTile(
        title: Text(f.name),
        subtitle: Text('Bought \$${f.bought.toStringAsFixed(0)} • Sold \$${f.sold.toStringAsFixed(0)}'),
        trailing: Text('+\$${f.profit.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      )),
    ]);
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.plan, required this.onUpgrade});
  final HunterPlan plan;
  final VoidCallback onUpgrade;
  @override
  Widget build(BuildContext context) => ListView(children: [
    const PageTitle('⚙️ Settings'),
    ListTile(
      leading: const Icon(Icons.workspace_premium),
      title: Text(plan == HunterPlan.avid ? '🔥 Avid Hunter' : '🟢 Casual Hunter'),
      subtitle: Text(plan == HunterPlan.avid ? 'All MVP features unlocked' : 'Up to 2 saved hunts'),
      trailing: plan == HunterPlan.casual ? const Icon(Icons.chevron_right) : null,
      onTap: plan == HunterPlan.casual
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => UpgradeScreen(onUpgrade: onUpgrade)))
          : null,
    ),
    const ListTile(leading: Icon(Icons.notifications), title: Text('Notifications'), subtitle: Text('Deal alerts and thresholds')),
    const ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Search Area'), subtitle: Text('Location and radius preferences')),
    const ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text('Privacy & Security')),
  ]);
}

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key, required this.onUpgrade});
  final VoidCallback onUpgrade;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Avid Hunter')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Text('🔥', textAlign: TextAlign.center, style: TextStyle(fontSize: 60)),
      Text('Become an Avid Hunter', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Unlock the full Profit Hunter experience.', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      const ListTile(leading: Icon(Icons.all_inclusive), title: Text('Unlimited Hunts')),
      const ListTile(leading: Icon(Icons.psychology_alt), title: Text('Advanced AI Analysis')),
      const ListTile(leading: Icon(Icons.notifications_active), title: Text('Priority Alerts')),
      const ListTile(leading: Icon(Icons.analytics_outlined), title: Text('Advanced Flip Analytics')),
      const ListTile(leading: Icon(Icons.qr_code_scanner), title: Text('Photo, Model/SKU & Barcode Tools')),
      const SizedBox(height: 20),
      const Text('\$9.99/month', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () {
          onUpgrade();
          Navigator.pop(context);
        },
        child: const Text('START AVID HUNTER'),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text(
          'Prototype only: this button unlocks Avid Hunter locally. App Store / Google Play billing is not connected yet.',
          textAlign: TextAlign.center,
        ),
      ),
    ]),
  );
}
