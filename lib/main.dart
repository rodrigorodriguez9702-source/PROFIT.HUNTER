import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProfitHunterApp());
}

enum HunterPlan { casual, avid }

class UserProfile {
  UserProfile({
    required this.name,
    required this.email,
    required this.plan,
  });

  final String name;
  final String email;
  final HunterPlan plan;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'plan': plan.name,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      plan: (json['plan'] as String?) == HunterPlan.avid.name
          ? HunterPlan.avid
          : HunterPlan.casual,
    );
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'keywords': keywords,
      'modelNumber': modelNumber,
      'sku': sku,
      'maxBuyPrice': maxBuyPrice,
      'minProfit': minProfit,
      'radiusMiles': radiusMiles,
      'isActive': isActive,
    };
  }

  factory Hunt.fromJson(Map<String, dynamic> json) {
    return Hunt(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      keywords: json['keywords'] as String? ?? '',
      modelNumber: json['modelNumber'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      maxBuyPrice: (json['maxBuyPrice'] as num?)?.toDouble() ?? 0,
      minProfit: (json['minProfit'] as num?)?.toDouble() ?? 0,
      radiusMiles: (json['radiusMiles'] as num?)?.toInt() ?? 30,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
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
      home: const AppGate(),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  static const profileKey = 'profit_hunter_profile_v1';

  bool isLoading = true;
  UserProfile? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(profileKey);

    UserProfile? loaded;

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);

        if (decoded is Map) {
          loaded = UserProfile.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      profile = loaded;
      isLoading = false;
    });
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      profileKey,
      jsonEncode(newProfile.toJson()),
    );

    if (!mounted) return;

    setState(() {
      profile = newProfile;
    });
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(profileKey);

    if (!mounted) return;

    setState(() {
      profile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (profile == null) {
      return AccountSetupPage(
        onCreateAccount: saveProfile,
      );
    }

    return HomeShell(
      profile: profile!,
      onProfileUpdated: saveProfile,
      onSignOut: signOut,
    );
  }
}

class AccountSetupPage extends StatefulWidget {
  const AccountSetupPage({
    super.key,
    required this.onCreateAccount,
  });

