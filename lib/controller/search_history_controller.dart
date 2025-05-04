import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchHistoryController extends GetxController {
  final RxList<Map<String, dynamic>> searchHistory =
      <Map<String, dynamic>>[].obs;
  final RxList<String> searchQueries = <String>[].obs;
  final int maxHistoryItems = 20;

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
    loadSearchQueries();
  }

  Future<void> loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('search_post_history') ?? [];

      searchHistory.value = historyJson
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  Future<void> loadSearchQueries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      searchQueries.value = prefs.getStringList('search_queries') ?? [];
    } catch (e) {
      print('Error loading search queries: $e');
    }
  }

  Future<void> addToSearchHistory(Map<String, dynamic> post) async {
    try {
      // Check if post already exists in history
      final existingIndex =
          searchHistory.indexWhere((item) => item['id'] == post['id']);

      // Remove if exists (to move it to the top)
      if (existingIndex != -1) {
        searchHistory.removeAt(existingIndex);
      }

      // Add to the beginning of the list
      searchHistory.insert(0, post);

      // Trim list if it exceeds maximum items
      if (searchHistory.length > maxHistoryItems) {
        searchHistory.removeLast();
      }

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          searchHistory.map((item) => jsonEncode(item)).toList();

      await prefs.setStringList('search_post_history', historyJson);
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    try {
      // Check if query already exists
      final existingIndex = searchQueries.indexOf(query);

      // Remove if exists (to move it to the top)
      if (existingIndex != -1) {
        searchQueries.removeAt(existingIndex);
      }

      // Add to the beginning of the list
      searchQueries.insert(0, query);

      // Trim list if it exceeds 10 items
      if (searchQueries.length > 10) {
        searchQueries.removeLast();
      }

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_queries', searchQueries);
    } catch (e) {
      print('Error adding search query: $e');
    }
  }

  Future<void> removeSearchQuery(int index) async {
    try {
      if (index >= 0 && index < searchQueries.length) {
        searchQueries.removeAt(index);

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('search_queries', searchQueries);
      }
    } catch (e) {
      print('Error removing search query: $e');
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      searchHistory.clear();

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_post_history', []);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  Future<void> clearSearchQueries() async {
    try {
      searchQueries.clear();

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_queries', []);
    } catch (e) {
      print('Error clearing search queries: $e');
    }
  }
}
