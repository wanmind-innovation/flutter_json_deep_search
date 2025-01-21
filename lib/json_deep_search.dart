import 'package:flutter/foundation.dart' show listEquals;

/// A utility class for performing deep search operations on JSON data
class JsonDeepSearch {
  /// Performs a deep search in JSON data for a given query
  /// Returns a list of matches with their paths
  static List<SearchResult> search(
    dynamic jsonData,
    String query, {
    bool caseSensitive = false,
    bool exactMatch = false,
    bool useRegex = false,
    Set<Type>? allowedTypes,
    SearchTarget searchTarget = SearchTarget.both,
    Map<String, String>? nestedSearch,
  }) {
    final results = <SearchResult>[];
    _searchRecursive(
      jsonData,
      query,
      [],
      results,
      caseSensitive: caseSensitive,
      exactMatch: exactMatch,
      useRegex: useRegex,
      allowedTypes: allowedTypes,
      searchTarget: searchTarget,
      nestedSearch: nestedSearch,
    );
    return results;
  }

  /// Recursive helper function to traverse JSON structure
  static void _searchRecursive(
    dynamic data,
    String query,
    List<String> currentPath,
    List<SearchResult> results, {
    bool caseSensitive = false,
    bool exactMatch = false,
    bool useRegex = false,
    Set<Type>? allowedTypes,
    SearchTarget searchTarget = SearchTarget.both,
    Map<String, String>? nestedSearch,
  }) {
    if (data == null) return;

    // Check if we should search in nested object
    if (nestedSearch != null && currentPath.isNotEmpty) {
      final currentKey = currentPath.last;
      final searchField = nestedSearch[currentKey];
      if (searchField != null && data is Map) {
        final nestedValue = data[searchField];
        if (nestedValue != null) {
          if (_matchesQuery(nestedValue.toString(), query,
              caseSensitive: caseSensitive,
              exactMatch: exactMatch,
              useRegex: useRegex)) {
            results.add(SearchResult(
              path: [...currentPath, searchField],
              key: searchField,
              value: nestedValue,
              matchType: MatchType.nestedValue,
            ));
          }
          return; // Skip further processing for this object
        }
      }
    }

    // Handle different data types
    if (data is Map) {
      data.forEach((key, value) {
        // Check if the key contains the search query
        if (searchTarget != SearchTarget.valuesOnly &&
            _matchesQuery(key.toString(), query,
                caseSensitive: caseSensitive,
                exactMatch: exactMatch,
                useRegex: useRegex)) {
          results.add(SearchResult(
            path: [...currentPath, key.toString()],
            key: key.toString(),
            value: value,
            matchType: MatchType.key,
          ));
        }

        // Recurse into nested objects
        _searchRecursive(
          value,
          query,
          [...currentPath, key.toString()],
          results,
          caseSensitive: caseSensitive,
          exactMatch: exactMatch,
          useRegex: useRegex,
          allowedTypes: allowedTypes,
          searchTarget: searchTarget,
          nestedSearch: nestedSearch,
        );
      });
    } else if (data is List) {
      // Handle arrays
      for (var i = 0; i < data.length; i++) {
        _searchRecursive(
          data[i],
          query,
          [...currentPath, i.toString()],
          results,
          caseSensitive: caseSensitive,
          exactMatch: exactMatch,
          useRegex: useRegex,
          allowedTypes: allowedTypes,
          searchTarget: searchTarget,
          nestedSearch: nestedSearch,
        );
      }
    } else {
      // Handle primitive values (String, num, bool)
      if (allowedTypes != null && !allowedTypes.contains(data.runtimeType)) {
        return;
      }

      if (searchTarget != SearchTarget.keysOnly) {
        final stringValue = data.toString();
        if (_matchesQuery(stringValue, query,
            caseSensitive: caseSensitive,
            exactMatch: exactMatch,
            useRegex: useRegex)) {
          results.add(SearchResult(
            path: currentPath,
            key: currentPath.isEmpty ? '' : currentPath.last,
            value: data,
            matchType: MatchType.value,
          ));
        }
      }
    }
  }

  /// Helper function to check if a string matches the query
  static bool _matchesQuery(
    String text,
    String query, {
    bool caseSensitive = false,
    bool exactMatch = false,
    bool useRegex = false,
  }) {
    if (!caseSensitive) {
      text = text.toLowerCase();
      query = query.toLowerCase();
    }

    if (useRegex) {
      try {
        final regex = RegExp(query, caseSensitive: caseSensitive);
        return regex.hasMatch(text);
      } catch (e) {
        return false; // Invalid regex pattern
      }
    }

    if (exactMatch) {
      return text == query;
    }
    return text.contains(query);
  }
}

/// Enum to identify whether the match was found in a key or value
enum MatchType { key, value, nestedValue }

/// Enum to specify search target (keys, values, or both)
enum SearchTarget { keysOnly, valuesOnly, both }

/// Class to represent a search result
class SearchResult {
  final List<String> path;
  final String key;
  final dynamic value;
  final MatchType matchType;

  const SearchResult({
    required this.path,
    required this.key,
    required this.value,
    required this.matchType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResult &&
        listEquals(path, other.path) &&
        key == other.key &&
        value == other.value &&
        matchType == other.matchType;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(path),
        key,
        value,
        matchType,
      );

  @override
  String toString() =>
      'SearchResult(path: ${path.join('/')}, key: $key, value: $value, matchType: $matchType)';

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'key': key,
      'value': value,
      'matchType': matchType.toString(),
    };
  }
}
