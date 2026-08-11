import 'package:flutter/material.dart';

import '../logic/purchase_manager.dart';
import '../theme/theme.dart';

/// Poort van `PaywallView.swift`: één eenmalige aankoop die Premium ontgrendelt.
/// De feature-lijst is afgestemd op wat op Android achter de paywall zit.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, required this.isDark});

  final bool isDark;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _purchasing = false;
  bool _restoring = false;

  Future<void> _buy() async {
    setState(() => _purchasing = true);
    await PurchaseManager.instance.buyPremium();
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (PurchaseManager.instance.isPremiumUnlocked) Navigator.of(context).pop();
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    await PurchaseManager.instance.restore();
    if (!mounted) return;
    setState(() => _restoring = false);
    if (PurchaseManager.instance.isPremiumUnlocked) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Premium', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: PurchaseManager.instance,
          builder: (context, _) {
            final pm = PurchaseManager.instance;
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              children: [
                Column(
                  children: [
                    Icon(Icons.star, size: 44, color: WwColors.orange),
                    const SizedBox(height: 8),
                    Text('Whey, mate! Premium',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
                    const SizedBox(height: 6),
                    Text(
                      'Eenmalige aankoop — geen abonnement, geen verborgen kosten.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: WwColors.secondaryText(isDark)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                WwCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _feature(Icons.show_chart, 'Langere grafiek-geschiedenis (30 dagen & alles)'),
                      const SizedBox(height: 12),
                      _feature(Icons.pie_chart, 'Gedetailleerd macro-overzicht per dag'),
                      const SizedBox(height: 12),
                      _feature(Icons.favorite, 'Steun de doorontwikkeling van de app'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (pm.isPremiumUnlocked)
                  _unlockedNotice()
                else
                  _buyArea(pm),
                if (pm.purchaseErrorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(pm.purchaseErrorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buyArea(PurchaseManager pm) {
    final isDark = widget.isDark;
    return Column(
      children: [
        if (pm.isLoadingProduct)
          Text('Productinformatie laden…', style: TextStyle(color: WwColors.secondaryText(isDark)))
        else if (pm.product != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: WwColors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: (_purchasing || _restoring) ? null : _buy,
              child: _purchasing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Ontgrendel voor ${pm.priceLabel ?? ''}'),
            ),
          )
        else
          Text('Productinformatie kon niet geladen worden.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: WwColors.secondaryText(isDark))),
        const SizedBox(height: 12),
        TextButton(
          onPressed: (_purchasing || _restoring) ? null : _restore,
          child: _restoring
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: WwColors.secondaryText(isDark)))
              : Text('Aankoop terugzetten', style: TextStyle(color: WwColors.secondaryText(isDark))),
        ),
      ],
    );
  }

  Widget _unlockedNotice() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Row(
        children: [
          Icon(Icons.check_circle, color: WwColors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Premium is ontgrendeld — bedankt voor je steun!',
                style: TextStyle(color: WwColors.darkAccent(isDark), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    final isDark = widget.isDark;
    return Row(
      children: [
        Icon(icon, size: 20, color: WwColors.teal),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: WwColors.darkAccent(isDark)))),
      ],
    );
  }
}
