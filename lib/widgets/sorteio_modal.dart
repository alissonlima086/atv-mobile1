import 'package:flutter/material.dart';
import '../models/warframe.dart';

class SorteioModal extends StatefulWidget {
  final Warframe warframeInicial;
  final List<Warframe> listaWarframes;
  final Set<String> possuidos;
  final ValueChanged<String> onTogglePossuido;
  final ValueChanged<Warframe> onLocalizarNoCatalogo;

  const SorteioModal({
    super.key,
    required this.warframeInicial,
    required this.listaWarframes,
    required this.possuidos,
    required this.onTogglePossuido,
    required this.onLocalizarNoCatalogo,
  });

  @override
  State<SorteioModal> createState() => _SorteioModalState();
}

class _SorteioModalState extends State<SorteioModal> {
  late Warframe _atual;
  bool _apenasNaoPossuidos = false;

  @override
  void initState() {
    super.initState();
    _atual = widget.warframeInicial;
  }

  void _sortearOutro() {
    var candidatos = widget.listaWarframes.where((w) => w.name != _atual.name);
    if (_apenasNaoPossuidos) {
      candidatos = candidatos.where((w) => !widget.possuidos.contains(w.name));
    }
    final lista = candidatos.toList();
    if (lista.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum outro Warframe disponivel com este filtro.')),
      );
      return;
    }
    lista.shuffle();
    setState(() {
      _atual = lista.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPossuido = widget.possuidos.contains(_atual.name);

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amber, size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                      'Warframe Sorteado',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 16.0),
            Center(
              child: SizedBox(
                height: 150.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    _atual.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        _atual.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.shield_outlined, size: 60.0, color: Colors.amber),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Center(
              child: Text(
                _atual.name,
                style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6.0),
            Center(
              child: Wrap(
                spacing: 6.0,
                children: _atual.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11.0)),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(child: _buildStat('Vida', _atual.health.toString(), Colors.redAccent)),
                const SizedBox(width: 6.0),
                Expanded(child: _buildStat('Escudo', _atual.shield.toString(), Colors.blueAccent)),
                const SizedBox(width: 6.0),
                Expanded(child: _buildStat('Armadura', _atual.armor.toString(), Colors.amberAccent)),
                const SizedBox(width: 6.0),
                Expanded(child: _buildStat('Energia', _atual.power.toString(), Colors.purpleAccent)),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTag('Versao', _atual.isPrime ? 'Prime' : 'Padrao', _atual.isPrime ? Colors.amber : Colors.blueGrey),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: _buildInfoTag('Sexo', _atual.sex, Colors.tealAccent),
                ),
              ],
            ),
            if (_atual.description.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _atual.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                    height: 1.35,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8.0),
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                dense: true,
                value: _apenasNaoPossuidos,
                title: const Text('Apenas nao possuidos'),
                subtitle: const Text('Sortear apenas warframes que ainda nao possui'),
                secondary: const Icon(Icons.filter_alt_outlined),
                onChanged: (val) {
                  setState(() => _apenasNaoPossuidos = val);
                },
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                dense: true,
                value: isPossuido,
                title: const Text('Marcar como Possuido'),
                secondary: Icon(
                  isPossuido ? Icons.check_circle : Icons.check_circle_outline,
                  color: isPossuido ? Colors.greenAccent : null,
                ),
                onChanged: (_) {
                  widget.onTogglePossuido(_atual.name);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sortearOutro,
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Outro'),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onLocalizarNoCatalogo(_atual);
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Ver no Catalogo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10.0, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2.0),
          Text(value, style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 10.0, color: color, fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
