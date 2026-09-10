import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warframe_codex/models/warframe.dart';
import 'package:warframe_codex/services/warframe_api.dart';
import 'package:warframe_codex/widgets/resumo_header.dart';
import 'package:warframe_codex/widgets/sorteio_modal.dart';
import 'package:warframe_codex/widgets/warframe_card.dart';

void main() {
  const mockWarframe = Warframe(
    name: 'Excalibur',
    health: 300,
    shield: 300,
    armor: 225,
    power: 100,
    imageName: 'Excalibur.png',
    description: 'Espadachim classico.',
    isPrime: false,
    sex: 'Male',
  );

  testWidgets('ResumoHeader exibe metricas e divisor', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResumoHeader(totalGeral: 50, totalPossuidos: 5),
        ),
      ),
    );

    expect(find.text('Total de Warframes'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('Warframes Possuidos'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('WarframeCard recolhido exibe dados e tags sem overflow', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 400,
            child: WarframeCard(
              warframe: mockWarframe,
              isPossuido: false,
              isExpandido: false,
              onToggleExpansao: () {},
              onTogglePossuido: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Excalibur'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.text('Padrao'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
  });

  testWidgets('WarframeCard expandido exibe stats, linha, description e versao/sexo', (WidgetTester tester) async {
    bool possuidoAlterado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            height: 450,
            child: WarframeCard(
              warframe: mockWarframe,
              isPossuido: true,
              isExpandido: true,
              onToggleExpansao: () {},
              onTogglePossuido: (val) {
                possuidoAlterado = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('HP'), findsOneWidget);
    expect(find.text('ESC'), findsOneWidget);
    expect(find.text('ARM'), findsOneWidget);
    expect(find.text('ENG'), findsOneWidget);
    expect(find.text('Espadachim classico.'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(find.text('Possui'), findsNWidgets(2));
    expect(find.byType(AnimatedContainer), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(possuidoAlterado, isTrue);
  });

  testWidgets('WarframeCard recolhido permite alternar Possui diretamente pelo botao', (WidgetTester tester) async {
    bool possuidoToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 350,
            child: WarframeCard(
              warframe: mockWarframe,
              isPossuido: false,
              isExpandido: false,
              onToggleExpansao: () {},
              onTogglePossuido: (val) {
                possuidoToggled = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Adicionar'), findsOneWidget);
    await tester.tap(find.text('Adicionar'));
    await tester.pump();
    expect(possuidoToggled, isTrue);
  });

  testWidgets('SorteioModal exibe dados, description, botoes e permite marcar como possuido', (WidgetTester tester) async {
    bool possuidoChamado = false;
    bool localizarChamado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SorteioModal(
            warframeInicial: mockWarframe,
            listaWarframes: const [mockWarframe],
            possuidos: const {},
            onTogglePossuido: (_) {
              possuidoChamado = true;
            },
            onLocalizarNoCatalogo: (_) {
              localizarChamado = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Destaque Sorteado'), findsOneWidget);
    expect(find.text('Excalibur'), findsOneWidget);
    expect(find.text('Espadachim classico.'), findsOneWidget);
    expect(find.text('Outro'), findsOneWidget);
    expect(find.text('Ver no Catalogo'), findsOneWidget);
    expect(find.text('Marcar como Possuido'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.text('Apenas nao possuidos'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(possuidoChamado, isTrue);

    await tester.ensureVisible(find.text('Ver no Catalogo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver no Catalogo'));
    await tester.pump();
    expect(localizarChamado, isTrue);
  });

  testWidgets('Barra de busca dinamica com icone de limpar', (WidgetTester tester) async {
    final controller = TextEditingController();
    String termo = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                controller: controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: termo.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.clear();
                            setState(() => termo = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => termo = val),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), 'EXCALIBUR');
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsNothing);
  });

  test('Filtros avancados por prime, nao prime, posse e sexo', () {
    const wExcal = Warframe(
      name: 'Excalibur',
      health: 300,
      shield: 300,
      armor: 225,
      power: 100,
      imageName: 'Excalibur.png',
      isPrime: false,
      sex: 'Male',
    );
    const wMagPrime = Warframe(
      name: 'Mag Prime',
      health: 300,
      shield: 450,
      armor: 175,
      power: 175,
      imageName: 'MagPrime.png',
      isPrime: true,
      sex: 'Female',
    );
    const wXaku = Warframe(
      name: 'Xaku',
      health: 290,
      shield: 290,
      armor: 145,
      power: 160,
      imageName: 'Xaku.png',
      isPrime: false,
      sex: 'Non-Binary',
    );

    final warframes = [wExcal, wMagPrime, wXaku];
    final possuidos = {'Excalibur'};

    // Filtro Prime vs Nao Prime
    expect(warframes.where((w) => w.isPrime).map((w) => w.name), ['Mag Prime']);
    expect(warframes.where((w) => !w.isPrime).map((w) => w.name), ['Excalibur', 'Xaku']);

    // Filtro Posse
    expect(warframes.where((w) => possuidos.contains(w.name)).map((w) => w.name), ['Excalibur']);
    expect(warframes.where((w) => !possuidos.contains(w.name)).map((w) => w.name), ['Mag Prime', 'Xaku']);

    // Filtro Sexo
    expect(warframes.where((w) => w.sex.toLowerCase() == 'male').map((w) => w.name), ['Excalibur']);
    expect(warframes.where((w) => w.sex.toLowerCase() == 'female').map((w) => w.name), ['Mag Prime']);
    expect(
      warframes.where((w) => w.sex.toLowerCase() != 'male' && w.sex.toLowerCase() != 'female').map((w) => w.name),
      ['Xaku'],
    );
  });

  test('WarframeApi carrega lista de fallback local', () async {
    final api = WarframeApi(bundle: _LocalTestAssetBundle());
    final fallbackList = await api.carregarFallbackLocal();
    expect(fallbackList.isNotEmpty, isTrue);
    expect(fallbackList.any((w) => w.name == 'Excalibur'), isTrue);
    expect(fallbackList.length, 121);
  });
}

class _LocalTestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File(key);
    final bytes = await file.readAsBytes();
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}
