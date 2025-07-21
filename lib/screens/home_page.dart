import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/models.dart';
import 'package:login_page/providers.dart';
import 'package:login_page/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends ConsumerWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _search = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('📰 News Feed'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.onBackground,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FutureBuilder<String?>(
              future: SharedPreferences.getInstance().then(
                (prefs) => prefs.getString('profileImagePath'),
              ),
              builder: (context, snapshot) {
                final imagePath = snapshot.data;
                final hasImage =
                    imagePath != null && File(imagePath).existsSync();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ).then((_) {
                      // Rebuild HomePage after returning from ProfilePage
                      (context as Element).reassemble();
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage:
                        hasImage ? FileImage(File(imagePath!)) : null,
                    child:
                        hasImage
                            ? null
                            : Text(
                              username[0].toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome, $username 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _search,
              onChanged:
                  (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search news articles... ✍️',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    ref.watch(searchQueryProvider).isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                        : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final articleState = ref.watch(articleProvider);

                if (articleState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (articleState.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⚠️ ${articleState.error}'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(articleProvider.notifier)
                                .fetchNews(ref.read(searchQueryProvider));
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (articleState.articles.isEmpty) {
                  return const Center(
                    child: Text(
                      'No news articles found. Try a different keyword!',
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: articleState.articles.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 16),
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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return InkWell(
      onTap: () async {
        if (article.url != null) {
          final uri = Uri.parse(article.url!);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open the article: $e')),
            );
          }
        }
      },
      child: Card(
        elevation: 6,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null)
              CachedNetworkImage(
                imageUrl: article.urlToImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 200,
                      color: theme.colorScheme.surfaceVariant,
                      child: const Icon(Icons.broken_image),
                    ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? 'No title available',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description ?? 'No description provided',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.source?.name ?? 'Unknown',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        article.publishedAt?.toLocal().toString().split(
                              ' ',
                            )[0] ??
                            'Unknown date',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
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
