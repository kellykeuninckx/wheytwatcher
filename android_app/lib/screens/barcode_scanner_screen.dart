import 'package:drift/drift.dart' show Value;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/open_food_facts_service.dart';
import '../theme/theme.dart';
import '../widgets/placeholder_card.dart';
import 'add_food_screen.dart';
import 'food_product_quick_add_screen.dart';

/// Poort van `BarcodeScannerView.swift`. iOS gebruikt VisionKit's
/// `DataScannerViewController`; hier `mobile_scanner` (camera + ML Kit
/// barcode-detectie) als Android/Flutter-equivalent.
///
/// Op iOS zit dit achter de premium-paywall — Android heeft nog geen Play
/// Billing (zie geheugen), dus voorlopig bewust vrij toegankelijk, net als de
/// andere premium-features die al geport zijn.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _controller = MobileScannerController();
  String? _lastScanned;
  bool _isLookingUp = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isLookingUp) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode == _lastScanned) return;
    _lastScanned = barcode;

    final db = widget.db;
    final existing = await (db.select(db.foodProducts)..where((p) => p.barcode.equals(barcode))).getSingleOrNull();

    if (existing != null) {
      await _openQuickAdd(FoodCandidate(
        name: existing.name,
        brand: existing.brand,
        caloriesPer100g: existing.caloriesPer100g,
        proteinPer100g: existing.proteinPer100g,
        carbsPer100g: existing.carbsPer100g,
        fatPer100g: existing.fatPer100g,
        fiberPer100g: existing.fiberPer100g,
      ));
      return;
    }

    setState(() => _isLookingUp = true);
    OpenFoodFactsLookupResult? remote;
    try {
      remote = await OpenFoodFactsService.lookup(barcode);
    } catch (_) {
      remote = null;
    }

    if (!mounted) return;
    setState(() => _isLookingUp = false);

    if (remote == null) {
      _showNotFoundDialog(barcode);
      return;
    }

    await db.into(db.foodProducts).insert(
          FoodProductsCompanion.insert(
            name: remote.name,
            brand: Value(remote.brand),
            barcode: Value(barcode),
            caloriesPer100g: remote.caloriesPer100g,
            proteinPer100g: remote.proteinPer100g,
            carbsPer100g: remote.carbsPer100g,
            fatPer100g: remote.fatPer100g,
            fiberPer100g: remote.fiberPer100g,
            createdAt: DateTime.now(),
          ),
        );

    await _openQuickAdd(FoodCandidate(
      name: remote.name,
      brand: remote.brand,
      caloriesPer100g: remote.caloriesPer100g,
      proteinPer100g: remote.proteinPer100g,
      carbsPer100g: remote.carbsPer100g,
      fatPer100g: remote.fatPer100g,
      fiberPer100g: remote.fiberPer100g,
    ));
  }

  Future<void> _openQuickAdd(FoodCandidate candidate) async {
    final logged = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => FoodProductQuickAddScreen(db: widget.db, isDark: widget.isDark, product: candidate),
      ),
    );
    if (logged == true && mounted) Navigator.of(context).pop();
    _lastScanned = null;
  }

  void _showNotFoundDialog(String barcode) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Niet gevonden'),
        content: const Text('We konden dit product niet vinden in onze database. Wil je het handmatig toevoegen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuleer'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddFoodScreen(db: widget.db, isDark: widget.isDark, prefilledBarcode: barcode),
                ),
              );
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Handmatig toevoegen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Sluiten', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetect,
            errorBuilder: (context, error) => Padding(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: PlaceholderCard(
                  isDark: isDark,
                  icon: Icons.qr_code_scanner,
                  color: WwColors.orange,
                  title: 'Scanner niet beschikbaar',
                  message: 'Barcode scannen vereist cameratoegang. Geef toestemming in de systeeminstellingen om dit te gebruiken.',
                ),
              ),
            ),
          ),
          if (_isLookingUp)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: WwColors.cardBackground(true), borderRadius: BorderRadius.circular(16)),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text('Product opzoeken…', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
