// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mis Noticias';

  @override
  String get newsFeedTitle => 'Feed de Noticias';

  @override
  String get profileTitle => 'Perfil';

  @override
  String welcomeMessage(Object username) {
    return 'Bienvenido, $username 👋';
  }

  @override
  String get guest => 'Invitado';

  @override
  String get searchHint => 'Buscar artículos de noticias...';

  @override
  String searchHintCategory(Object category) {
    return 'Buscar noticias de $category...';
  }

  @override
  String get savedArticles => 'Artículos Guardados';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get noArticles => 'No se encontraron artículos de noticias.\n¡Prueba una palabra clave diferente!';

  @override
  String get retry => 'Reintentar';

  @override
  String get readMore => 'Leer Más';

  @override
  String get permissionDenied => 'Permiso denegado para acceder a la galería.';

  @override
  String get noImageSelected => 'No se seleccionó ninguna imagen.';

  @override
  String imagePickError(Object error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String get noTitle => 'No hay título disponible';

  @override
  String get noDescription => 'No hay descripción disponible';

  @override
  String get unknownSource => 'Desconocido';

  @override
  String get unknownDate => 'Fecha desconocida';

  @override
  String urlLaunchError(Object error) {
    return 'No se pudo abrir el artículo: $error';
  }

  @override
  String shareText(Object title) {
    return 'Mira este artículo: $title';
  }

  @override
  String get category_business => 'Negocios';

  @override
  String get category_entertainment => 'Entretenimiento';

  @override
  String get category_general => 'General';

  @override
  String get category_health => 'Salud';

  @override
  String get category_science => 'Ciencia';

  @override
  String get category_sports => 'Deportes';

  @override
  String get category_technology => 'Tecnología';

  @override
  String category(Object categoryName) {
    return '$categoryName';
  }
}
