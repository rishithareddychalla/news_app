import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:login_page/models.dart';
import 'package:login_page/providers.dart';
import 'package:login_page/screens/category.dart';
import 'package:login_page/screens/profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends ConsumerStatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(searchQueryProvider) ?? '',
    ); // Null check
    _search.addListener(() {
      final query = _search.text;
      debugPrint('Search input: $query');
      ref.read(searchQueryProvider.notifier).state = query;
    });
    loadBookmarks(ref);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Exit the app when back button is pressed on HomePage
        return true; // Returning true allows the app to exit
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            l10n!.newsFeedTitle,
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
                                    : 'G', // Null check
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ).animate().scale(
                      duration: 300.ms,
                      curve: Curves.easeInOut,
                    ),
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
                  .read(articleProvider.notifier)
                  .fetchNews(searchQuery ?? ''), // Null check
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.welcomeMessage(widget.username), // Null check
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ).animate().fadeIn(duration: 500.ms, curve: Curves.easeIn),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                    suffixIcon:
                        searchQuery != null && searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.primary,
                              ),
                              onPressed: () {
                                _search.clear();
                                ref.read(searchQueryProvider.notifier).state =
                                    '';
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
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        {
                              'business': l10n.category_business,
                              'entertainment': l10n.category_entertainment,
                              'general': l10n.category_general,
                              'health': l10n.category_health,
                              'science': l10n.category_science,
                              'sports': l10n.category_sports,
                              'technology': l10n.category_technology,
                            }.entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0,
                                ),
                                child: ActionChip(
                                  label: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => CategoryPage(
                                              category: entry.key.toLowerCase(),
                                              username: widget.username,
                                            ),
                                      ),
                                    );
                                  },
                                ).animate().scale(
                                  duration: 200.ms,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final articleState = ref.watch(articleProvider);

                    if (articleState.isLoading) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 5,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder:
                            (_, __) => Shimmer.fromColors(
                              baseColor: colorScheme.surface.withOpacity(0.3),
                              highlightColor: colorScheme.surface.withOpacity(
                                0.1,
                              ),
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  height: 200,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      );
                    }

                    if (articleState.error.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '⚠️ ${articleState.error}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(articleProvider.notifier)
                                    .fetchNews(searchQuery ?? '');
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.retry),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (articleState.articles.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.noArticles,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: articleState.articles.length,
                      separatorBuilder:
                          (context, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final article = articleState.articles[index];
                        return _ArticleCard(article: article)
                            .animate()
                            .fadeIn(
                              duration: 500.ms,
                              delay: (index * 100).ms,
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
      ),
    );
  }
}

class _ArticleCard extends ConsumerWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBookmarked = ref
        .watch(bookmarkProvider)
        .any((a) => a.url == article.url);

    return InkWell(
      onTap: () async {
        if (article.url != null) {
          final uri = Uri.parse(article.url!); // Safe: checked for null
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n!.urlLaunchError(e.toString()))),
            );
          }
        }
      },
      child: Card(
        elevation: 8,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null)
              Stack(
                children: [
                  Hero(
                    tag: 'article-${article.url ?? 'default'}', // Null check
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!, // Safe: checked for null
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Shimmer.fromColors(
                            baseColor: colorScheme.surface.withOpacity(0.3),
                            highlightColor: colorScheme.surface.withOpacity(
                              0.1,
                            ),
                            child: Container(height: 200, color: Colors.white),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            height: 200,
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
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.cardColor.withOpacity(0.8),
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
                    article.title ?? l10n!.noTitle,
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
                    article.description ?? l10n!.noDescription,
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
                              l10n!.unknownSource, // Safe: null-aware access
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
                            ).format(
                              article.publishedAt!,
                            ) // Safe: checked for null
                            : l10n!.unknownDate,
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
                            final uri = Uri.parse(
                              article.url!,
                            ); // Safe: checked for null
                            try {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n!.urlLaunchError(e.toString()),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          l10n!.readMore,
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
                                  l10n!.shareText(
                                    article.title ?? l10n.noTitle,
                                  ),
                                  subject: article.title ?? l10n.noTitle,
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
