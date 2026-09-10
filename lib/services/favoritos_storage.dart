import 'package:shared_preferences/shared_preferences.dart';

class FavoritosStorage {
  static const _key = 'warframe_possuidos';
  static const _legacyKey = 'warframe_favoritos';

  Future<Set<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final itens = prefs.getStringList(_key) ?? prefs.getStringList(_legacyKey) ?? [];
    return itens.toSet();
  }

  Future<void> salvar(Set<String> possuidos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, possuidos.toList());
  }
}
