import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_json_deep_search/flutter_json_deep_search.dart';

void main() {
  group('JsonDeepSearch Tests', () {
    final Map<String, dynamic> testJson = {
      'name': 'John',
      'age': 30,
      'address': {
        'street': 'Main St',
        'number': 123,
        'city': {'name': 'New York', 'country': 'USA'}
      },
      'contacts': [
        {'type': 'email', 'value': 'john@example.com'},
        {'type': 'phone', 'value': '1234567890'}
      ]
    };

    test('should find simple key-value', () {
      final result = JsonDeepSearch.search(testJson, 'name');
      expect(result, const [
        SearchResult(
            path: ['name'],
            key: 'name',
            value: 'John',
            matchType: MatchType.key),
        SearchResult(
          path: ['address', 'city', 'name'],
          key: 'name',
          value: 'New York',
          matchType: MatchType.key,
        ),
      ]);
    });

    test('should find nested value', () {
      final result = JsonDeepSearch.search(testJson, 'country');
      expect(result, const [
        SearchResult(
          path: ['address', 'city', 'country'],
          key: 'country',
          value: 'USA',
          matchType: MatchType.key,
        ),
      ]);
    });

    test('should find value in array', () {
      final result = JsonDeepSearch.search(testJson, 'type');
      expect(result, const [
        SearchResult(
          path: ['contacts', '0', 'type'],
          key: 'type',
          value: 'email',
          matchType: MatchType.key,
        ),
        SearchResult(
          path: ['contacts', '1', 'type'],
          key: 'type',
          value: 'phone',
          matchType: MatchType.key,
        ),
      ]);
    });

    test('should return empty list when key not found', () {
      final result = JsonDeepSearch.search(testJson, 'nonexistent');
      expect(result, isEmpty);
    });

    test('should handle null input', () {
      final result = JsonDeepSearch.search(null, 'test');
      expect(result, isEmpty);
    });

    test('should find value with exact match', () {
      final result = JsonDeepSearch.search(testJson, 'value', exactMatch: true);
      expect(result, const [
        SearchResult(
          path: ['contacts', '0', 'value'],
          key: 'value',
          value: 'john@example.com',
          matchType: MatchType.key,
        ),
        SearchResult(
          path: ['contacts', '1', 'value'],
          key: 'value',
          value: '1234567890',
          matchType: MatchType.key,
        ),
      ]);
    });

    test('should find value with case sensitive search', () {
      final result =
          JsonDeepSearch.search(testJson, 'NAME', caseSensitive: true);
      expect(result, isEmpty);
    });

    group('Basic Search Tests', () {
      // ... existing tests ...
    });

    group('Regex Search Tests', () {
      test('should find matches using regex pattern', () {
        final result = JsonDeepSearch.search(
          testJson,
          r'.*@.*\.com',
          useRegex: true,
        );
        expect(result, const [
          SearchResult(
            path: ['contacts', '0', 'value'],
            key: 'value',
            value: 'john@example.com',
            matchType: MatchType.value,
          ),
        ]);
      });

      test('should handle invalid regex pattern gracefully', () {
        final result = JsonDeepSearch.search(
          testJson,
          r'[invalid',
          useRegex: true,
        );
        expect(result, isEmpty);
      });
    });

    group('Type Filtering Tests', () {
      test('should only find number values', () {
        final result = JsonDeepSearch.search(
          testJson,
          '123',
          allowedTypes: {int},
        );
        expect(result, const [
          SearchResult(
            path: ['address', 'number'],
            key: 'number',
            value: 123,
            matchType: MatchType.value,
          ),
        ]);
      });

      test('should only find string values', () {
        final result = JsonDeepSearch.search(
          testJson,
          'New',
          allowedTypes: {String},
        );
        expect(result, const [
          SearchResult(
            path: ['address', 'city', 'name'],
            key: 'name',
            value: 'New York',
            matchType: MatchType.value,
          ),
        ]);
      });
    });

    group('Search Target Tests', () {
      test('should only search in keys', () {
        final result = JsonDeepSearch.search(
          testJson,
          'type',
          searchTarget: SearchTarget.keysOnly,
        );
        expect(result, const [
          SearchResult(
            path: ['contacts', '0', 'type'],
            key: 'type',
            value: 'email',
            matchType: MatchType.key,
          ),
          SearchResult(
            path: ['contacts', '1', 'type'],
            key: 'type',
            value: 'phone',
            matchType: MatchType.key,
          ),
        ]);
      });

      test('should only search in values', () {
        final result = JsonDeepSearch.search(
          testJson,
          'York',
          searchTarget: SearchTarget.valuesOnly,
        );
        expect(result, const [
          SearchResult(
            path: ['address', 'city', 'name'],
            key: 'name',
            value: 'New York',
            matchType: MatchType.value,
          ),
        ]);
      });
    });

    group('Nested Search Tests', () {
      final nestedJson = {
        'users': [
          {
            'id': 1,
            'profile': {
              'displayName': 'John Doe',
              'username': 'johnd',
              'contact': {'email': 'john@example.com', 'phone': '1234567890'}
            },
            'settings': {'theme': 'dark', 'notifications': true}
          },
          {
            'id': 2,
            'profile': {
              'displayName': 'Jane Smith',
              'username': 'janes',
              'contact': {'email': 'jane@example.com', 'phone': '0987654321'}
            }
          }
        ],
        'metadata': {'lastUpdate': '2024-01-01'}
      };

      test('should find value in nested object with specific path', () {
        final result = JsonDeepSearch.search(
          nestedJson,
          'John',
          nestedSearch: {'profile': 'displayName'},
        );
        expect(result, const [
          SearchResult(
            path: ['users', '0', 'profile', 'displayName'],
            key: 'displayName',
            value: 'John Doe',
            matchType: MatchType.nestedValue,
          ),
        ]);
      });

      test('should find multiple values in nested objects', () {
        final result = JsonDeepSearch.search(
          nestedJson,
          'example.com',
          nestedSearch: {'contact': 'email'},
        );
        expect(result, const [
          SearchResult(
            path: ['users', '0', 'profile', 'contact', 'email'],
            key: 'email',
            value: 'john@example.com',
            matchType: MatchType.nestedValue,
          ),
          SearchResult(
            path: ['users', '1', 'profile', 'contact', 'email'],
            key: 'email',
            value: 'jane@example.com',
            matchType: MatchType.nestedValue,
          ),
        ]);
      });

      test('should handle multiple nested search paths', () {
        final result = JsonDeepSearch.search(
          nestedJson,
          'dark',
          nestedSearch: {
            'settings': 'theme',
            'profile': 'displayName',
          },
        );
        expect(result, const [
          SearchResult(
            path: ['users', '0', 'settings', 'theme'],
            key: 'theme',
            value: 'dark',
            matchType: MatchType.nestedValue,
          ),
        ]);
      });

      test('should handle case sensitivity in nested search', () {
        final result = JsonDeepSearch.search(
          nestedJson,
          'JOHN',
          nestedSearch: {'profile': 'displayName'},
          caseSensitive: true,
        );
        expect(result, isEmpty);

        final resultInsensitive = JsonDeepSearch.search(
          nestedJson,
          'JOHN',
          nestedSearch: {'profile': 'displayName'},
          caseSensitive: false,
        );
        expect(resultInsensitive, const [
          SearchResult(
            path: ['users', '0', 'profile', 'displayName'],
            key: 'displayName',
            value: 'John Doe',
            matchType: MatchType.nestedValue,
          ),
        ]);
      });

      test('should handle regex in nested search', () {
        final result = JsonDeepSearch.search(
          nestedJson,
          r'.*@example\.com',
          nestedSearch: {'contact': 'email'},
          useRegex: true,
        );
        expect(result, const [
          SearchResult(
            path: ['users', '0', 'profile', 'contact', 'email'],
            key: 'email',
            value: 'john@example.com',
            matchType: MatchType.nestedValue,
          ),
          SearchResult(
            path: ['users', '1', 'profile', 'contact', 'email'],
            key: 'email',
            value: 'jane@example.com',
            matchType: MatchType.nestedValue,
          ),
        ]);
      });

      test('should handle exact match in nested search', () {
        final result = JsonDeepSearch.search(
          nestedJson,
          'John Doe',
          nestedSearch: {'profile': 'displayName'},
          exactMatch: true,
        );
        expect(result, const [
          SearchResult(
            path: ['users', '0', 'profile', 'displayName'],
            key: 'displayName',
            value: 'John Doe',
            matchType: MatchType.nestedValue,
          ),
        ]);

        final partialResult = JsonDeepSearch.search(
          nestedJson,
          'John',
          nestedSearch: {'profile': 'displayName'},
          exactMatch: true,
        );
        expect(partialResult, isEmpty);
      });

      test('should handle non-existent nested paths gracefully', () {
        final result = JsonDeepSearch.search(
          nestedJson,
          'test',
          nestedSearch: {'nonexistent': 'field'},
        );
        expect(result, isEmpty);
      });

      test('should handle null values in nested objects', () {
        final jsonWithNull = {
          'user': {
            'profile': null,
            'settings': {'theme': 'light'}
          }
        };

        final result = JsonDeepSearch.search(
          jsonWithNull,
          'test',
          nestedSearch: {'profile': 'displayName'},
        );
        expect(result, isEmpty);
      });
    });
  });
}
