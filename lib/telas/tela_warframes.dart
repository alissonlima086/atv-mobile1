import 'dart:math';
import 'package:flutter/material.dart';
import '../models/warframe.dart';
import '../services/favoritos_storage.dart';
import '../services/warframe_api.dart';
import '../widgets/resumo_header.dart';
import '../widgets/sorteio_modal.dart';
import '../widgets/warframe_card.dart';

enum FiltroPosse { todos, possuidos, naoPossuidos }
enum FiltroPrime { todos, prime, normal }
enum FiltroSexo { todos, male, female, nonBinary }

class TelaWarframes extends StatefulWidget {
  const TelaWarframes({super.key});

  @override
  State<TelaWarframes> createState() => _TelaWarframesState();
}

class _TelaWarframesState extends State<TelaWarframes> {
  final WarframeApi _api = WarframeApi();
  final FavoritosStorage _storage = FavoritosStorage();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _buscaController = TextEditingController();

  List<Warframe> _warframes = [];
  Set<String> _possuidos = {};
  final Set<String> _expandidos = {};
  String _termoBusca = '';

  FiltroPosse _filtroPosse = FiltroPosse.todos;
  FiltroPrime _filtroPrime = FiltroPrime.todos;
  FiltroSexo _filtroSexo = FiltroSexo.todos;

  bool _carregando = true;
  String? _erro;

