import 'package:flutter/material.dart';

void main() {
  runApp(const ProfitHunterApp());
}

enum HunterPlan { casual, avid }

class Hunt {
  Hunt({
    required this.id,
    required this.name,
    required this.keywords,
    this.modelNumber = '',
    this.sku = '',
    required this.maxBuyPrice,
    required this.minProfit,
    required this.radiusMiles,
    this.isActive = true,
  });

  final int id;
  String name;
  String keywords;
  String modelNumber;
  String sku;
  double maxBuyPrice;
  double minProfit;
  int radiusMiles;
  bool isActive;
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
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selectedIndex = 0;
  HunterPlan plan = HunterPlan.casual;
  int nextHuntId = 1;

  final List<Hunt> hunts = [];

  int get activeHuntCount =>
      hunts.where((hunt) => hunt.isActive).length;

  bool get canCreateAnotherHunt {
    if (plan == HunterPlan.avid) return true;
    return activeHuntCount < 2;
  }

  void addHunt(Hunt hunt) {
    setState(() {
      hunts.add(hunt);
      nextHuntId += 1;
    });
  }

  void updateHunt(Hunt updated) {
    setState(() {
      final index =
          hunts.indexWhere((hunt) => hunt.id == updated.id);

      if (index != -1) {
        hunts[index] = updated;
      }
    });
  }

  void deleteHunt(int huntId) {
    setState(() {
      hunts.removeWhere((hunt) => hunt.id == huntId);
    });
  }

  void toggleHunt(int huntId) {
    setState(() {
      final hunt =
          hunts.firstWhere((item) => item.id == huntId);

      if (!hunt.isActive &&
          plan == HunterPlan.casual &&
          activeHuntCount >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Casual Hunter allows up to 2 active hunts.',
            ),
          ),
        );
        return;
      }

