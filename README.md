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

## Features

- 🔍 Deep search in nested JSON structures
- 🎯 Search in both keys and values
- ⚡ Regular expression support
- 🎨 Type-specific filtering
- 🎮 Flexible search targeting (keys only, values only, or both)
- 💪 Case-sensitive and exact match options
- 🌳 Smart nested object search
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

#### Case Sensitivity and Exact Matching
```dart
// Case-sensitive search
final caseSensitiveResults = JsonDeepSearch.search(
  jsonData,
  'Name',
  caseSensitive: true,
);

// Exact match search
final exactResults = JsonDeepSearch.search(
  jsonData,
  'John',
  exactMatch: true,
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

## Search Result Structure

Each search result includes:
- `path`: List of strings representing the path to the match
- `key`: The key where the match was found
- `value`: The value associated with the match
- `matchType`: Whether the match was found in a key or value (MatchType.key or MatchType.value)

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
  key,    // Match found in a key
  value   // Match found in a value
}
```

## Examples

### Complex Nested Search
```dart
final complexJson = {
  'users': [
    {
      'id': 1,
      'email': 'john@example.com',
      'preferences': {
        'theme': 'dark',
        'notifications': true
      }
    }
  ]
};

// Find all email addresses
final emailResults = JsonDeepSearch.search(
  complexJson,
  r'.*@.*\.com',
  useRegex: true,
  searchTarget: SearchTarget.valuesOnly,
);

// Find all boolean values
final boolResults = JsonDeepSearch.search(
  complexJson,
  'true',
  allowedTypes: {bool},
);
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
