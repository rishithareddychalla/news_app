// // Provider for the search query (holds the text typed in the search bar)
// // This is a simple provider that stores a String and updates when the user types
// final searchQueryProvider = StateProvider<String>((ref) => '');

// // Notifier to manage the state of news articles (loading, data, or error)
// // This handles fetching articles from ApiServices and updating the UI
// class NewsStateNotifier extends StateNotifier<AsyncValue<List<Article>>> {
//   // Fields: ref to access other providers, apiServices to fetch data
//   final Ref ref;
//   final NewsServices _apiServices;

//   // Constructor: Initializes state to an empty list and fetches initial articles
//   NewsStateNotifier(this.ref, this._apiServices) : super(AsyncValue.data([])) {
//     // Watch the search query provider and fetch articles when it changes
//     fetchNews(ref.watch(searchQueryProvider));
//   }

//   // Method to fetch articles for a given query
//   Future<void> fetchNews(String query) async {
//     // Set state to loading (shows a spinner in the UI)
//     state = AsyncValue.loading();
//     try {
//       // Call ApiServices to fetch articles
//       final articles = await _apiServices.fetchNews(query);
//       // Update state with the fetched articles
//       state = AsyncValue.data(articles);
//     } catch (e, stackTrace) {
//       // If an error occurs (e.g., network issue, API failure), update state with error
//       state = AsyncValue.error(e, stackTrace);
//     }
//   }
// }

// // Provider for the NewsStateNotifier
// // This makes NewsStateNotifier available to the app and passes dependencies
// final newsProvider = StateNotifierProvider<NewsStateNotifier, AsyncValue<List<Article>>>(
//   (ref) => NewsStateNotifier(ref, NewsServices()),
// );

// class ArticleState{
//     final List<Article> articles;
//     final bool isLoading;
//     final String error;

//     ArticleState({
//         this.articles=const[],
//         this.isLoading = false,
//         this.error="",
//     });
//     ArticleState copyWith({
//         List<Article>? posts,
//         bool? isLoading,
//         String? error,
//     }) {
//         return ArticleState(
//             articles: articles?? this.articles,
//             isLoading:isLoading??this.isLoading,
//             error: error?? this.error,
//         );
//     }
// }

// class ArticleNotifier extends StateNotifier<ArticleState>{
//     final NewsServices _newsService;

//     ArticleNotifier(this._newsService): super(ArticleState()){
//         fetchNews();

//     }
//     Future <void> fetchNews() async{
//         try{
//             state = state.copyWith(isLoading: true,error:"");
//             final articles = await _newsService.fetchNews();
//             state =state.copyWith(isLoading:true,error:"");
//         }catch(e){
//             log('Error fetching posts: $e');
//             state = state.copyWith(error: 'Failed to load articles', isLoading:false);
//         }
//     }
// }
// final articleProvider = StateNotifierProvider<ArticleNotifier, ArticleState>((ref){
//     return ArticleNotifier(NewsServices());
// });

// // Provider for the search query (holds the text typed in the search bar)
// final searchQueryProvider = StateProvider<String>((ref) => '');

// // State class to hold articles, loading status, and error
// class ArticleState {
//   final List<Article> articles;
//   final bool isLoading;
//   final String error;

//   ArticleState({
//     this.articles = const [],
//     this.isLoading = false,
//     this.error = '',
//   });

//   ArticleState copyWith({
//     List<Article>? articles,
//     bool? isLoading,
//     String? error,
//   }) {
//     return ArticleState(
//       articles: articles ?? this.articles,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//     );
//   }
// }

// // Notifier to manage article state (fetching articles and updating state)
// class ArticleNotifier extends StateNotifier<ArticleState> {
//   final Ref ref;
//   final NewsServices _apiServices;

//   ArticleNotifier(this.ref, this._apiServices) : super(ArticleState()) {
//     // Watch the search query and fetch articles when it changes
//     fetchNews(ref.watch(searchQueryProvider));
//   }

//   Future<void> fetchNews(String query) async {
//     try {
//       // Set loading state
//       state = state.copyWith(isLoading: true, error: '');
//       // Fetch articles (handle empty query)
//       final articles = await _apiServices.fetchNews(query.isEmpty ? 'news' : query);
//       // Update state with articles
//       state = state.copyWith(articles: articles, isLoading: false, error: '');
//     } catch (e) {
//       log('Error fetching articles: $e');
//       // Update state with error
//       state = state.copyWith(error: 'Failed to load articles', isLoading: false);
//     }
//   }
// }

// // Provider for ArticleNotifier
// final articleProvider = StateNotifierProvider<ArticleNotifier, ArticleState>((ref) {
//   return ArticleNotifier(ref, NewsServices());
// });

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

// Provider for ArticleNotifier
final articleProvider = StateNotifierProvider<ArticleNotifier, ArticleState>((
  ref,
) {
  return ArticleNotifier(ref, NewsServices());
});
