import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:http/http.dart' as http;
import '../models/warframe.dart';

class WarframeApi {
  static const _baseUrl = 'https://api.warframestat.us';
  static const fallbackAssetPath = 'assets/data/warframes.json';

  final http.Client _client;
  final AssetBundle? bundle;

  WarframeApi({http.Client? client, this.bundle})
      : _client = client ?? http.Client();

  Future<List<Warframe>> fetchWarframes({bool forceFallback = false}) async {
    if (!forceFallback) {
      try {
        final response = await _client
            .get(Uri.parse('$_baseUrl/warframes'))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body) as List;
          final warframes = _parseWarframes(data);
          if (warframes.isNotEmpty) {
            return warframes;
          }
        }
      } catch (_) {}
    }

    return carregarFallbackLocal();
  }

  Future<List<Warframe>> carregarFallbackLocal() async {
    final resolvedBundle = bundle ?? rootBundle;
    final rawJson = await resolvedBundle.loadString(fallbackAssetPath);
    final List data = jsonDecode(rawJson) as List;
    final warframes = _parseWarframes(data);
    if (warframes.isEmpty) {
      throw Exception('Fallback local vazio ou invalido.');
    }
    return warframes;
  }

  List<Warframe> _parseWarframes(List data) {
    final List<Warframe> warframes = [];

    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final category = item['category'] as String? ?? '';
      final type = item['type'] as String? ?? '';
      if (category == 'Warframes' || type == 'Warframe') {
        warframes.add(Warframe.fromJson(item));
      }
    }

    if (warframes.isEmpty) {
      for (final item in data) {
        if (item is Map<String, dynamic> && item['name'] != null) {
          warframes.add(Warframe.fromJson(item));
        }
      }
    }

    return warframes;
  }
}