  final Future<void> Function(UserProfile) onCreateAccount;

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your name and a valid email address.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    await widget.onCreateAccount(
      UserProfile(
        name: name,
        email: email,
        plan: HunterPlan.casual,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 30),

            const Text(
              '🔥 PROFIT HUNTER',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Create your Hunter profile',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: isSaving ? null : createAccount,
              icon: const Icon(Icons.person_add),
              label: Text(
                isSaving
                    ? 'CREATING...'
                    : 'CREATE ACCOUNT',
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Accounts v1 stores your profile on this device.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onSignOut,
  });

  final UserProfile profile;
  final Future<void> Function(UserProfile) onProfileUpdated;
  final Future<void> Function() onSignOut;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const huntsKey = 'profit_hunter_hunts_v2';

  int selectedIndex = 0;
  int nextHuntId = 1;
  bool isLoading = true;

  final List<Hunt> hunts = [];

  HunterPlan get plan => widget.profile.plan;

  @override
  void initState() {
    super.initState();
    loadHunts();
  }

  int get activeHuntCount =>
      hunts.where((hunt) => hunt.isActive).length;

  bool get canCreateAnotherHunt {
    return plan == HunterPlan.avid ||
        activeHuntCount < 2;
  }

  Future<void> loadHunts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(huntsKey);

    final loadedHunts = <Hunt>[];

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;

        for (final item in decoded) {
          if (item is Map) {
            loadedHunts.add(
              Hunt.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      hunts
        ..clear()
        ..addAll(loadedHunts);

      if (hunts.isNotEmpty) {
        final highestId = hunts
            .map((hunt) => hunt.id)
            .reduce((a, b) => a > b ? a : b);

        nextHuntId = highestId + 1;
      }

      isLoading = false;
    });
  }

  Future<void> saveHunts() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      huntsKey,
      jsonEncode(
        hunts.map((hunt) => hunt.toJson()).toList(),
      ),
    );
  }

  Future<void> addHunt(Hunt hunt) async {
    setState(() {
      hunts.add(hunt);
      nextHuntId += 1;
    });

    await saveHunts();
  }

  Future<void> updateHunt(Hunt updated) async {
    setState(() {
      final index =
          hunts.indexWhere((hunt) => hunt.id == updated.id);

      if (index != -1) {
        hunts[index] = updated;
      }
    });

    await saveHunts();
  }

  Future<void> deleteHunt(int huntId) async {
    setState(() {
      hunts.removeWhere(
        (hunt) => hunt.id == huntId,
      );
    });

    await saveHunts();
  }

  Future<void> toggleHunt(int huntId) async {
    final hunt =
        hunts.firstWhere((item) => item.id == huntId);

    if (!hunt.isActive &&
        plan == HunterPlan.casual &&
        activeHuntCount >= 2) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Casual Hunter allows up to 2 active hunts.',
          ),
        ),
      );

      return;
    }

    setState(() {
      hunt.isActive = !hunt.isActive;
    });

    await saveHunts();
  }

  Future<void> upgradeToAvid() async {
    await widget.onProfileUpdated(
      UserProfile(
        name: widget.profile.name,
        email: widget.profile.email,
        plan: HunterPlan.avid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final pages = [
      DashboardPage(
        profile: widget.profile,
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
        profile: widget.profile,
        activeHuntCount: activeHuntCount,
        onUpgrade: upgradeToAvid,
        onSignOut: widget.onSignOut,
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
    required this.profile,
    required this.hunts,
    required this.activeHuntCount,
  });

  final UserProfile profile;
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
          'Welcome, ${profile.name}',
        ),

        Text(
          profile.plan == HunterPlan.avid
              ? 'Avid Hunter'
              : 'Casual Hunter',
        ),

        const SizedBox(height: 24),

        StatCard(
          title: 'Active Hunts',
          value: profile.plan == HunterPlan.avid
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
                  hunt.isActive
                      ? 'Active'
                      : 'Paused',
                ),
              ),
            ),
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

  final Future<void> Function(Hunt) onAddHunt;
  final Future<void> Function(Hunt) onUpdateHunt;
  final Future<void> Function(int) onDeleteHunt;
  final Future<void> Function(int) onToggleHunt;
  final Future<void> Function() onUpgrade;

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
    final huntLimitText =
        plan == HunterPlan.avid
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
          onPressed: () =>
              openCreateHunt(context),

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

              onToggle: () async {
                await onToggleHunt(
                  hunt.id,
                );
              },

              onDelete: () async {
                await onDeleteHunt(
                  hunt.id,
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
      margin:
          const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hunt.name,

                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
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

            Text(
              'Keywords: ${hunt.keywords}',
            ),

            if (hunt
                .modelNumber
                .trim()
                .isNotEmpty)
              Text(
                'Model: ${hunt.modelNumber}',
              ),

            if (hunt
                .sku
                .trim()
                .isNotEmpty)
              Text(
                'SKU / UPC: ${hunt.sku}',
              ),

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
                  icon:
                      const Icon(Icons.edit),
                  label:
                      const Text('Edit'),
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

                  label:
                      const Text('Delete'),
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
  final Future<void> Function(Hunt) onSave;
  final Hunt? existingHunt;

  @override
  State<HuntFormPage> createState() =>
      _HuntFormPageState();
}

class _HuntFormPageState
    extends State<HuntFormPage> {
  late final TextEditingController
      nameController;

  late final TextEditingController
      keywordController;

  late final TextEditingController
      modelController;

  late final TextEditingController
      skuController;

  late final TextEditingController
      maxBuyController;

  late final TextEditingController
      minProfitController;

  late final TextEditingController
      radiusController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final hunt =
        widget.existingHunt;

    nameController =
        TextEditingController(
      text: hunt?.name ?? '',
    );

    keywordController =
        TextEditingController(
      text: hunt?.keywords ?? '',
    );

    modelController =
        TextEditingController(
      text: hunt?.modelNumber ?? '',
    );

    skuController =
        TextEditingController(
      text: hunt?.sku ?? '',
    );

    maxBuyController =
        TextEditingController(
      text: hunt == null
          ? '150'
          : hunt.maxBuyPrice
              .toStringAsFixed(0),
    );

    minProfitController =
        TextEditingController(
      text: hunt == null
          ? '75'
          : hunt.minProfit
              .toStringAsFixed(0),
    );

    radiusController =
        TextEditingController(
      text: hunt == null
          ? '30'
          : hunt.radiusMiles
              .toString(),
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

  Future<void> saveHunt() async {
    final name =
        nameController.text.trim();

    final keywords =
        keywordController.text.trim();

    if (name.isEmpty ||
        keywords.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a hunt name and keywords.',
          ),
        ),
      );

      return;
    }

    final maxBuy =
        double.tryParse(
      maxBuyController.text.trim(),
    );

    final minProfit =
        double.tryParse(
      minProfitController.text.trim(),
    );

    final radius =
        int.tryParse(
      radiusController.text.trim(),
    );

    if (maxBuy == null ||
        minProfit == null ||
        radius == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Check your price, profit, and radius values.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    final existing =
        widget.existingHunt;

    final hunt = Hunt(
      id: widget.huntId,
      name: name,
      keywords: keywords,

      modelNumber:
          modelController.text.trim(),

      sku:
          skuController.text.trim(),

      maxBuyPrice: maxBuy,
      minProfit: minProfit,
      radiusMiles: radius,

      isActive:
          existing?.isActive ?? true,
    );

    await widget.onSave(hunt);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.title)),

      body: ListView(
        padding:
            const EdgeInsets.all(20),

        children: [
          TextField(
            controller:
                nameController,

            decoration:
                const InputDecoration(
              labelText: 'Hunt name',

              hintText:
                  'Milwaukee Tool Hunter',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller:
                keywordController,

            decoration:
                const InputDecoration(
              labelText: 'Keywords',

              hintText:
                  'Milwaukee M18, Packout',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller:
                modelController,

            decoration:
                const InputDecoration(
              labelText:
                  'Model number (optional)',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller:
                skuController,

            decoration:
                const InputDecoration(
              labelText:
                  'SKU / UPC (optional)',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller:
                maxBuyController,

            keyboardType:
                const TextInputType
                    .numberWithOptions(
              decimal: true,
            ),

            decoration:
                const InputDecoration(
              labelText:
                  'Maximum buy price',

              prefixText: '\$',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller:
                minProfitController,

            keyboardType:
                const TextInputType
                    .numberWithOptions(
              decimal: true,
            ),

            decoration:
                const InputDecoration(
              labelText:
                  'Minimum profit goal',

              prefixText: '\$',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller:
                radiusController,

            keyboardType:
                TextInputType.number,

            decoration:
                const InputDecoration(
              labelText:
                  'Search radius',

              suffixText: ' miles',
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed:
                isSaving
                    ? null
                    : saveHunt,

            icon:
                const Icon(Icons.save),

            label: Text(
              isSaving
                  ? 'SAVING...'
                  : 'SAVE HUNT',
            ),
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

  final Future<void> Function()
      onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(
        title:
            const Text('Avid Hunter'),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(24),

        children: [
          const Text(
            '🔥',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(fontSize: 60),
          ),

          const Text(
            'Become an Avid Hunter',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          const ListTile(
            leading:
                Icon(Icons.all_inclusive),

            title:
                Text('Unlimited Hunts'),
          ),

          const ListTile(
            leading:
                Icon(Icons.psychology_alt),

            title:
                Text(
              'Advanced AI Analysis',
            ),
          ),

          const ListTile(
            leading:
                Icon(
              Icons.notifications_active,
            ),

            title:
                Text('Priority Alerts'),
          ),

          const SizedBox(height: 20),

          const Text(
            '\$9.99/month',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () async {
              await onUpgrade();

              if (!context.mounted) {
                return;
              }

              Navigator.pop(context);
            },

            child:
                const Text(
              'START AVID HUNTER',
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Prototype only: no payment is charged yet.',

            textAlign:
                TextAlign.center,
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
    return const SimplePage(
      title: '🔥 Deal Feed',
      description:
          'Your deal feed is still using sample listings for now.',
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
          'Flip tracking will be connected in the next build.',
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.profile,
    required this.activeHuntCount,
    required this.onUpgrade,
    required this.onSignOut,
  });

  final UserProfile profile;
  final int activeHuntCount;

  final Future<void> Function()
      onUpgrade;

  final Future<void> Function()
      onSignOut;

  @override
  Widget build(BuildContext context) {
    final isAvid =
        profile.plan ==
            HunterPlan.avid;

    return ListView(
      padding:
          const EdgeInsets.all(20),

      children: [
        const Text(
          '⚙️ Settings',

          style: TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: ListTile(
            leading:
                const Icon(Icons.person),

            title:
                Text(profile.name),

            subtitle:
                Text(profile.email),
          ),
        ),

        Card(
          child: ListTile(
            leading:
                const Icon(
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

            onTap: isAvid
                ? null
                : () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            UpgradePage(
                          onUpgrade:
                              onUpgrade,
                        ),
                      ),
                    );
                  },
          ),
        ),

        const SizedBox(height: 20),

        OutlinedButton.icon(
          onPressed: () async {
            await onSignOut();
          },

          icon:
              const Icon(Icons.logout),

          label:
              const Text('SIGN OUT'),
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
      padding:
          const EdgeInsets.all(20),

      children: [
        Text(
          title,

          style:
              const TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          description,

          style:
              const TextStyle(
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
        padding:
            const EdgeInsets.all(18),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

          children: [
            Text(title),

            Text(
              value,

              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
