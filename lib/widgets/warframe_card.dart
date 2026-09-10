import 'package:flutter/material.dart';
import '../models/warframe.dart';

class WarframeCard extends StatelessWidget {
  final Warframe warframe;
  final bool isPossuido;
  final bool isExpandido;
  final VoidCallback onToggleExpansao;
  final ValueChanged<bool?> onTogglePossuido;

  const WarframeCard({
    super.key,
    required this.warframe,
    required this.isPossuido,
    required this.isExpandido,
    required this.onToggleExpansao,
    required this.onTogglePossuido,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggleExpansao,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isPossuido
                ? Colors.greenAccent.withValues(alpha: 0.85)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: isPossuido ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: AspectRatio(
                    aspectRatio: isExpandido ? 16 / 7 : 16 / 10,
                    child: Image.asset(
                      warframe.assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          warframe.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(strokeWidth: 2.0),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shield_outlined, size: 28.0, color: Colors.amber),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      warframe.name,
                                      style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 6.0,
                  right: 6.0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onTogglePossuido(!isPossuido),
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: isPossuido
                              ? Colors.green.shade900.withValues(alpha: 0.9)
                              : Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: isPossuido ? Colors.greenAccent : Colors.white70,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPossuido ? Icons.check : Icons.add,
                              color: isPossuido ? Colors.greenAccent : Colors.white,
                              size: 13.0,
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              isPossuido ? 'Possui' : 'Adicionar',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: isPossuido ? Colors.greenAccent : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              warframe.name,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: warframe.tags
                  .map(
                    (tag) => Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 10.0),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpandido
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 6.0),
                        const Divider(height: 8.0),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem('HP', warframe.health.toString(), Colors.redAccent),
                            ),
                            const SizedBox(width: 3.0),
                            Expanded(
                              child: _buildStatItem('ESC', warframe.shield.toString(), Colors.blueAccent),
                            ),
                            const SizedBox(width: 3.0),
                            Expanded(
                              child: _buildStatItem('ARM', warframe.armor.toString(), Colors.amberAccent),
                            ),
                            const SizedBox(width: 3.0),
                            Expanded(
                              child: _buildStatItem('ENG', warframe.power.toString(), Colors.purpleAccent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoTag('Versao', warframe.isPrime ? 'Prime' : 'Padrao', warframe.isPrime ? Colors.amber : Colors.blueGrey),
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: _buildInfoTag('Sexo', warframe.sex, Colors.tealAccent),
                            ),
                          ],
                        ),
                        if (warframe.description.isNotEmpty) ...[
                          const SizedBox(height: 6.0),
                          Text(
                            warframe.description,
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.25,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4.0),
                        Material(
                          type: MaterialType.transparency,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: const Text(
                              'Possui',
                              style: TextStyle(fontSize: 12.0),
                            ),
                            value: isPossuido,
                            onChanged: onTogglePossuido,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1.0),
          Text(
            value,
            style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 8.5, color: color, fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
