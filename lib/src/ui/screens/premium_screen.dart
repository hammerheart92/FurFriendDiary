import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/purchase_service.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});
  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _loading = false;
  List products = [];

  @override
  void initState() {
    super.initState();
    PurchaseService.init(ref);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await PurchaseService.queryProducts();
    setState(() {
      products = p;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Go Premium')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: premium
                  ? const Center(child: Text('Premium unlocked!'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            'Unlock unlimited pets, advanced reports, and calendar export.'),
                        const SizedBox(height: 12),
                        if (products.isEmpty)
                          const Text(
                              'Products not available yet. Configure store listings.'),
                        for (final p in products)
                          Card(
                            child: ListTile(
                              title: Text(p.title),
                              subtitle: Text(p.description),
                              trailing: Text(p.price),
                              onTap: () => PurchaseService.buy(p),
                            ),
                          ),
                      ],
                    ),
            ),
    );
  }
}
