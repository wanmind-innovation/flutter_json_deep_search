import 'package:flutter_json_deep_search/flutter_json_deep_search.dart';

class JsonDeepSearchHelper {
  static Map<String, dynamic> convertToJson(SearchResult result) {
    return result.toJson();
  }

  static List<Map<String, dynamic>> convertToJsonList(
      List<SearchResult> results) {
    return results.map((r) => r.toJson()).toList();
  }
}
