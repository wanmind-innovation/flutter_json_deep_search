import 'package:flutter/material.dart';
import 'package:flutter_json_deep_search/flutter_json_deep_search.dart';
import 'dart:convert';

class CidadeEstadoPage extends StatefulWidget {
  const CidadeEstadoPage({super.key});

  @override
  State<CidadeEstadoPage> createState() => _CidadeEstadoPageState();
}

class _CidadeEstadoPageState extends State<CidadeEstadoPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchCidadesEstados(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Load the JSON file
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/cidades-estados.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      // Use flutter_json_deep_search to search
      var results = JsonDeepSearch.search(
        jsonData,
        query,
        caseSensitive: false,
        ignoreDiacritics: true,
        searchTarget: SearchTarget.valuesOnly,
        nestedSearch: {
          'estado': 'nome',
          'cidades': 'nome',
        },
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      debugPrint('Error searching: $e');
    }
  }

  Widget _buildResultIcon(SearchResult result) {
    // Verifica se é uma cidade (tem 'cidades' no path)
    if (result.hasInPath('cidades')) {
      return const Icon(
        Icons.location_city,
        color: Colors.blue,
      );
    }
    // Se não for cidade, é um estado
    return const Icon(
      Icons.map,
      color: Colors.green,
    );
  }

  String _getResultSubtitle(SearchResult result) {
    if (result.hasInPath('cidades')) {
      // Encontra o estado da cidade
      final estado = result.findInPath((segment) => segment == 'estado') ?? '';
      return 'Cidade${estado.isNotEmpty ? ' - $estado' : ''}';
    }
    return 'Estado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca Cidade/Estado'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar cidade ou estado',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _searchCidadesEstados,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Digite algo para buscar'
                                  : 'Nenhum resultado encontrado',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            leading: _buildResultIcon(result),
                            title: Text(result.value.toString()),
                            subtitle: Text(_getResultSubtitle(result)),
                            trailing: Text(result.path.join('/')),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Row(
                                    children: [
                                      _buildResultIcon(result),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(result.hasInPath('cidades')
                                            ? 'Detalhes da Cidade'
                                            : 'Detalhes do Estado'),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: const Text('Valor Encontrado'),
                                        subtitle: Text(result.value.toString()),
                                        leading: const Icon(Icons.search),
                                      ),
                                      ListTile(
                                        title: const Text('Tipo de Match'),
                                        subtitle: Text(result.matchType
                                            .toString()
                                            .split('.')
                                            .last),
                                        leading: const Icon(Icons.category),
                                      ),
                                      ListTile(
                                        title: const Text('Caminho no JSON'),
                                        subtitle: Text(result.path.join(' → ')),
                                        leading: const Icon(Icons.route),
                                      ),
                                      ListTile(
                                        title: const Text('Chave'),
                                        subtitle: Text(result.key),
                                        leading: const Icon(Icons.key),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Fechar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
