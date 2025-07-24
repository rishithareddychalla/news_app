import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/l10n/app_localizations.dart';
import 'package:login_page/models.dart';
import 'package:login_page/providers.dart';
import 'package:login_page/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class SavedArticlesPage extends ConsumerStatefulWidget {
  const SavedArticlesPage({super.key});

  @override
  ConsumerState<SavedArticlesPage> createState() => _SavedArticlesPageState();
}

class _SavedArticlesPageState extends ConsumerState<SavedArticlesPage> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(bookmarkProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.savedArticles ?? 'Saved Articles',
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
                              _username.isNotEmpty
                                  ? _username[0].toUpperCase()
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
        onRefresh: () => loadBookmarks(ref),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n?.welcomeMessage(
                        _username.isNotEmpty ? _username : "Guest",
                      ) ??
                      'Welcome, ${_username.isNotEmpty ? _username : 'Guest'}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                  ),
                ).animate().fadeIn(duration: 500.ms, curve: Curves.easeIn),
              ),
            ),
            Expanded(
              child:
                  bookmarks.isEmpty
                      ? Center(
                        child: Text(
                          l10n?.noArticles ?? 'No news articles found.',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: bookmarks.length,
                        separatorBuilder:
                            (context, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final article = bookmarks[index];
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
                      ),
            ),
          ],
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
          final uri = Uri.parse(article.url!);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.urlLaunchError(e.toString()) ??
                      'Could not open article: $e',
                ),
              ),
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
                    tag: 'article-${article.url ?? 'default'}',
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage!,
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
                    article.title ?? l10n?.noTitle ?? 'No title',
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
                        'No description',
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
                                        'Could not open article: $e',
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
