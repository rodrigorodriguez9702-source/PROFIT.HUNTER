import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProfitHunterApp());
}

enum HunterPlan { casual, avid }

class UserProfile {
  const UserProfile(
    this.name,
    this.email,
    this.plan,
  );

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

  factory UserProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfile(
      json['name'] as String? ?? '',
      json['email'] as String? ?? '',
      (json['plan'] as String?) ==
              HunterPlan.avid.name
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
    required this.maxBuyPrice,
    required this.minProfit,
    required this.radiusMiles,
    this.modelNumber = '',
    this.sku = '',
    this.isActive = true,
  });

  final int id;

  String name;
  String keywords;
  double maxBuyPrice;
  double minProfit;
  int radiusMiles;

  String modelNumber;
  String sku;

  bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'keywords': keywords,
      'maxBuyPrice': maxBuyPrice,
      'minProfit': minProfit,
      'radiusMiles': radiusMiles,
      'modelNumber': modelNumber,
      'sku': sku,
      'isActive': isActive,
    };
  }

  factory Hunt.fromJson(
    Map<String, dynamic> json,
  ) {
    return Hunt(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      keywords:
          json['keywords'] as String? ?? '',
      maxBuyPrice:
          (json['maxBuyPrice'] as num?)
                  ?.toDouble() ??
              0,
      minProfit:
          (json['minProfit'] as num?)
                  ?.toDouble() ??
              0,
      radiusMiles:
          (json['radiusMiles'] as num?)
                  ?.toInt() ??
              30,
      modelNumber:
          json['modelNumber'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      isActive:
          json['isActive'] as bool? ?? true,
    );
  }
}

class Deal {
  Deal({
    required this.id,
    required this.title,
    required this.source,
    required this.price,
    required this.estimatedResale,
    required this.distanceMiles,
    this.modelNumber = '',
    this.sku = '',
    this.saved = false,
    this.dismissed = false,
  });

  final int id;
  final String title;
  final String source;

  final double price;
  final double estimatedResale;

  final int distanceMiles;

  final String modelNumber;
  final String sku;

  bool saved;
  bool dismissed;

  double get estimatedProfit {
    return estimatedResale - price;
  }

  int get hunterScore {
    if (price <= 0) {
      return 0;
    }

    final roi =
        (estimatedProfit / price) * 100;

    return roi.clamp(0, 100).round();
  }

  String get rating {
    if (hunterScore >= 90) {
      return 'HOT DEAL';
    }

    if (hunterScore >= 75) {
      return 'GOOD DEAL';
    }

    if (hunterScore >= 60) {
      return 'WATCH';
    }

    return 'PASS';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'source': source,
      'price': price,
      'estimatedResale': estimatedResale,
      'distanceMiles': distanceMiles,
      'modelNumber': modelNumber,
      'sku': sku,
      'saved': saved,
      'dismissed': dismissed,
    };
  }

  factory Deal.fromJson(
    Map<String, dynamic> json,
  ) {
    return Deal(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      source:
          json['source'] as String? ?? '',
      price:
          (json['price'] as num?)
                  ?.toDouble() ??
              0,
      estimatedResale:
          (json['estimatedResale'] as num?)
                  ?.toDouble() ??
              0,
      distanceMiles:
          (json['distanceMiles'] as num?)
                  ?.toInt() ??
              0,
      modelNumber:
          json['modelNumber'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      saved: json['saved'] as bool? ?? false,
      dismissed:
          json['dismissed'] as bool? ?? false,
    );
  }
}

class ProfitHunterApp extends StatelessWidget {
  const ProfitHunterApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Profit Hunter',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              const Color(0xFF16A34A),
          brightness:
              Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: const AppGate(),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({
    super.key,
  });

  @override
  State<AppGate> createState() {
    return _AppGateState();
  }
}

class _AppGateState
    extends State<AppGate> {
  static const profileKey =
      'profit_hunter_profile_v1';

  UserProfile? profile;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final raw =
        prefs.getString(profileKey);

    UserProfile? loaded;

    if (raw != null) {
      try {
        loaded =
            UserProfile.fromJson(
          Map<String, dynamic>.from(
            jsonDecode(raw) as Map,
          ),
        );
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    setState(() {
      profile = loaded;
      loading = false;
    });
  }

  Future<void> saveProfile(
    UserProfile value,
  ) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      profileKey,
      jsonEncode(
        value.toJson(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      profile = value;
    });
  }

  Future<void> signOut() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.remove(
      profileKey,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      profile = null;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (profile == null) {
      return AccountSetupPage(
        onCreateAccount:
            saveProfile,
      );
    }

    return HomeShell(
      profile: profile!,
      onProfileUpdated:
          saveProfile,
      onSignOut: signOut,
    );
  }
}

