// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'मेरी खबरें';

  @override
  String get newsFeedTitle => 'समाचार फ़ीड';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String welcomeMessage(Object username) {
    return 'स्वागत है, $username 👋';
  }

  @override
  String get guest => 'अतिथि';

  @override
  String get searchHint => 'समाचार लेख खोजें...';

  @override
  String searchHintCategory(Object category) {
    return '$category समाचार खोजें...';
  }

  @override
  String get savedArticles => 'सहेजे गए लेख';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get language => 'भाषा';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get noArticles => 'कोई समाचार लेख नहीं मिला।\nकोई अलग कीवर्ड आज़माएं!';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get readMore => 'और पढ़ें';

  @override
  String get permissionDenied => 'गैलरी तक पहुंचने की अनुमति अस्वीकृत।';

  @override
  String get noImageSelected => 'कोई छवि चयनित नहीं।';

  @override
  String imagePickError(Object error) {
    return 'छवि चुनने में विफल: $error';
  }

  @override
  String get noTitle => 'कोई शीर्षक उपलब्ध नहीं';

  @override
  String get noDescription => 'कोई विवरण उपलब्ध नहीं';

  @override
  String get unknownSource => 'अज्ञात';

  @override
  String get unknownDate => 'अज्ञात तारीख';

  @override
  String urlLaunchError(Object error) {
    return 'लेख खोलने में असमर्थ: $error';
  }

  @override
  String shareText(Object title) {
    return 'इस लेख को देखें: $title';
  }

  @override
  String get category_business => 'व्यवसाय';

  @override
  String get category_entertainment => 'मनोरंजन';

  @override
  String get category_general => 'सामान्य';

  @override
  String get category_health => 'स्वास्थ्य';

  @override
  String get category_science => 'विज्ञान';

  @override
  String get category_sports => 'खेल';

  @override
  String get category_technology => 'प्रौद्योगिकी';

  @override
  String category(Object categoryName) {
    return '$categoryName';
  }
}
