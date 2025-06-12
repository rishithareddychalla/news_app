import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/models.dart';
import 'package:login_page/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends ConsumerWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _search = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('News Feed'), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, $username',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer(
              builder: (context, ref, child) {
                return TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search news...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Consumer(
                      builder: (context, ref, child) {
                        final query = ref.watch(searchQueryProvider);
                        return query.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                // Clear the search query
                                ref.read(searchQueryProvider.notifier).state =
                                    '';
                                _search.clear();
                              },
                            )
                            : const SizedBox.shrink();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onSubmitted: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                );
              },
            ),
          ),

          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final articleState = ref.watch(articleProvider);

                if (articleState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (articleState.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${articleState.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(articleProvider.notifier)
                                .fetchNews(ref.read(searchQueryProvider));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (articleState.articles.isEmpty) {
                  return const Center(child: Text('No articles found'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: articleState.articles.length,
                  itemBuilder: (context, index) {
                    final article = articleState.articles[index];
                    return _ArticleCard(article: article);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () async {
          if (article.url != null) ;
          {
            final uri = Uri.parse(article.url!);
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Failed to open Url: $e')));
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            if (article.urlToImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                ),
              ),
            // Article details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title ?? 'No title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    article.description ?? 'No description',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Source and published date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.source?.name ?? 'Unknown source',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      Text(
                        article.publishedAt != null
                            ? article.publishedAt!.toIso8601String().split(
                              'T',
                            )[0]
                            : 'Unknown date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
