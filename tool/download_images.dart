import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final dir = Directory('assets/images');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  stdout.writeln('Consultando API de Warframes...');
  final res = await http.get(Uri.parse('https://api.warframestat.us/warframes'));
  if (res.statusCode != 200) {
    stderr.writeln('Erro ao consultar API: ${res.statusCode}');
    exit(1);
  }

  final List data = jsonDecode(res.body) as List;
  final warframes = data.where((item) {
    if (item is! Map<String, dynamic>) return false;
    final cat = item['category'] as String? ?? '';
    final type = item['type'] as String? ?? '';
    return cat == 'Warframes' || type == 'Warframe';
  }).toList();

  stdout.writeln('Encontrados ${warframes.length} Warframes. Baixando imagens...');

  int baixados = 0;
  for (final w in warframes) {
    final rawImageName = (w['imageName'] as String?)?.trim() ?? '';
    final name = (w['name'] as String?)?.trim() ?? '';
    final fileName = rawImageName.isNotEmpty ? rawImageName : '$name.png';
    final cleanFile = fileName.startsWith('/') ? fileName.substring(1) : fileName;

    final file = File('assets/images/$cleanFile');
    if (file.existsSync() && file.lengthSync() > 0) {
      baixados++;
      continue;
    }

    final urlsToTry = [
      'https://cdn.warframestat.us/img/$cleanFile',
      if (cleanFile != '$name.png') 'https://cdn.warframestat.us/img/$name.png',
      if (rawImageName.isNotEmpty && rawImageName != cleanFile) 'https://cdn.warframestat.us/img/$rawImageName',
    ];

    bool sucesso = false;
    for (final url in urlsToTry) {
      try {
        final imgRes = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
        if (imgRes.statusCode == 200 && imgRes.bodyBytes.isNotEmpty) {
          await file.writeAsBytes(imgRes.bodyBytes);
          baixados++;
          sucesso = true;
          break;
        }
      } catch (_) {}
    }

    if (!sucesso) {
      stdout.writeln('Nao foi possivel obter imagem para: $name ($cleanFile)');
    }
  }

  stdout.writeln('Concluido: $baixados imagens prontas em assets/images/');
}
