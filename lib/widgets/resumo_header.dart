import 'package:flutter/material.dart';

class ResumoHeader extends StatelessWidget {
  final int totalGeral;
  final int totalAdquirido;

  const ResumoHeader({
    super.key,
    required this.totalGeral,
    required this.totalAdquirido,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Total de Warframes'),
            trailing: Text(
              '$totalGeral',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Warframes Adquiridos'),
            trailing: Text(
              '$totalAdquirido',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
