// lib/core/debug/log_viewer.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  Timer? _timer;
  String _filter = '';
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Her 500ms'de yenile (canlı log akışı)
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = MedLogger.recentLogs.where((e) {
      if (_filter.isEmpty) return true;
      final f = _filter.toLowerCase();
      return e.unit.toLowerCase().contains(f) ||
          e.message.toLowerCase().contains(f) ||
          (e.context?.toString().toLowerCase().contains(f) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Loglar', style: TextStyle(color: Colors.white, fontSize: 14)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            tooltip: 'Temizle',
            onPressed: () => setState(() => MedLogger.clearBuffer()),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Filtrele (unit, mesaj, içerik)...',
                hintStyle: const TextStyle(color: Colors.white38),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: logs.length,
              itemBuilder: (_, i) {
                final e = logs[i];
                final color = switch (e.level) {
                  LogLevel.error => const Color(0xFFFF6B6B),
                  LogLevel.warn => const Color(0xFFFFD93D),
                  LogLevel.info => const Color(0xFF6BCB77),
                };
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${e.timestamp.toIso8601String().substring(11, 23)} '
                    '[${e.unit}] ${e.message} ${e.context ?? ''}',
                    style: TextStyle(color: color, fontSize: 10, fontFamily: 'monospace'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
