import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ee.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fon.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_kbp.dart';
import 'app_localizations_ln.dart';
import 'app_localizations_tem.dart';
import 'app_localizations_yo.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('ee'),
    Locale('fon'),
    Locale('fr'),
    Locale('kbp'),
    Locale('ln'),
    Locale('tem'),
    Locale('yo'),
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

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navDiag.
  ///
  /// In fr, this message translates to:
  /// **'Diag'**
  String get navDiag;

  /// No description provided for @navHospital.
  ///
  /// In fr, this message translates to:
  /// **'Hôpital'**
  String get navHospital;

  /// No description provided for @navScan.
  ///
  /// In fr, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navLyra.
  ///
  /// In fr, this message translates to:
  /// **'Lyra'**
  String get navLyra;

  /// No description provided for @btnVocal.
  ///
  /// In fr, this message translates to:
  /// **'Vocal'**
  String get btnVocal;

  /// No description provided for @btnPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get btnPhoto;

  /// No description provided for @symptomVomiting.
  ///
  /// In fr, this message translates to:
  /// **'Vomissements'**
  String get symptomVomiting;

  /// No description provided for @symptomNausea.
  ///
  /// In fr, this message translates to:
  /// **'Nausée'**
  String get symptomNausea;

  /// No description provided for @symptomBackPain.
  ///
  /// In fr, this message translates to:
  /// **'Mal de dos'**
  String get symptomBackPain;

  /// No description provided for @symptomHeadache.
  ///
  /// In fr, this message translates to:
  /// **'Mal de tête'**
  String get symptomHeadache;

  /// No description provided for @symptomAbdominalPainAcute.
  ///
  /// In fr, this message translates to:
  /// **'Douleur abdominale aiguë'**
  String get symptomAbdominalPainAcute;

  /// No description provided for @symptomFever.
  ///
  /// In fr, this message translates to:
  /// **'Fièvre'**
  String get symptomFever;

  /// No description provided for @symptomAbdominalPainLow.
  ///
  /// In fr, this message translates to:
  /// **'Douleur abdominale basse'**
  String get symptomAbdominalPainLow;

  /// No description provided for @symptomCough.
  ///
  /// In fr, this message translates to:
  /// **'Toux'**
  String get symptomCough;

  /// No description provided for @symptomNasalCongestion.
  ///
  /// In fr, this message translates to:
  /// **'Congestion nasale'**
  String get symptomNasalCongestion;

  /// No description provided for @symptomHeartburn.
  ///
  /// In fr, this message translates to:
  /// **'Brûlure abdominale'**
  String get symptomHeartburn;

  /// No description provided for @symptomArmPain.
  ///
  /// In fr, this message translates to:
  /// **'Douleur au bras'**
  String get symptomArmPain;

  /// No description provided for @symptomLowBackPain.
  ///
  /// In fr, this message translates to:
  /// **'Lombalgie'**
  String get symptomLowBackPain;

  /// No description provided for @symptomEarPain.
  ///
  /// In fr, this message translates to:
  /// **'Mal d\'oreille'**
  String get symptomEarPain;

  /// No description provided for @symptomDiarrhea.
  ///
  /// In fr, this message translates to:
  /// **'Diarrhée'**
  String get symptomDiarrhea;

  /// No description provided for @symptomNeckPain.
  ///
  /// In fr, this message translates to:
  /// **'Douleur au cou'**
  String get symptomNeckPain;

  /// No description provided for @symptomSkinAbnormal.
  ///
  /// In fr, this message translates to:
  /// **'Peau anormale'**
  String get symptomSkinAbnormal;

  /// No description provided for @symptomWeakness.
  ///
  /// In fr, this message translates to:
  /// **'Faiblesse'**
  String get symptomWeakness;

  /// No description provided for @symptomSkinLesion.
  ///
  /// In fr, this message translates to:
  /// **'Lésion cutanée'**
  String get symptomSkinLesion;

  /// No description provided for @symptomChestPainAcute.
  ///
  /// In fr, this message translates to:
  /// **'Douleur thoracique aiguë'**
  String get symptomChestPainAcute;

  /// No description provided for @symptomSensationLoss.
  ///
  /// In fr, this message translates to:
  /// **'Perte de sensation'**
  String get symptomSensationLoss;

  /// No description provided for @symptomPelvicPain.
  ///
  /// In fr, this message translates to:
  /// **'Douleur pelvienne'**
  String get symptomPelvicPain;

  /// No description provided for @symptomSkinGrowth.
  ///
  /// In fr, this message translates to:
  /// **'Excroissance cutanée'**
  String get symptomSkinGrowth;

  /// No description provided for @symptomPeeling.
  ///
  /// In fr, this message translates to:
  /// **'Desquamation'**
  String get symptomPeeling;

  /// No description provided for @symptomDrySkin.
  ///
  /// In fr, this message translates to:
  /// **'Peau sèche'**
  String get symptomDrySkin;

  /// No description provided for @symptomMovementProblem.
  ///
  /// In fr, this message translates to:
  /// **'Problème de mouvement'**
  String get symptomMovementProblem;

  /// No description provided for @symptomItching.
  ///
  /// In fr, this message translates to:
  /// **'Démangeaison'**
  String get symptomItching;

  /// No description provided for @symptomLegSwelling.
  ///
  /// In fr, this message translates to:
  /// **'Gonflement des jambes'**
  String get symptomLegSwelling;

  /// No description provided for @symptomEyePain.
  ///
  /// In fr, this message translates to:
  /// **'Douleur à l\'œil'**
  String get symptomEyePain;

  /// No description provided for @symptomChestTightness.
  ///
  /// In fr, this message translates to:
  /// **'Oppression thoracique'**
  String get symptomChestTightness;

  /// No description provided for @symptomDepression.
  ///
  /// In fr, this message translates to:
  /// **'Symptômes dépressifs'**
  String get symptomDepression;

  /// No description provided for @symptomScalpAbnormal.
  ///
  /// In fr, this message translates to:
  /// **'Cuir chevelu anormal'**
  String get symptomScalpAbnormal;

  /// No description provided for @symptomInsomnia.
  ///
  /// In fr, this message translates to:
  /// **'Insomnie'**
  String get symptomInsomnia;

  /// No description provided for @symptomSidePain.
  ///
  /// In fr, this message translates to:
  /// **'Douleur latérale'**
  String get symptomSidePain;

  /// No description provided for @symptomKneePain.
  ///
  /// In fr, this message translates to:
  /// **'Douleur au genou'**
  String get symptomKneePain;

  /// No description provided for @symptomPainfulUrination.
  ///
  /// In fr, this message translates to:
  /// **'Miction douloureuse'**
  String get symptomPainfulUrination;

  /// No description provided for @symptomBreathingDifficulty.
  ///
  /// In fr, this message translates to:
  /// **'Difficulté à respirer'**
  String get symptomBreathingDifficulty;

  /// No description provided for @symptomAcne.
  ///
  /// In fr, this message translates to:
  /// **'Acné'**
  String get symptomAcne;

  /// No description provided for @symptomFacePain.
  ///
  /// In fr, this message translates to:
  /// **'Douleur faciale'**
  String get symptomFacePain;

  /// No description provided for @symptomFootPain.
  ///
  /// In fr, this message translates to:
  /// **'Douleur au pied'**
  String get symptomFootPain;

  /// No description provided for @symptomFrequentUrination.
  ///
  /// In fr, this message translates to:
  /// **'Miction fréquente'**
  String get symptomFrequentUrination;

  /// No description provided for @symptomDizziness.
  ///
  /// In fr, this message translates to:
  /// **'Vertiges'**
  String get symptomDizziness;

  /// No description provided for @symptomEyeProblem.
  ///
  /// In fr, this message translates to:
  /// **'Problème oculaire'**
  String get symptomEyeProblem;

  /// No description provided for @symptomAppetiteLoss.
  ///
  /// In fr, this message translates to:
  /// **'Perte d\'appétit'**
  String get symptomAppetiteLoss;

  /// No description provided for @symptomStomachBurn.
  ///
  /// In fr, this message translates to:
  /// **'Brûlure d\'estomac'**
  String get symptomStomachBurn;

  /// No description provided for @symptomIrritability.
  ///
  /// In fr, this message translates to:
  /// **'Irritabilité'**
  String get symptomIrritability;

  /// No description provided for @symptomMole.
  ///
  /// In fr, this message translates to:
  /// **'Grain de beauté'**
  String get symptomMole;

  /// No description provided for @symptomTearing.
  ///
  /// In fr, this message translates to:
  /// **'Larmoiement'**
  String get symptomTearing;

  /// No description provided for @symptomAlcoholConsumption.
  ///
  /// In fr, this message translates to:
  /// **'Consommation d\'alcool'**
  String get symptomAlcoholConsumption;

  /// No description provided for @searchHospitalHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un hôpital...'**
  String get searchHospitalHint;

  /// No description provided for @recommendedSection.
  ///
  /// In fr, this message translates to:
  /// **'Recommandés pour vous'**
  String get recommendedSection;

  /// No description provided for @noHospitalFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun hôpital trouvé à proximité.'**
  String get noHospitalFound;

  /// No description provided for @serviceEmergency.
  ///
  /// In fr, this message translates to:
  /// **'Urgences'**
  String get serviceEmergency;

  /// No description provided for @serviceCardiology.
  ///
  /// In fr, this message translates to:
  /// **'Cardiologie'**
  String get serviceCardiology;

  /// No description provided for @servicePediatrics.
  ///
  /// In fr, this message translates to:
  /// **'Pédiatrie'**
  String get servicePediatrics;

  /// No description provided for @serviceNeurology.
  ///
  /// In fr, this message translates to:
  /// **'Neurologie'**
  String get serviceNeurology;

  /// No description provided for @serviceGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get serviceGeneral;

  /// No description provided for @serviceMaternity.
  ///
  /// In fr, this message translates to:
  /// **'Maternité'**
  String get serviceMaternity;

  /// No description provided for @healthTipsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conseil du jour'**
  String get healthTipsTitle;

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

  /// No description provided for @tipHydrationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Hydratation'**
  String get tipHydrationTitle;

  /// No description provided for @tipHydrationDesc.
  ///
  /// In fr, this message translates to:
  /// **'Buvez au moins 1,5L d\'eau par jour pour rester en forme.'**
  String get tipHydrationDesc;

  /// No description provided for @tipExerciseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activité physique'**
  String get tipExerciseTitle;

  /// No description provided for @tipExerciseDesc.
  ///
  /// In fr, this message translates to:
  /// **'30 minutes de marche par jour améliorent votre santé cardiaque.'**
  String get tipExerciseDesc;

  /// No description provided for @tipSleepTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sommeil'**
  String get tipSleepTitle;

  /// No description provided for @tipSleepDesc.
  ///
  /// In fr, this message translates to:
  /// **'Un sommeil de 7-8h est essentiel pour la récupération.'**
  String get tipSleepDesc;

  /// No description provided for @tipDietTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alimentation'**
  String get tipDietTitle;

  /// No description provided for @tipDietDesc.
  ///
  /// In fr, this message translates to:
  /// **'Mangez 5 fruits et légumes par jour.'**
  String get tipDietDesc;

  /// No description provided for @tipStressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion du stress'**
  String get tipStressTitle;

  /// No description provided for @tipStressDesc.
  ///
  /// In fr, this message translates to:
  /// **'Prenez 5 minutes pour respirer profondément.'**
  String get tipStressDesc;

  /// No description provided for @tipHygieneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Hygiène'**
  String get tipHygieneTitle;

  /// No description provided for @tipHygieneDesc.
  ///
  /// In fr, this message translates to:
  /// **'Lavez-vous les mains régulièrement.'**
  String get tipHygieneDesc;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In fr, this message translates to:
  /// **'Ou continuer avec'**
  String get orContinueWith;

  /// No description provided for @chooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une langue'**
  String get chooseLanguage;

  /// No description provided for @myProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editProfile;

  /// No description provided for @medicalFile.
  ///
  /// In fr, this message translates to:
  /// **'Fiche Medical'**
  String get medicalFile;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Parametre'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get history;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpSupport.
  ///
  /// In fr, this message translates to:
  /// **'Aide & Support'**
  String get helpSupport;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageChanged.
  ///
  /// In fr, this message translates to:
  /// **'Langue modifiée avec succès'**
  String get languageChanged;

  /// No description provided for @ourServices.
  ///
  /// In fr, this message translates to:
  /// **'Nos services'**
  String get ourServices;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'ee',
    'fon',
    'fr',
    'kbp',
    'ln',
    'tem',
    'yo',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ee':
      return AppLocalizationsEe();
    case 'fon':
      return AppLocalizationsFon();
    case 'fr':
      return AppLocalizationsFr();
    case 'kbp':
      return AppLocalizationsKbp();
    case 'ln':
      return AppLocalizationsLn();
    case 'tem':
      return AppLocalizationsTem();
    case 'yo':
      return AppLocalizationsYo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
