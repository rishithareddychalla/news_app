import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/api_services.dart';
import 'package:login_page/models.dart';
import 'package:flutter/material.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final searchQueryProvider = StateProvider<String>((ref) => '');

class ArticleState {
  final List<Article> articles;
  final bool isLoading;
  final String error;

  ArticleState({
    this.articles = const [],
    this.isLoading = false,
    this.error = '',
  });

  ArticleState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? error,
  }) {
    return ArticleState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ArticleNotifier extends StateNotifier<ArticleState> {
  final Ref ref;
  final NewsServices _apiServices;

  ArticleNotifier(this.ref, this._apiServices) : super(ArticleState()) {
    fetchNews(ref.watch(searchQueryProvider));
  }

  Future<void> fetchNews(String query) async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: '');
      // Fetch articles (handle empty query)
      final articles = await _apiServices.fetchNews(
        query.isEmpty ? 'news' : query,
      );
      // Update state with articles
      state = state.copyWith(articles: articles, isLoading: false, error: '');
    } catch (e) {
      log('Error fetching articles: $e');
      // Update state with error
      state = state.copyWith(
        error: 'Failed to load articles',
        isLoading: false,
      );
    }
  }
}

class CategoryNotifier extends StateNotifier<ArticleState> {
  final String category;
  final NewsServices _apiService;

  CategoryNotifier(this.category, this._apiService) : super(ArticleState()) {
    log('Initializing CategoryNotifier for category: $category');
    fetchCategoryNews();
  }

  Future<void> fetchCategoryNews() async {
    try {
      log('Fetching news for category: $category');
      state = state.copyWith(isLoading: true, error: '');
      final articles = await _apiService.fetchNewsByCategory(category);
      log('Fetched ${articles.length} articles for category: $category');
      state = state.copyWith(articles: articles, isLoading: false);
    } catch (e) {
      log('Error fetching $category news: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load $category news: $e',
      );
    }
  }
}

// Provider for ArticleNotifier
final articleProvider = StateNotifierProvider<ArticleNotifier, ArticleState>((
  ref,
) {
  return ArticleNotifier(ref, NewsServices());
});
final categoryProvider =
    StateNotifierProvider.family<CategoryNotifier, ArticleState, String>(
      (ref, category) => CategoryNotifier(category, NewsServices()),
    );
