import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ee.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_kbp.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ee'),
    Locale('fr'),
    Locale('kbp'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'PulseAI'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @signupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get signupTitle;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'SE CONNECTER'**
  String get loginButton;

  /// No description provided for @googleLogin.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get googleLogin;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// No description provided for @homeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get homeTitle;

  /// No description provided for @diagnosisTitle.
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic'**
  String get diagnosisTitle;

  /// No description provided for @hospitalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Hôpital'**
  String get hospitalTitle;

  /// No description provided for @scanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scan'**
  String get scanTitle;

  /// No description provided for @chatTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lyra'**
  String get chatTitle;

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get hello;

  /// No description provided for @healthSnapshot.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu Santé'**
  String get healthSnapshot;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get height;

  /// No description provided for @bloodGroup.
  ///
  /// In fr, this message translates to:
  /// **'Groupe sanguin'**
  String get bloodGroup;

  /// No description provided for @ruralDiag.
  ///
  /// In fr, this message translates to:
  /// **'RURAL DIAG'**
  String get ruralDiag;

  /// No description provided for @ruralDiagDesc.
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic\nintelligent et rapide'**
  String get ruralDiagDesc;

  /// No description provided for @smartHosp.
  ///
  /// In fr, this message translates to:
  /// **'SMARTHOSP'**
  String get smartHosp;

  /// No description provided for @smartHospDesc.
  ///
  /// In fr, this message translates to:
  /// **'Centre médical\nle plus proche'**
  String get smartHospDesc;

  /// No description provided for @medScan.
  ///
  /// In fr, this message translates to:
  /// **'MED SCAN'**
  String get medScan;

  /// No description provided for @medScanDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre\nmédicament'**
  String get medScanDesc;

  /// No description provided for @lyraDesc.
  ///
  /// In fr, this message translates to:
  /// **'Assistant de\nsanté mentale'**
  String get lyraDesc;

  /// No description provided for @describeSymptoms.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez ce que vous ressentez...'**
  String get describeSymptoms;

  /// No description provided for @analyze.
  ///
  /// In fr, this message translates to:
  /// **'LANCER L\'ANALYSE'**
  String get analyze;

  /// No description provided for @frequentSymptoms.
  ///
  /// In fr, this message translates to:
  /// **'Symptômes fréquents'**
  String get frequentSymptoms;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get seeAll;

  /// No description provided for @seeLess.
  ///
  /// In fr, this message translates to:
  /// **'Voir moins'**
  String get seeLess;

  /// No description provided for @searchHospital.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un hôpital...'**
  String get searchHospital;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get all;

  /// No description provided for @emergency.
  ///
  /// In fr, this message translates to:
  /// **'Urgences'**
  String get emergency;

  /// No description provided for @cardiology.
  ///
  /// In fr, this message translates to:
  /// **'Cardiologie'**
  String get cardiology;

  /// No description provided for @pediatrics.
  ///
  /// In fr, this message translates to:
  /// **'Pédiatrie'**
  String get pediatrics;

  /// No description provided for @neurology.
  ///
  /// In fr, this message translates to:
  /// **'Neurologie'**
  String get neurology;

  /// No description provided for @general.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get general;

  /// No description provided for @maternity.
  ///
  /// In fr, this message translates to:
  /// **'Maternité'**
  String get maternity;

  /// No description provided for @dentist.
  ///
  /// In fr, this message translates to:
  /// **'Dentiste'**
  String get dentist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ee', 'fr', 'kbp'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ee':
      return AppLocalizationsEe();
    case 'fr':
      return AppLocalizationsFr();
    case 'kbp':
      return AppLocalizationsKbp();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
