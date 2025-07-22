import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:login_page/models.dart';

class NewsServices {
  static const String baseUrl = 'newsapi.org';
  static const String apiKey = '00cd6e8a40e74859bb3e3535eefb9f5e';

  Future<List<Article>> fetchNews(String query) async {
    try {
      final uri = Uri.https(baseUrl, '/v2/everything', {
        'q': query.isEmpty ? 'news' : query,
        'apiKey': apiKey,
      });
      final response = await http.get(uri);
      log('GET ${response.request?.url} -> ${response.statusCode}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final articlesJson = json['articles'] as List<dynamic>;
        final articles =
            articlesJson.map((item) => Article.fromJson(item)).toList();
        if (articles.isNotEmpty) {
          log('First Article Title: ${articles.first.title}');
        }
        return articles;
      } else {
        throw Exception(
          'Failed to load articles. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error fetching articles: $e');
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<List<Article>> fetchNewsByCategory(String category) async {
    try {
      final uri = Uri.https(baseUrl, '/v2/top-headlines', {
        'category': category,
        'country': 'us',
        'apiKey': apiKey,
      });

      final response = await http.get(uri);
      log('GET ${response.request?.url} -> ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'error') {
          throw Exception('API Error: ${json['message']}');
        }
        final articlesJson = json['articles'] as List<dynamic>;
        final articles =
            articlesJson.map((item) => Article.fromJson(item)).toList();
        if (articles.isNotEmpty) {
          log('Category [$category] -> First Article: ${articles.first.title}');
        }
        return articles;
      } else {
        throw Exception(
          'Failed to load category articles. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error fetching category articles: $e');
      throw Exception('Failed to load category articles: $e');
    }
  }
}
