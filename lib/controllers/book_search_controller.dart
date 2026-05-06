import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/book.dart';

class BookSearchController extends GetxController {
  final TextEditingController textController = TextEditingController();
  Timer? _debounce;

  Map<int, Book> suggestions = {};
  Map<int, Book> results = {};
  bool isLoading = false;
  String searchText = '';

  @override
  void onClose() {
    textController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    searchText = query;
    update(['search_bar']);

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _fetchSuggestions(query);
      } else {
        clearSearch();
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    final apiResults = await BookSnapshot.searchByKeyword(query);
    suggestions = {for (var b in apiResults.take(6)) b.id: b};
    update(['search_suggestions']);
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;

    isLoading = true;
    update(['search_results']);

    final apiResults = await BookSnapshot.searchByKeyword(query);
    results = {for (var b in apiResults) b.id: b};

    isLoading = false;
    update(['search_results']);
  }

  void clearSearch() {
    textController.clear();
    searchText = '';
    suggestions.clear();
    update(['search_bar', 'search_suggestions']);
  }
}