class AccountSetupPage
    extends StatefulWidget {
  const AccountSetupPage({
    super.key,
    required this.onCreateAccount,
  });

  final Future<void> Function(
    UserProfile,
  ) onCreateAccount;

  @override
  State<AccountSetupPage>
      createState() {
    return _AccountSetupPageState();
  }
}

class _AccountSetupPageState
    extends State<AccountSetupPage> {
  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(24),

          children: [
            const SizedBox(
              height: 30,
            ),

            const Text(
              '🔥 PROFIT HUNTER',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText: 'Name',
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            FilledButton(
              onPressed: () async {
                final name =
                    nameController
                        .text
                        .trim();

                final email =
                    emailController
                        .text
                        .trim();

                if (name.isEmpty ||
                    !email
                        .contains('@')) {
                  return;
                }

                await widget
                    .onCreateAccount(
                  UserProfile(
                    name,
                    email,
                    HunterPlan.casual,
                  ),
                );
              },

              child: const Text(
                'CREATE ACCOUNT',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeShell
    extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onSignOut,
  });

  final UserProfile profile;

  final Future<void> Function(
    UserProfile,
  ) onProfileUpdated;

  final Future<void> Function()
      onSignOut;

  @override
  State<HomeShell> createState() {
    return _HomeShellState();
  }
}

class _HomeShellState
    extends State<HomeShell> {
  static const huntsKey =
      'profit_hunter_hunts_v2';

  static const dealsKey =
      'profit_hunter_deals_v1';

  int selectedIndex = 0;

  int nextHuntId = 1;

  bool loading = true;

  final hunts = <Hunt>[];

  final deals = <Deal>[];

  HunterPlan get plan {
    return widget.profile.plan;
  }

  int get activeHuntCount {
    return hunts
        .where(
          (hunt) =>
              hunt.isActive,
        )
        .length;
  }

  bool get canCreateAnotherHunt {
    return plan ==
            HunterPlan.avid ||
        activeHuntCount < 2;
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final rawHunts =
        prefs.getString(
      huntsKey,
    );

    final rawDeals =
        prefs.getString(
      dealsKey,
    );

    if (rawHunts != null) {
      try {
        final decoded =
            jsonDecode(rawHunts)
                as List<dynamic>;

        hunts.addAll(
          decoded.map(
            (item) =>
                Hunt.fromJson(
              Map<String, dynamic>
                  .from(
                item as Map,
              ),
            ),
          ),
        );
      } catch (_) {}
    }

    if (rawDeals != null) {
      try {
        final decoded =
            jsonDecode(rawDeals)
                as List<dynamic>;

        deals.addAll(
          decoded.map(
            (item) =>
                Deal.fromJson(
              Map<String, dynamic>
                  .from(
                item as Map,
              ),
            ),
          ),
        );
      } catch (_) {}
    }

    if (deals.isEmpty) {
      deals.addAll(
        [
          Deal(
            id: 1,
            title:
                'Milwaukee M18 Fuel Kit',
            source:
                'Sample Marketplace',
            price: 120,
            estimatedResale: 260,
            distanceMiles: 8,
            modelNumber:
                'M18 FUEL',
          ),

          Deal(
            id: 2,
            title:
                'DeWalt 20V Tool Bundle',
            source:
                'Sample Local Listing',
            price: 100,
            estimatedResale: 240,
            distanceMiles: 12,
          ),

          Deal(
            id: 3,
            title:
                'Solid Wood Dresser',
            source:
                'Sample Local Listing',
            price: 50,
            estimatedResale: 225,
            distanceMiles: 5,
          ),
        ],
      );
    }

    if (hunts.isNotEmpty) {
      nextHuntId =
          hunts
                  .map(
                    (hunt) =>
                        hunt.id,
                  )
                  .reduce(
                    (a, b) =>
                        a > b
                            ? a
                            : b,
                  ) +
              1;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      loading = false;
    });

    await saveDeals();
  }

  Future<void> saveHunts() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      huntsKey,
      jsonEncode(
        hunts
            .map(
              (hunt) =>
                  hunt.toJson(),
            )
            .toList(),
      ),
    );
  }

  Future<void> saveDeals() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      dealsKey,
      jsonEncode(
        deals
            .map(
              (deal) =>
                  deal.toJson(),
            )
            .toList(),
      ),
    );
  }

  bool dealMatchesHunt(
    Deal deal,
    Hunt hunt,
  ) {
    if (!hunt.isActive) {
      return false;
    }

    if (deal.price >
        hunt.maxBuyPrice) {
      return false;
    }

    if (deal.distanceMiles >
        hunt.radiusMiles) {
      return false;
    }

    if (deal.estimatedProfit <
        hunt.minProfit) {
      return false;
    }

    final haystack =
        '${deal.title} '
        '${deal.modelNumber} '
        '${deal.sku}'
            .toLowerCase();

    final terms =
        hunt.keywords
            .split(',')
            .map(
              (term) =>
                  term
                      .trim()
                      .toLowerCase(),
            )
            .where(
              (term) =>
                  term.isNotEmpty,
            )
            .toList();

    if (terms.isNotEmpty &&
        !terms.any(
          (term) =>
              haystack.contains(
            term,
          ),
        )) {
      return false;
    }

    if (hunt.modelNumber
            .trim()
            .isNotEmpty &&
        !haystack.contains(
          hunt.modelNumber
              .trim()
              .toLowerCase(),
        )) {
      return false;
    }

    if (hunt.sku
            .trim()
            .isNotEmpty &&
        !haystack.contains(
          hunt.sku
              .trim()
              .toLowerCase(),
        )) {
      return false;
    }

    return true;
  }

  List<Hunt> matchingHunts(
    Deal deal,
  ) {
    return hunts
        .where(
          (hunt) =>
              dealMatchesHunt(
            deal,
            hunt,
          ),
        )
        .toList();
  }

  Future<void> addHunt(
    Hunt hunt,
  ) async {
    setState(() {
      hunts.add(hunt);

      nextHuntId++;
    });

    await saveHunts();
  }

  Future<void> toggleSaved(
    int id,
  ) async {
    setState(() {
      final deal =
          deals.firstWhere(
        (deal) =>
            deal.id == id,
      );

      deal.saved =
          !deal.saved;
    });

    await saveDeals();
  }

  Future<void> dismissDeal(
    int id,
  ) async {
    setState(() {
      final deal =
          deals.firstWhere(
        (deal) =>
            deal.id == id,
      );

      deal.dismissed =
          true;
    });

    await saveDeals();
  }

  Future<void>
      upgradeToAvid() async {
    await widget
        .onProfileUpdated(
      UserProfile(
        widget.profile.name,
        widget.profile.email,
        HunterPlan.avid,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final visibleDeals =
        deals
            .where(
              (deal) =>
                  !deal.dismissed,
            )
            .toList();

    visibleDeals.sort(
      (a, b) =>
          b.hunterScore
              .compareTo(
            a.hunterScore,
          ),
    );

    final matchedDeals =
        visibleDeals
            .where(
              (deal) =>
                  matchingHunts(
                    deal,
                  ).isNotEmpty,
            )
            .toList();

    final pages = [
      DashboardPage(
        profile:
            widget.profile,
        activeHuntCount:
            activeHuntCount,
        matchedDeals:
            matchedDeals,
      ),

      HuntsPage(
        plan: plan,
        hunts: hunts,
        canCreateAnotherHunt:
            canCreateAnotherHunt,
        nextHuntId:
            nextHuntId,
        onAddHunt: addHunt,
        onUpgrade:
            upgradeToAvid,
      ),

      DealsPage(
        deals:
            visibleDeals,
        matchingHunts:
            matchingHunts,
        onToggleSaved:
            toggleSaved,
        onDismiss:
            dismissDeal,
      ),

      SavedDealsPage(
        deals: visibleDeals
            .where(
              (deal) =>
                  deal.saved,
            )
            .toList(),
        matchingHunts:
            matchingHunts,
        onToggleSaved:
            toggleSaved,
      ),

      SettingsPage(
        profile:
            widget.profile,
        onUpgrade:
            upgradeToAvid,
        onSignOut:
            widget.onSignOut,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child:
            pages[selectedIndex],
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            selectedIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            selectedIndex =
                index;
          });
        },

        destinations:
            const [
          NavigationDestination(
            icon:
                Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.track_changes,
            ),
            label: 'Hunts',
          ),

          NavigationDestination(
            icon: Icon(
              Icons
                  .local_fire_department,
            ),
            label: 'Deals',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.bookmark,
            ),
            label: 'Saved',
          ),

          NavigationDestination(
            icon:
                Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardPage
    extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.profile,
    required this.activeHuntCount,
    required this.matchedDeals,
  });

  final UserProfile profile;
  final int activeHuntCount;
  final List<Deal> matchedDeals;

  @override
  Widget build(
    BuildContext context,
  ) {
    final potentialProfit =
        matchedDeals.fold<double>(
      0,
      (sum, deal) =>
          sum +
          deal.estimatedProfit,
    );

    return ListView(
      padding:
          const EdgeInsets.all(20),

      children: [
        const Text(
          '🔥 PROFIT HUNTER',
          style: TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        Text(
          'Welcome, ${profile.name}',
        ),

        const SizedBox(
          height: 20,
        ),

        StatCard(
          title: 'Active Hunts',
          value: profile.plan ==
                  HunterPlan.avid
              ? '$activeHuntCount'
              : '$activeHuntCount / 2',
        ),

        StatCard(
          title:
              'Matched Deals',
          value:
              '${matchedDeals.length}',
        ),

        StatCard(
          title:
              'Potential Profit',
          value:
              '\$${potentialProfit.toStringAsFixed(0)}',
        ),

        const SizedBox(
          height: 20,
        ),

        const Text(
          'Top Matches',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        if (matchedDeals.isEmpty)
          const Card(
            child: Padding(
              padding:
                  EdgeInsets.all(
                16,
              ),
              child: Text(
                'No current deals match your active hunts yet.',
              ),
            ),
          )
        else
          ...matchedDeals
              .take(3)
              .map(
                (deal) => Card(
                  child: ListTile(
                    title:
                        Text(
                      deal.title,
                    ),
                    subtitle:
                        Text(
                      'Profit +\$${deal.estimatedProfit.toStringAsFixed(0)} • Score ${deal.hunterScore}',
                    ),
                    trailing:
                        Text(
                      '\$${deal.price.toStringAsFixed(0)}',
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class HuntsPage
    extends StatelessWidget {
  const HuntsPage({
    super.key,
    required this.plan,
    required this.hunts,
    required this.canCreateAnotherHunt,
    required this.nextHuntId,
    required this.onAddHunt,
    required this.onUpgrade,
  });

  final HunterPlan plan;
  final List<Hunt> hunts;
  final bool canCreateAnotherHunt;
  final int nextHuntId;

  final Future<void> Function(
    Hunt,
  ) onAddHunt;

  final Future<void> Function()
      onUpgrade;

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      padding:
          const EdgeInsets.all(20),

      children: [
        const Text(
          '🎯 My Hunts',
          style: TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        FilledButton.icon(
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

          onPressed: () {
            if (!canCreateAnotherHunt) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UpgradePage(
                    onUpgrade:
                        onUpgrade,
                  ),
                ),
              );

              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CreateHuntPage(
                  huntId:
                      nextHuntId,
                  onSave:
                      onAddHunt,
                ),
              ),
            );
          },
        ),

        const SizedBox(
          height: 16,
        ),

        if (hunts.isEmpty)
          const Card(
            child: Padding(
              padding:
                  EdgeInsets.all(
                16,
              ),
              child: Text(
                'Create a hunt to start matching deals.',
              ),
            ),
          )
        else
          ...hunts.map(
            (hunt) => Card(
              child: Padding(
                padding:
                    const EdgeInsets
                        .all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      hunt.name,

                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    Text(
                      'Keywords: ${hunt.keywords}',
                    ),

                    Text(
                      'Max \$${hunt.maxBuyPrice.toStringAsFixed(0)} • Profit \$${hunt.minProfit.toStringAsFixed(0)}+ • ${hunt.radiusMiles} mi',
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CreateHuntPage
    extends StatefulWidget {
  const CreateHuntPage({
    super.key,
    required this.huntId,
    required this.onSave,
  });

  final int huntId;

  final Future<void> Function(
    Hunt,
  ) onSave;

  @override
  State<CreateHuntPage>
      createState() {
    return _CreateHuntPageState();
  }
}

class _CreateHuntPageState
    extends State<CreateHuntPage> {
  final name =
      TextEditingController();

  final keywords =
      TextEditingController();

  final model =
      TextEditingController();

  final sku =
      TextEditingController();

  final maxPrice =
      TextEditingController(
    text: '150',
  );

  final minProfit =
      TextEditingController(
    text: '75',
  );

  final radius =
      TextEditingController(
    text: '30',
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Create Hunt',
        ),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(
          20,
        ),

        children: [
          TextField(
            controller: name,
            decoration:
                const InputDecoration(
              labelText:
                  'Hunt name',
            ),
          ),

          TextField(
            controller:
                keywords,
            decoration:
                const InputDecoration(
              labelText:
                  'Keywords',
            ),
          ),

          TextField(
            controller: model,
            decoration:
                const InputDecoration(
              labelText:
                  'Model number (optional)',
            ),
          ),

          TextField(
            controller: sku,
            decoration:
                const InputDecoration(
              labelText:
                  'SKU / UPC (optional)',
            ),
          ),

          TextField(
            controller:
                maxPrice,
            keyboardType:
                TextInputType.number,
            decoration:
                const InputDecoration(
              labelText:
                  'Maximum buy price',
              prefixText: '\$',
            ),
          ),

          TextField(
            controller:
                minProfit,
            keyboardType:
                TextInputType.number,
            decoration:
                const InputDecoration(
              labelText:
                  'Minimum profit',
              prefixText: '\$',
            ),
          ),

          TextField(
            controller:
                radius,
            keyboardType:
                TextInputType.number,
            decoration:
                const InputDecoration(
              labelText:
                  'Radius',
              suffixText:
                  ' miles',
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          FilledButton(
            onPressed: () async {
              if (name.text
                      .trim()
                      .isEmpty ||
                  keywords.text
                      .trim()
                      .isEmpty) {
                return;
              }

              await widget
                  .onSave(
                Hunt(
                  id:
                      widget.huntId,

                  name:
                      name.text
                          .trim(),

                  keywords:
                      keywords.text
                          .trim(),

                  maxBuyPrice:
                      double.tryParse(
                            maxPrice
                                .text,
                          ) ??
                          0,

                  minProfit:
                      double.tryParse(
                            minProfit
                                .text,
                          ) ??
                          0,

                  radiusMiles:
                      int.tryParse(
                            radius
                                .text,
                          ) ??
                          30,

                  modelNumber:
                      model.text
                          .trim(),

                  sku:
                      sku.text
                          .trim(),
                ),
              );

              if (!mounted) {
                return;
              }

              Navigator.pop(
                context,
              );
            },

            child:
                const Text(
              'SAVE HUNT',
            ),
          ),
        ],
      ),
    );
  }
}

class DealsPage
    extends StatelessWidget {
  const DealsPage({
    super.key,
    required this.deals,
    required this.matchingHunts,
    required this.onToggleSaved,
    required this.onDismiss,
  });

  final List<Deal> deals;

  final List<Hunt> Function(
    Deal,
  ) matchingHunts;

  final Future<void> Function(
    int,
  ) onToggleSaved;

  final Future<void> Function(
    int,
  ) onDismiss;

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      padding:
          const EdgeInsets.all(
        20,
      ),

      children: [
        const Text(
          '🔥 Deal Feed',
          style: TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        if (deals.isEmpty)
          const Card(
            child: Padding(
              padding:
                  EdgeInsets.all(
                16,
              ),
              child: Text(
                'No active deals.',
              ),
            ),
          )
        else
          ...deals.map(
            (deal) =>
                DealCard(
              deal: deal,
              matchingHunts:
                  matchingHunts(
                deal,
              ),

              onSave:
                  () async {
                await onToggleSaved(
                  deal.id,
                );
              },

              onDismiss:
                  () async {
                await onDismiss(
                  deal.id,
                );
              },
            ),
          ),
      ],
    );
  }
}

class SavedDealsPage
    extends StatelessWidget {
  const SavedDealsPage({
    super.key,
    required this.deals,
    required this.matchingHunts,
    required this.onToggleSaved,
  });

  final List<Deal> deals;

  final List<Hunt> Function(
    Deal,
  ) matchingHunts;

  final Future<void> Function(
    int,
  ) onToggleSaved;

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      padding:
          const EdgeInsets.all(
        20,
      ),

      children: [
        const Text(
          '🔖 Saved Deals',
          style: TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        if (deals.isEmpty)
          const Card(
            child: Padding(
              padding:
                  EdgeInsets.all(
                16,
              ),
              child: Text(
                'No saved deals yet.',
              ),
            ),
          )
        else
          ...deals.map(
            (deal) =>
                DealCard(
              deal: deal,
              matchingHunts:
                  matchingHunts(
                deal,
              ),

              onSave:
                  () async {
                await onToggleSaved(
                  deal.id,
                );
              },

              onDismiss:
                  null,
            ),
          ),
      ],
    );
  }
}

class DealCard
    extends StatelessWidget {
  const DealCard({
    super.key,
    required this.deal,
    required this.matchingHunts,
    required this.onSave,
    this.onDismiss,
  });

  final Deal deal;

  final List<Hunt>
      matchingHunts;

  final VoidCallback onSave;

  final VoidCallback?
      onDismiss;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    deal.title,

                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),

                Chip(
                  label:
                      Text(
                    deal.rating,
                  ),
                ),
              ],
            ),

            Text(
              deal.source,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Buy: \$${deal.price.toStringAsFixed(0)}',
            ),

            Text(
              'Estimated resale: \$${deal.estimatedResale.toStringAsFixed(0)}',
            ),

            Text(
              'Estimated profit: +\$${deal.estimatedProfit.toStringAsFixed(0)}',
            ),

            Text(
              'Distance: ${deal.distanceMiles} miles',
            ),

            Text(
              'Hunter Score: ${deal.hunterScore}/100',
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              matchingHunts
                      .isEmpty
                  ? 'No active hunt match'
                  : 'Matches: ${matchingHunts.map((hunt) => hunt.name).join(', ')}',
            ),

            const SizedBox(
              height: 10,
            ),

            Wrap(
              spacing: 8,

              children: [
                FilledButton.icon(
                  onPressed:
                      onSave,

                  icon: Icon(
                    deal.saved
                        ? Icons.bookmark
                        : Icons
                            .bookmark_border,
                  ),

                  label: Text(
                    deal.saved
                        ? 'SAVED'
                        : 'SAVE DEAL',
                  ),
                ),

                if (onDismiss != null)
                  OutlinedButton
                      .icon(
                    onPressed:
                        onDismiss,

                    icon:
                        const Icon(
                      Icons.close,
                    ),

                    label:
                        const Text(
                      'DISMISS',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UpgradePage
    extends StatelessWidget {
  const UpgradePage({
    super.key,
    required this.onUpgrade,
  });

  final Future<void> Function()
      onUpgrade;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Avid Hunter',
        ),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(
          24,
        ),

        children: [
          const Text(
            '🔥 Become an Avid Hunter',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          const ListTile(
            leading: Icon(
              Icons.all_inclusive,
            ),
            title:
                Text(
              'Unlimited Hunts',
            ),
          ),

          const ListTile(
            leading: Icon(
              Icons.psychology_alt,
            ),
            title:
                Text(
              'Advanced AI Analysis',
            ),
          ),

          const ListTile(
            leading: Icon(
              Icons
                  .notifications_active,
            ),
            title:
                Text(
              'Priority Alerts',
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            '\$9.99/month',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          FilledButton(
            onPressed: () async {
              await onUpgrade();

              if (!context
                  .mounted) {
                return;
              }

              Navigator.pop(
                context,
              );
            },

            child:
                const Text(
              'START AVID HUNTER',
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage
    extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.profile,
    required this.onUpgrade,
    required this.onSignOut,
  });

  final UserProfile profile;

  final Future<void> Function()
      onUpgrade;

  final Future<void> Function()
      onSignOut;

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      padding:
          const EdgeInsets.all(
        20,
      ),

      children: [
        const Text(
          '⚙️ Settings',

          style:
              TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        Card(
          child: ListTile(
            leading:
                const Icon(
              Icons.person,
            ),

            title:
                Text(
              profile.name,
            ),

            subtitle:
                Text(
              profile.email,
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading:
                const Icon(
              Icons.workspace_premium,
            ),

            title:
                Text(
              profile.plan ==
                      HunterPlan.avid
                  ? '🔥 Avid Hunter'
                  : '🟢 Casual Hunter',
            ),

            onTap: profile.plan ==
                    HunterPlan.avid
                ? null
                : () {
                    Navigator.push(
                      context,
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

        OutlinedButton.icon(
          onPressed: () async {
            await onSignOut();
          },

          icon:
              const Icon(
            Icons.logout,
          ),

          label:
              const Text(
            'SIGN OUT',
          ),
        ),
      ],
    );
  }
}

class StatCard
    extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),

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
