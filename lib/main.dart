import 'package:flutter/material.dart';
import 'telas/tela_warframes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WarframeApp());
}

class WarframeApp extends StatelessWidget {
  const WarframeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warframe Codex',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      home: const TelaWarframes(),
    );
  }
}
