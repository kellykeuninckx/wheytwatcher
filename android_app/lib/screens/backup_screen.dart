import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../logic/backup_manager.dart';
import '../theme/theme.dart';

/// Poort van `BackupView.swift`: exporteer alle data naar één bestand of zet
/// een eerdere back-up terug (vervangt alles).
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final json = await BackupManager.buildJson(widget.db);
      final now = DateTime.now();
      final stamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/whey-mate-backup-$stamp.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], subject: 'Whey, mate! back-up');
    } catch (_) {
      if (mounted) _toast('Exporteren is niet gelukt.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    final path = result?.files.single.path;
    if (path == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WwColors.cardBackground(widget.isDark),
        title: Text('Back-up terugzetten', style: TextStyle(color: WwColors.darkAccent(widget.isDark))),
        content: Text('Dit vervangt al je huidige gegevens door de gekozen back-up. Deze actie kan niet ongedaan worden.',
            style: TextStyle(color: WwColors.secondaryText(widget.isDark))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuleer', style: TextStyle(color: WwColors.teal))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ja, vervang alles', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final content = await File(path).readAsString();
      await BackupManager.restore(widget.db, content);
      if (mounted) {
        _toast('Back-up teruggezet. Herstart de app voor het beste resultaat.');
      }
    } catch (_) {
      if (mounted) _toast('Dit bestand kon niet worden teruggezet.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Back-up & herstel', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          children: [
            WwCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exporteren', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
                  const SizedBox(height: 6),
                  Text('Bewaar al je gegevens (profiel, logboek, gewicht, trainingen, maaltijden, favorieten…) in één bestand dat je kunt delen of opslaan.',
                      style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: WwColors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _busy ? null : _export,
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Exporteer back-up'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            WwCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terugzetten', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
                  const SizedBox(height: 6),
                  Text('Kies een eerder geëxporteerd back-upbestand. Let op: dit vervangt al je huidige gegevens.',
                      style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: WwColors.teal, side: BorderSide(color: WwColors.teal), padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _busy ? null : _import,
                      icon: const Icon(Icons.restore),
                      label: const Text('Kies back-up om terug te zetten'),
                    ),
                  ),
                ],
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: 20),
              Center(child: CircularProgressIndicator(color: WwColors.teal)),
            ],
          ],
        ),
      ),
    );
  }
}