  static const int _itensPorPagina = 8;
  int _paginaAtual = 1;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resultados = await _api.fetchWarframes();
      final salvos = await _storage.carregar();
      if (!mounted) return;
      setState(() {
        _warframes = resultados;
        _possuidos = salvos;
        _carregando = false;
        _paginaAtual = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Nao foi possivel carregar os dados.';
        _carregando = false;
      });
    }
  }

  void _togglePossuido(String nome, bool? valor) {
    setState(() {
      if (_possuidos.contains(nome)) {
        _possuidos.remove(nome);
      } else {
        _possuidos.add(nome);
      }
    });
    _storage.salvar(_possuidos);
  }

  void _toggleExpansao(String nome) {
    setState(() {
      if (_expandidos.contains(nome)) {
        _expandidos.remove(nome);
      } else {
        _expandidos.add(nome);
      }
    });
  }

  void _setFiltro(VoidCallback atualizacao) {
    setState(() {
      atualizacao();
      _paginaAtual = 1;
    });
  }

  bool get _temFiltrosAtivos =>
      _filtroPosse != FiltroPosse.todos ||
      _filtroPrime != FiltroPrime.todos ||
      _filtroSexo != FiltroSexo.todos ||
      _termoBusca.isNotEmpty;

  void _limparTodosFiltros() {
    setState(() {
      _filtroPosse = FiltroPosse.todos;
      _filtroPrime = FiltroPrime.todos;
      _filtroSexo = FiltroSexo.todos;
      _termoBusca = '';
      _buscaController.clear();
      _paginaAtual = 1;
    });
  }

  void _abrirSorteioModal() {
    final listaBase = _itensFiltrados;
    if (listaBase.isEmpty) return;

    final random = Random();
    final sorteado = listaBase[random.nextInt(listaBase.length)];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SorteioModal(
        warframeInicial: sorteado,
        listaWarframes: listaBase,
        possuidos: _possuidos,
        onTogglePossuido: (nome) => _togglePossuido(nome, null),
        onLocalizarNoCatalogo: (w) {
          final index = _itensFiltrados.indexOf(w);
          if (index != -1) {
            final paginaDestino = (index ~/ _itensPorPagina) + 1;
            setState(() {
              _paginaAtual = paginaDestino;
              _expandidos.add(w.name);
            });
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                120.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        },
      ),
    );
  }

  List<Warframe> get _itensFiltrados {
    final termo = _termoBusca.trim().toLowerCase();
    return _warframes.where((w) {
      final isPossuido = _possuidos.contains(w.name);
      if (_filtroPosse == FiltroPosse.possuidos && !isPossuido) return false;
      if (_filtroPosse == FiltroPosse.naoPossuidos && isPossuido) return false;

      if (_filtroPrime == FiltroPrime.prime && !w.isPrime) return false;
      if (_filtroPrime == FiltroPrime.normal && w.isPrime) return false;

      final s = w.sex.trim().toLowerCase();
      if (_filtroSexo == FiltroSexo.male && s != 'male' && s != 'masculino') return false;
      if (_filtroSexo == FiltroSexo.female && s != 'female' && s != 'feminino') return false;
      if (_filtroSexo == FiltroSexo.nonBinary) {
        if (s == 'male' || s == 'masculino' || s == 'female' || s == 'feminino') return false;
      }

      if (termo.isNotEmpty && !w.name.toLowerCase().contains(termo)) return false;

      return true;
    }).toList();
  }

  int get _totalPaginas {
    final total = _itensFiltrados.length;
    if (total == 0) return 1;
    return ((total - 1) ~/ _itensPorPagina) + 1;
  }

  List<Warframe> get _itensDaPagina {
    final todos = _itensFiltrados;
    if (todos.isEmpty) return [];
    final inicio = (_paginaAtual - 1) * _itensPorPagina;
    if (inicio >= todos.length) return [];
    final fim = (inicio + _itensPorPagina > todos.length) ? todos.length : inicio + _itensPorPagina;
    return todos.sublist(inicio, fim);
  }

  void _irParaPagina(int pagina) {
    if (pagina < 1 || pagina > _totalPaginas) return;
    setState(() {
      _paginaAtual = pagina;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMonitor = screenWidth > 700;
    final maxAllowedWidth = isMonitor ? screenWidth * 0.5 : double.infinity;

    return Scaffold(
      backgroundColor: isMonitor
          ? theme.colorScheme.surfaceContainerLowest
          : theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxAllowedWidth),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: isMonitor ? BorderRadius.circular(16.0) : BorderRadius.zero,
                border: isMonitor
                    ? Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: 1.0,
                      )
                    : null,
                boxShadow: isMonitor
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16.0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              clipBehavior: isMonitor ? Clip.antiAlias : Clip.none,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text(
                    'Warframe Codex',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  elevation: 0,
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: _carregando || _warframes.isEmpty ? null : _abrirSorteioModal,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Sortear'),
                ),
                body: _buildCorpo(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCorpo() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Carregando Warframes...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48.0, color: Colors.redAccent),
              const SizedBox(height: 12.0),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _carregarDados,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final paginaItens = _itensDaPagina;
    final totalFiltrados = _itensFiltrados.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final crossAxisCount = constraints.maxWidth > 650 ? 3 : 2;
        final childAspectRatio = crossAxisCount == 3 ? 0.60 : 0.55;

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 84.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResumoHeader(
                totalGeral: _warframes.length,
                totalPossuidos: _possuidos.length,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar Warframe por nome...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _termoBusca.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _buscaController.clear();
                              setState(() {
                                _termoBusca = '';
                                _paginaAtual = 1;
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      _termoBusca = valor;
                      _paginaAtual = 1;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFilterGroup(
                      label: 'Posse',
                      chips: [
                        _buildChoiceChip('Todos', _filtroPosse == FiltroPosse.todos, () => _setFiltro(() => _filtroPosse = FiltroPosse.todos)),
                        _buildChoiceChip('Possuidos', _filtroPosse == FiltroPosse.possuidos, () => _setFiltro(() => _filtroPosse = FiltroPosse.possuidos)),
                        _buildChoiceChip('Nao Possuidos', _filtroPosse == FiltroPosse.naoPossuidos, () => _setFiltro(() => _filtroPosse = FiltroPosse.naoPossuidos)),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    _buildFilterGroup(
                      label: 'Edicao',
                      chips: [
                        _buildChoiceChip('Todos', _filtroPrime == FiltroPrime.todos, () => _setFiltro(() => _filtroPrime = FiltroPrime.todos)),
                        _buildChoiceChip('Prime', _filtroPrime == FiltroPrime.prime, () => _setFiltro(() => _filtroPrime = FiltroPrime.prime)),
                        _buildChoiceChip('Nao Prime', _filtroPrime == FiltroPrime.normal, () => _setFiltro(() => _filtroPrime = FiltroPrime.normal)),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    _buildFilterGroup(
                      label: 'Sexo',
                      chips: [
                        _buildChoiceChip('Todos', _filtroSexo == FiltroSexo.todos, () => _setFiltro(() => _filtroSexo = FiltroSexo.todos)),
                        _buildChoiceChip('Male', _filtroSexo == FiltroSexo.male, () => _setFiltro(() => _filtroSexo = FiltroSexo.male)),
                        _buildChoiceChip('Female', _filtroSexo == FiltroSexo.female, () => _setFiltro(() => _filtroSexo = FiltroSexo.female)),
                        _buildChoiceChip('Non-Binary', _filtroSexo == FiltroSexo.nonBinary, () => _setFiltro(() => _filtroSexo = FiltroSexo.nonBinary)),
                      ],
                    ),
                    if (_temFiltrosAtivos) ...[
                      const SizedBox(height: 6.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$totalFiltrados warframes encontrados',
                            style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                          ),
                          TextButton.icon(
                            onPressed: _limparTodosFiltros,
                            icon: const Icon(Icons.refresh, size: 14.0),
                            label: const Text('Limpar filtros', style: TextStyle(fontSize: 12.0)),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              if (paginaItens.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 44.0, color: Colors.grey),
                        const SizedBox(height: 8.0),
                        Text(
                          _termoBusca.isNotEmpty
                              ? 'Nenhum Warframe encontrado para "$_termoBusca".'
                              : 'Nenhum Warframe encontrado com os filtros selecionados.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: paginaItens.length,
                    itemBuilder: (context, index) {
                      final item = paginaItens[index];
                      final isPossuido = _possuidos.contains(item.name);
                      final isExpandido = _expandidos.contains(item.name);

                      return WarframeCard(
                        warframe: item,
                        isPossuido: isPossuido,
                        isExpandido: isExpandido,
                        onToggleExpansao: () => _toggleExpansao(item.name),
                        onTogglePossuido: (val) => _togglePossuido(item.name, val),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12.0),
                _buildControlesPaginacao(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterGroup({required String label, required List<Widget> chips}) {
    return Row(
      children: [
        SizedBox(
          width: 50.0,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: chips
                  .map((c) => Padding(padding: const EdgeInsets.only(right: 6.0), child: c))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.0,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildControlesPaginacao() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _paginaAtual > 1 ? () => _irParaPagina(_paginaAtual - 1) : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Anterior'),
          ),
          Text(
            '$_paginaAtual / $_totalPaginas',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
          ),
          ElevatedButton.icon(
            onPressed: _paginaAtual < _totalPaginas ? () => _irParaPagina(_paginaAtual + 1) : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Proxima'),
          ),
        ],
      ),
    );
  }
}
