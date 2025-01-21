# Flutter JSON Deep Search

Um pacote Flutter poderoso e flexível para busca profunda em estruturas JSON. Este pacote fornece recursos avançados de busca, incluindo correspondência por regex, filtragem por tipo e buscas direcionadas em chaves/valores.

[![pub package](https://img.shields.io/pub/v/flutter_json_deep_search.svg)](https://pub.dev/packages/flutter_json_deep_search)
[![codecov](https://codecov.io/gh/willianmattos/flutter_json_deep_search/branch/main/graph/badge.svg)](https://codecov.io/gh/willianmattos/flutter_json_deep_search)
[![Tests](https://github.com/willianmattos/flutter_json_deep_search/actions/workflows/test.yml/badge.svg)](https://github.com/willianmattos/flutter_json_deep_search/actions/workflows/test.yml)

*Read this in other languages: [English](README.md), [Português](README.pt-BR.md)*

## Funcionalidades

- 🔍 Busca profunda em estruturas JSON aninhadas
- 🎯 Busca em chaves e valores
- ⚡ Suporte a expressões regulares (regex)
- 🎨 Filtragem por tipos específicos
- 🎮 Busca flexível (apenas chaves, apenas valores ou ambos)
- 💪 Opções de case sensitive e correspondência exata
- 🌳 Busca inteligente em objetos aninhados
- 🔤 Busca sem considerar acentos
- 🛠️ Helpers para análise de caminhos
- 🛡️ Null-safe

## Instalação

Adicione ao arquivo `pubspec.yaml` do seu projeto:

```yaml
dependencies:
  flutter_json_deep_search: ^1.0.0
```

## Como Usar

### Busca Básica

```dart
import 'package:flutter_json_deep_search/flutter_json_deep_search.dart';

final jsonData = {
  'nome': 'João',
  'idade': 30,
  'endereco': {
    'cidade': {'nome': 'São Paulo', 'pais': 'Brasil'}
  }
};

// Busca simples
final resultados = JsonDeepSearch.search(jsonData, 'nome');
```

### Opções Avançadas de Busca

#### Busca Ignorando Acentos
```dart
// Encontra tanto "São Paulo" quanto "Sao Paulo"
final resultados = JsonDeepSearch.search(
  jsonData,
  'Sao Paulo',
  ignoreDiacritics: true,
);
```

#### Busca com Regex
```dart
// Encontrar endereços de email
final emailResults = JsonDeepSearch.search(
  jsonData,
  r'.*@.*\.com\.br',
  useRegex: true,
);
```

#### Filtragem por Tipo
```dart
// Encontrar apenas valores numéricos
final numerosResults = JsonDeepSearch.search(
  jsonData,
  '123',
  allowedTypes: {int, double},
);
```

#### Controle do Alvo da Busca
```dart
// Buscar apenas em chaves
final chavesResults = JsonDeepSearch.search(
  jsonData,
  'id',
  searchTarget: SearchTarget.keysOnly,
);

// Buscar apenas em valores
final valoresResults = JsonDeepSearch.search(
  jsonData,
  'São Paulo',
  searchTarget: SearchTarget.valuesOnly,
);
```

#### Busca em Objetos Aninhados
```dart
final dadosUsuario = {
  'usuarios': [
    {
      'id': 1,
      'perfil': {
        'nomeCompleto': 'João Silva',
        'usuario': 'joaos'
      }
    }
  ]
};

// Buscar em campos específicos de objetos aninhados
final resultados = JsonDeepSearch.search(
  dadosUsuario,
  'joao',
  nestedSearch: {
    'perfil': 'nomeCompleto', // Busca no campo 'nomeCompleto' dentro de objetos 'perfil'
  },
  caseSensitive: false,
);
```

### Trabalhando com os Resultados

SearchResult fornece métodos úteis para análise dos resultados:

```dart
final resultado = resultados.first;

// Verificar se o caminho contém uma chave específica
if (resultado.hasInPath('perfil')) {
  print('Encontrado na seção de perfil');
}

// Encontrar elemento específico no caminho
final usuario = resultado.findInPath((segmento) => segmento == 'usuario');

// Correspondência personalizada de padrões no caminho
final isDadosUsuario = resultado.matchesPattern(
  (caminho) => caminho.contains('usuarios') && caminho.contains('perfil')
);
```

## Estrutura do Resultado da Busca

Cada resultado inclui:
- `path`: Lista de strings representando o caminho até o resultado
- `key`: A chave onde foi encontrado
- `value`: O valor associado
- `matchType`: Se foi encontrado em uma chave, valor ou valor aninhado

```dart
SearchResult(
  path: ['endereco', 'cidade', 'nome'],
  key: 'nome',
  value: 'São Paulo',
  matchType: MatchType.key,
)
```

## Referência da API

### JsonDeepSearch.search()

```dart
static List<SearchResult> search(
  dynamic jsonData,
  String query, {
  bool caseSensitive = false,
  bool exactMatch = false,
  bool useRegex = false,
  bool ignoreDiacritics = false,
  Set<Type>? allowedTypes,
  SearchTarget searchTarget = SearchTarget.both,
  Map<String, String>? nestedSearch,
})
```

#### Parâmetros

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|---------|-------------|
| jsonData | dynamic | obrigatório | A estrutura JSON para buscar |
| query | String | obrigatório | O termo de busca |
| caseSensitive | bool | false | Se a busca deve considerar maiúsculas/minúsculas |
| exactMatch | bool | false | Se deve corresponder exatamente à string |
| useRegex | bool | false | Se deve tratar a query como expressão regular |
| ignoreDiacritics | bool | false | Se deve ignorar acentos na busca |
| allowedTypes | Set<Type>? | null | Conjunto de tipos para filtrar valores |
| searchTarget | SearchTarget | SearchTarget.both | Onde buscar (chaves, valores ou ambos) |
| nestedSearch | Map<String, String>? | null | Mapa de chaves de objetos para seus campos pesquisáveis |

### SearchTarget

Enum que define onde buscar na estrutura JSON:

```dart
enum SearchTarget {
  keysOnly,    // Buscar apenas em chaves
  valuesOnly,  // Buscar apenas em valores
  both         // Buscar em ambos
}
```

### MatchType

Enum que indica onde o resultado foi encontrado:

```dart
enum MatchType {
  key,         // Encontrado em uma chave
  value,       // Encontrado em um valor
  nestedValue  // Encontrado em um campo aninhado
}
```

## Exemplos

### Busca Aninhada com Acentos
```dart
final dadosLocalizacao = {
  'locais': [
    {
      'id': 1,
      'cidade': {
        'nome': 'São Paulo',
        'info': {'populacao': 12000000}
      }
    }
  ]
};

// Encontrar cidades ignorando acentos
final resultados = JsonDeepSearch.search(
  dadosLocalizacao,
  'Sao',
  ignoreDiacritics: true,
  searchTarget: SearchTarget.valuesOnly,
  nestedSearch: {
    'cidade': 'nome',
  },
);
```

## Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para enviar um Pull Request. Confira nossas [Diretrizes de Contribuição](CONTRIBUTING.md) para mais detalhes.

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes. 