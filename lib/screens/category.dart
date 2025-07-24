import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/l10n/app_localizations.dart';
import 'package:login_page/models.dart';
import 'package:login_page/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:login_page/screens/profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class CategoryPage extends ConsumerStatefulWidget {
  final String category;
  final String username;
  const CategoryPage({
    super.key,
    required this.category,
    required this.username,
  });

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  late TextEditingController _searchController;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query != _lastQuery) {
        _lastQuery = query;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_searchController.text == query && mounted) {
            debugPrint('Search query for category ${widget.category}: $query');
            ref.read(searchQueryProvider.notifier).state = query;
          }
        });
      }
    });
    loadBookmarks(ref);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryProvider(widget.category));
    final searchQuery = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.category(widget.category) ??
              '${widget.category[0].toUpperCase()}${widget.category.substring(1)} News',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: colorScheme.onPrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer(
              builder: (context, ref, _) {
                final imagePath = ref.watch(profileImageProvider);
                final hasImage =
                    imagePath != null && File(imagePath).existsSync();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    radius: 20,
                    backgroundImage:
                        hasImage ? FileImage(File(imagePath)) : null,
                    child:
                        hasImage
                            ? null
                            : Text(
                              widget.username.isNotEmpty
                                  ? widget.username[0].toUpperCase()
                                  : 'G',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh:
            () => ref
                .read(categoryProvider(widget.category.toLowerCase()).notifier)
                .fetchCategoryNews(query: searchQuery),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      l10n?.searchHintCategory(widget.category) ??
                      'Search ${widget.category} news... ✍️',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: colorScheme.primary),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                          : null,
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (value) {
                  debugPrint('TextField onChanged: $value');
                },
              ).animate().slideY(
                begin: 0.2,
                end: 0,
                duration: 300.ms,
                curve: Curves.easeInOut,
              ),
            ),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (state.isLoading) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder:
                          (_, __) => Shimmer.fromColors(
                            baseColor: colorScheme.surface.withOpacity(0.3),
                            highlightColor: colorScheme.surface.withOpacity(
                              0.1,
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                height: 220,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    );
                  }
                  if (state.error.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '⚠️ ${state.error}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(
                                    categoryProvider(
                                      widget.category.toLowerCase(),
                                    ).notifier,
                                  )
                                  .fetchCategoryNews(query: searchQuery);
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n?.retry ?? 'Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state.articles.isEmpty) {
                    return Center(
                      child: Text(
                        l10n?.noArticles ??
                            'No articles found for this category.\nTry a different keyword!',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.articles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      log(
                        'Rendering article ${i + 1}/${state.articles.length}: ${state.articles[i].title ?? 'No title'}',
                      );
                      return ArticleCard(article: state.articles[i])
                          .animate()
                          .fadeIn(
                            duration: 500.ms,
                            delay: (i * 100).ms,
                            curve: Curves.easeInOut,
                          )
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeInOut,
                          );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleCard extends ConsumerWidget {
  final Article article;
  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBookmarked = ref
        .watch(bookmarkProvider)
        .any((a) => a.url == article.url);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (article.url != null) {
            final uri = Uri.parse(article.url!);
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n?.urlLaunchError(e.toString()) ??
                        'Could not open the article: $e',
                  ),
                ),
              );
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null)
              Stack(
                children: [
                  Hero(
                    tag: 'article-${article.url ?? 'default'}',
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Shimmer.fromColors(
                            baseColor: colorScheme.surface.withOpacity(0.3),
                            highlightColor: colorScheme.surface.withOpacity(
                              0.1,
                            ),
                            child: Container(height: 220, color: Colors.white),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            height: 220,
                            color: colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: colorScheme.primary,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            colorScheme.surface.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? l10n?.noTitle ?? 'No title available',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description ??
                        l10n?.noDescription ??
                        'No description provided',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          article.source?.name ??
                              l10n?.unknownSource ??
                              'Unknown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        article.publishedAt != null
                            ? DateFormat.yMMMd(
                              Localizations.localeOf(context).languageCode,
                            ).format(article.publishedAt!)
                            : l10n?.unknownDate ?? 'Unknown date',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (article.url != null) {
                            final uri = Uri.parse(article.url!);
                            try {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n?.urlLaunchError(e.toString()) ??
                                        'Could not open the article: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          l10n?.readMore ?? 'Read More',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.share, color: colorScheme.primary),
                            onPressed: () {
                              if (article.url != null) {
                                Share.share(
                                  l10n?.shareText(
                                        article.title ??
                                            l10n?.noTitle ??
                                            'No title',
                                      ) ??
                                      'Check out this article: ${article.title ?? 'No title'}',
                                  subject:
                                      article.title ??
                                      l10n?.noTitle ??
                                      'No title',
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: colorScheme.primary,
                            ),
                            onPressed: () => toggleBookmark(ref, article),
                          ),
                        ],
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
