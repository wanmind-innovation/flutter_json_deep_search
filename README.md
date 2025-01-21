<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Flutter JSON Deep Search

A powerful and flexible Flutter package for deep searching within JSON data structures. This package provides advanced search capabilities including regex matching, type filtering, and targeted key/value searches.

[![pub package](https://img.shields.io/pub/v/flutter_json_deep_search.svg)](https://pub.dev/packages/flutter_json_deep_search)
[![codecov](https://codecov.io/gh/willianmattos/flutter_json_deep_search/branch/main/graph/badge.svg)](https://codecov.io/gh/willianmattos/flutter_json_deep_search)
[![Tests](https://github.com/willianmattos/flutter_json_deep_search/actions/workflows/test.yml/badge.svg)](https://github.com/willianmattos/flutter_json_deep_search/actions/workflows/test.yml)

*Read this in other languages: [English](README.md), [Português](README.pt-BR.md)*

## Features

- 🔍 Deep search in nested JSON structures
- 🎯 Search in both keys and values
- ⚡ Regular expression support
- 🎨 Type-specific filtering
- 🎮 Flexible search targeting (keys only, values only, or both)
- 💪 Case-sensitive and exact match options
- 🌳 Smart nested object search
- 🔤 Diacritic-insensitive search (accent support)
- 🛠️ Path analysis helpers
- 🛡️ Null-safe

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_json_deep_search: ^1.0.0
```

## Usage

### Basic Search

```dart
import 'package:flutter_json_deep_search/flutter_json_deep_search.dart';

final jsonData = {
  'name': 'John',
  'age': 30,
  'address': {
    'city': {'name': 'New York', 'country': 'USA'}
  }
};

// Simple search
final results = JsonDeepSearch.search(jsonData, 'name');
```

### Advanced Search Options

#### Diacritic-Insensitive Search (Accent Support)
```dart
// Will find both "São Paulo" and "Sao Paulo"
final results = JsonDeepSearch.search(
  jsonData,
  'Sao Paulo',
  ignoreDiacritics: true,
);
```

#### Regex Search
```dart
// Find email addresses
final emailResults = JsonDeepSearch.search(
  jsonData,
  r'.*@.*\.com',
  useRegex: true,
);
```

#### Type Filtering
```dart
// Find only numeric values
final numberResults = JsonDeepSearch.search(
  jsonData,
  '123',
  allowedTypes: {int, double},
);
```

#### Search Target Control
```dart
// Search only in keys
final keyResults = JsonDeepSearch.search(
  jsonData,
  'id',
  searchTarget: SearchTarget.keysOnly,
);

// Search only in values
final valueResults = JsonDeepSearch.search(
  jsonData,
  'New York',
  searchTarget: SearchTarget.valuesOnly,
);
```

#### Nested Object Search
```dart
final userData = {
  'users': [
    {
      'id': 1,
      'profile': {
        'displayName': 'John Doe',
        'username': 'johnd'
      }
    }
  ]
};

// Search for specific fields in nested objects
final results = JsonDeepSearch.search(
  userData,
  'john',
  nestedSearch: {
    'profile': 'displayName', // Search 'displayName' field inside 'profile' objects
  },
  caseSensitive: false,
);
```

### Working with Search Results

SearchResult provides helpful methods for analyzing the results:

```dart
final result = results.first;

// Check if path contains specific key
if (result.hasInPath('profile')) {
  print('Found in profile section');
}

// Find specific element in path
final username = result.findInPath((segment) => segment == 'username');

// Custom path pattern matching
final isUserData = result.matchesPattern(
  (path) => path.contains('users') && path.contains('profile')
);
```

## Search Result Structure

Each search result includes:
- `path`: List of strings representing the path to the match
- `key`: The key where the match was found
- `value`: The value associated with the match
- `matchType`: Whether the match was found in a key, value, or nested value

```dart
SearchResult(
  path: ['address', 'city', 'name'],
  key: 'name',
  value: 'New York',
  matchType: MatchType.key,
)
```

## API Reference

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

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| jsonData | dynamic | required | The JSON data structure to search in |
| query | String | required | The search query |
| caseSensitive | bool | false | Whether the search should be case-sensitive |
| exactMatch | bool | false | Whether to match the entire string exactly |
| useRegex | bool | false | Whether to treat the query as a regular expression |
| ignoreDiacritics | bool | false | Whether to ignore accents in search |
| allowedTypes | Set<Type>? | null | Set of types to filter values by |
| searchTarget | SearchTarget | SearchTarget.both | Where to search (keys, values, or both) |
| nestedSearch | Map<String, String>? | null | Map of object keys to their searchable fields |

### SearchTarget

Enum defining where to search within the JSON structure:

```dart
enum SearchTarget {
  keysOnly,    // Search only in keys
  valuesOnly,  // Search only in values
  both         // Search in both keys and values
}
```

### MatchType

Enum indicating whether a match was found in a key or value:

```dart
enum MatchType {
  key,         // Match found in a key
  value,       // Match found in a value
  nestedValue  // Match found in a nested field
}
```

## Examples

### Complex Nested Search with Accents
```dart
final locationData = {
  'locations': [
    {
      'id': 1,
      'city': {
        'name': 'São Paulo',
        'info': {'population': 12000000}
      }
    }
  ]
};

// Find cities ignoring accents
final results = JsonDeepSearch.search(
  locationData,
  'Sao',
  ignoreDiacritics: true,
  searchTarget: SearchTarget.valuesOnly,
  nestedSearch: {
    'city': 'name',
  },
);
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Check our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