      hunt.isActive = !hunt.isActive;
    });
  }

  void upgradeToAvid() {
    setState(() {
      plan = HunterPlan.avid;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avid Hunter unlocked for this prototype.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        plan: plan,
        hunts: hunts,
        activeHuntCount: activeHuntCount,
      ),
      HuntsPage(
        plan: plan,
        hunts: hunts,
        activeHuntCount: activeHuntCount,
        canCreateAnotherHunt: canCreateAnotherHunt,
        nextHuntId: nextHuntId,
        onAddHunt: addHunt,
        onUpdateHunt: updateHunt,
        onDeleteHunt: deleteHunt,
        onToggleHunt: toggleHunt,
        onUpgrade: upgradeToAvid,
      ),
      const DealsPage(),
      const FlipsPage(),
      SettingsPage(
        plan: plan,
        activeHuntCount: activeHuntCount,
        onUpgrade: upgradeToAvid,
      ),
    ];

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
  const DashboardPage({
    super.key,
    required this.plan,
    required this.hunts,
    required this.activeHuntCount,
  });

  final HunterPlan plan;
  final List<Hunt> hunts;
  final int activeHuntCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '🔥 PROFIT HUNTER',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          plan == HunterPlan.avid
              ? 'Avid Hunter'
              : 'Casual Hunter',
        ),
        const SizedBox(height: 24),
        StatCard(
          title: 'Active Hunts',
          value: plan == HunterPlan.avid
              ? '$activeHuntCount'
              : '$activeHuntCount / 2',
        ),
        const StatCard(
          title: 'Deals Found',
          value: '3',
        ),
        const StatCard(
          title: 'Potential Profit',
          value: '\$365',
        ),
        const SizedBox(height: 24),
        const Text(
          'Your Hunts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (hunts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'No hunts yet. Open the Hunts tab to create your first one.',
              ),
            ),
          )
        else
          ...hunts.take(3).map(
                (hunt) => Card(
                  child: ListTile(
                    leading: Icon(
                      hunt.isActive
                          ? Icons.radar
                          : Icons.pause_circle_outline,
                    ),
                    title: Text(hunt.name),
                    subtitle: Text(
                      hunt.isActive ? 'Active' : 'Paused',
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 24),
        const Text(
          'Top Opportunities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const DealCard(
          title: 'Milwaukee M18 Fuel Kit',
          buyPrice: 120,
          resalePrice: 260,
          hunterScore: 94,
        ),
        const DealCard(
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
  const HuntsPage({
    super.key,
    required this.plan,
    required this.hunts,
    required this.activeHuntCount,
    required this.canCreateAnotherHunt,
    required this.nextHuntId,
    required this.onAddHunt,
    required this.onUpdateHunt,
    required this.onDeleteHunt,
    required this.onToggleHunt,
    required this.onUpgrade,
  });

  final HunterPlan plan;
  final List<Hunt> hunts;
  final int activeHuntCount;
  final bool canCreateAnotherHunt;
  final int nextHuntId;

  final ValueChanged<Hunt> onAddHunt;
  final ValueChanged<Hunt> onUpdateHunt;
  final ValueChanged<int> onDeleteHunt;
  final ValueChanged<int> onToggleHunt;
  final VoidCallback onUpgrade;

  void openCreateHunt(BuildContext context) {
    if (!canCreateAnotherHunt) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UpgradePage(
            onUpgrade: onUpgrade,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HuntFormPage(
          title: 'Create Hunt',
          huntId: nextHuntId,
          onSave: onAddHunt,
        ),
      ),
    );
  }

  void openEditHunt(
    BuildContext context,
    Hunt hunt,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HuntFormPage(
          title: 'Edit Hunt',
          huntId: hunt.id,
          existingHunt: hunt,
          onSave: onUpdateHunt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final huntLimitText = plan == HunterPlan.avid
        ? '$activeHuntCount active • Unlimited hunts'
        : '$activeHuntCount / 2 active hunts';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '🎯 My Hunts',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(huntLimitText),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => openCreateHunt(context),
          icon: Icon(
            canCreateAnotherHunt
                ? Icons.add
                : Icons.lock,
          ),
          label: Text(
            canCreateAnotherHunt
                ? 'Create New Hunt'
                : 'Unlock Unlimited Hunts',
          ),
        ),
        const SizedBox(height: 20),
        if (hunts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Create a hunt to start tracking an item, model, or SKU.',
              ),
            ),
          )
        else
          ...hunts.map(
            (hunt) => HuntCard(
              hunt: hunt,
              onEdit: () =>
                  openEditHunt(context, hunt),
              onToggle: () =>
                  onToggleHunt(hunt.id),
              onDelete: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) =>
                      AlertDialog(
                    title: const Text('Delete Hunt?'),
                    content: Text(
                      'Delete "${hunt.name}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          onDeleteHunt(hunt.id);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class HuntCard extends StatelessWidget {
  const HuntCard({
    super.key,
    required this.hunt,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final Hunt hunt;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hunt.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    hunt.isActive
                        ? 'ACTIVE'
                        : 'PAUSED',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Keywords: ${hunt.keywords}'),
            if (hunt.modelNumber.trim().isNotEmpty)
              Text('Model: ${hunt.modelNumber}'),
            if (hunt.sku.trim().isNotEmpty)
              Text('SKU / UPC: ${hunt.sku}'),
            const SizedBox(height: 8),
            Text(
              'Max buy: \$${hunt.maxBuyPrice.toStringAsFixed(0)}',
            ),
            Text(
              'Minimum profit: \$${hunt.minProfit.toStringAsFixed(0)}',
            ),
            Text(
              'Radius: ${hunt.radiusMiles} miles',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    hunt.isActive
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    hunt.isActive
                        ? 'Pause'
                        : 'Resume',
                  ),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HuntFormPage extends StatefulWidget {
  const HuntFormPage({
    super.key,
    required this.title,
    required this.huntId,
    required this.onSave,
    this.existingHunt,
  });

  final String title;
  final int huntId;
  final ValueChanged<Hunt> onSave;
  final Hunt? existingHunt;

  @override
  State<HuntFormPage> createState() =>
      _HuntFormPageState();
}

class _HuntFormPageState
    extends State<HuntFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController keywordController;
  late final TextEditingController modelController;
  late final TextEditingController skuController;
  late final TextEditingController maxBuyController;
  late final TextEditingController minProfitController;
  late final TextEditingController radiusController;

  @override
  void initState() {
    super.initState();

    final hunt = widget.existingHunt;

    nameController = TextEditingController(
      text: hunt?.name ?? '',
    );

    keywordController = TextEditingController(
      text: hunt?.keywords ?? '',
    );

    modelController = TextEditingController(
      text: hunt?.modelNumber ?? '',
    );

    skuController = TextEditingController(
      text: hunt?.sku ?? '',
    );

    maxBuyController = TextEditingController(
      text: hunt == null
          ? '150'
          : hunt.maxBuyPrice.toStringAsFixed(0),
    );

    minProfitController = TextEditingController(
      text: hunt == null
          ? '75'
          : hunt.minProfit.toStringAsFixed(0),
    );

    radiusController = TextEditingController(
      text: hunt == null
          ? '30'
          : hunt.radiusMiles.toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    keywordController.dispose();
    modelController.dispose();
    skuController.dispose();
    maxBuyController.dispose();
    minProfitController.dispose();
    radiusController.dispose();
    super.dispose();
  }

  void saveHunt() {
    final name = nameController.text.trim();
    final keywords = keywordController.text.trim();

    if (name.isEmpty || keywords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a hunt name and keywords.',
          ),
        ),
      );
      return;
    }

    final maxBuy =
        double.tryParse(maxBuyController.text.trim());

    final minProfit =
        double.tryParse(minProfitController.text.trim());

    final radius =
        int.tryParse(radiusController.text.trim());

    if (maxBuy == null ||
        minProfit == null ||
        radius == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Check your price, profit, and radius values.',
          ),
        ),
      );
      return;
    }

    final existing = widget.existingHunt;

    final hunt = Hunt(
      id: widget.huntId,
      name: name,
      keywords: keywords,
      modelNumber: modelController.text.trim(),
      sku: skuController.text.trim(),
      maxBuyPrice: maxBuy,
      minProfit: minProfit,
      radiusMiles: radius,
      isActive: existing?.isActive ?? true,
    );

    widget.onSave(hunt);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Hunt name',
              hintText: 'Milwaukee Tool Hunter',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: keywordController,
            decoration: const InputDecoration(
              labelText: 'Keywords',
              hintText: 'Milwaukee M18, Packout',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: modelController,
            decoration: const InputDecoration(
              labelText: 'Model number (optional)',
              hintText: '3697-25CX',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: skuController,
            decoration: const InputDecoration(
              labelText: 'SKU / UPC (optional)',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: maxBuyController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Maximum buy price',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: minProfitController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Minimum profit goal',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: radiusController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Search radius',
              suffixText: ' miles',
            ),
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: saveHunt,
            icon: const Icon(Icons.save),
            label: const Text('SAVE HUNT'),
          ),
        ],
      ),
    );
  }
}

