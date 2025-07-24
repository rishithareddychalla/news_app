// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My News';

  @override
  String get newsFeedTitle => 'News Feed';

  @override
  String get profileTitle => 'Profile';

  @override
  String welcomeMessage(Object username) {
    return 'Welcome, $username 👋';
  }

  @override
  String get guest => 'Guest';

  @override
  String get searchHint => 'Search news articles...';

  @override
  String searchHintCategory(Object category) {
    return 'Search $category news...';
  }

  @override
  String get savedArticles => 'Saved Articles';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Logout';

  @override
  String get noArticles => 'No news articles found.\nTry a different keyword!';

  @override
  String get retry => 'Retry';

  @override
  String get readMore => 'Read More';

  @override
  String get permissionDenied => 'Permission denied to access gallery.';

  @override
  String get noImageSelected => 'No image selected.';

  @override
  String imagePickError(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get noTitle => 'No title available';

  @override
  String get noDescription => 'No description provided';

  @override
  String get unknownSource => 'Unknown';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String urlLaunchError(Object error) {
    return 'Could not open the article: $error';
  }

  @override
  String shareText(Object title) {
    return 'Check out this article: $title';
  }

  @override
  String get category_business => 'Business';

  @override
  String get category_entertainment => 'Entertainment';

  @override
  String get category_general => 'General';

  @override
  String get category_health => 'Health';

  @override
  String get category_science => 'Science';

  @override
  String get category_sports => 'Sports';

  @override
  String get category_technology => 'Technology';

  @override
  String category(Object categoryName) {
    return '$categoryName';
  }
}