class UpgradePage extends StatelessWidget {
  const UpgradePage({
    super.key,
    required this.onUpgrade,
  });

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avid Hunter'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            '🔥',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 60),
          ),
          const Text(
            'Become an Avid Hunter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock the full Profit Hunter experience.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          const ListTile(
            leading: Icon(Icons.all_inclusive),
            title: Text('Unlimited Hunts'),
          ),

          const ListTile(
            leading: Icon(Icons.psychology_alt),
            title: Text('Advanced AI Analysis'),
          ),

          const ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Priority Alerts'),
          ),

          const ListTile(
            leading: Icon(Icons.analytics_outlined),
            title: Text('Advanced Flip Analytics'),
          ),

          const SizedBox(height: 20),

          const Text(
            '\$9.99/month',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () {
              onUpgrade();
              Navigator.pop(context);
            },
            child: const Text(
              'START AVID HUNTER',
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Prototype only: no payment is charged yet.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
          'Track what you paid, expenses, selling price, and realized profit.',
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.plan,
    required this.activeHuntCount,
    required this.onUpgrade,
  });

  final HunterPlan plan;
  final int activeHuntCount;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isAvid =
        plan == HunterPlan.avid;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '⚙️ Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.workspace_premium,
            ),
            title: Text(
              isAvid
                  ? '🔥 Avid Hunter'
                  : '🟢 Casual Hunter',
            ),
            subtitle: Text(
              isAvid
                  ? 'Unlimited hunts'
                  : '$activeHuntCount / 2 active hunts',
            ),
            trailing: isAvid
                ? null
                : const Icon(
                    Icons.chevron_right,
                  ),
            onTap: isAvid
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            UpgradePage(
                          onUpgrade: onUpgrade,
                        ),
                      ),
                    );
                  },
          ),
        ),

        const Card(
          child: ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle:
                Text('Deal alerts and thresholds'),
          ),
        ),

        const Card(
          child: ListTile(
            leading:
                Icon(Icons.location_on_outlined),
            title: Text('Search Area'),
            subtitle:
                Text('Location and radius preferences'),
          ),
        ),

        const Card(
          child: ListTile(
            leading:
                Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy & Security'),
          ),
        ),
      ],
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
          style: const TextStyle(
            fontSize: 17,
          ),
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
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
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
    final profit =
        resalePrice - buyPrice;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
