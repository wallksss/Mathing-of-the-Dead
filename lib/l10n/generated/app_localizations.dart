import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mathing of the Dead'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Turn each zombie’s licence plate into a true equation before it reaches you.'**
  String get tagline;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @professorCredit.
  ///
  /// In en, this message translates to:
  /// **'Based on Emplake, by Prof. Walter Carnielli'**
  String get professorCredit;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @firebaseMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not configured'**
  String get firebaseMissingTitle;

  /// No description provided for @firebaseMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Run \"flutterfire configure\" to generate lib/firebase_options.dart and restart the app.'**
  String get firebaseMissingBody;

  /// No description provided for @firebaseErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to Firebase: {error}'**
  String firebaseErrorBody(String error);

  /// No description provided for @navPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get navPlay;

  /// No description provided for @navRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get navRanking;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'Graveyard'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to survive'**
  String get helpTitle;

  /// No description provided for @helpGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get helpGoalTitle;

  /// No description provided for @helpGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Each zombie carries a plate with four digits. Keep the digits in order and add operators and one \"=\" to build a true equation. Example: 8 1 3 1 → √(8 + 1) = 3**1.'**
  String get helpGoalBody;

  /// No description provided for @helpBuildTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading the plate'**
  String get helpBuildTitle;

  /// No description provided for @helpBuildBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a gap between the digits to aim (the glowing cursor), then tap the operators on the ammo belt. Tap an operator on the plate to remove it. Digits can never be joined: 1 2 is not twelve.'**
  String get helpBuildBody;

  /// No description provided for @helpKeyboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard (typing of the dead!)'**
  String get helpKeyboardTitle;

  /// No description provided for @helpKeyboardBody.
  ///
  /// In en, this message translates to:
  /// **'Type + - * / ( ) ! = directly. ** or ^ is a power, s is √, c is ∛, | is the absolute value, [ ] is floor and \'{ }\' is ceiling. Typing the next digit just moves past it. ← → move the cursor, Backspace removes, Enter fires and Esc clears.'**
  String get helpKeyboardBody;

  /// No description provided for @helpLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get helpLevelsTitle;

  /// No description provided for @helpLevelsBody.
  ///
  /// In en, this message translates to:
  /// **'Easy has every operator and is the only level that accepts non-integer divisions such as 5/2. Intermediate drops floor and ceiling, Advanced also drops powers and the cube root, and Hard only keeps + - × ÷, parentheses and the absolute value.'**
  String get helpLevelsBody;

  /// No description provided for @helpScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get helpScoreTitle;

  /// No description provided for @helpScoreBody.
  ///
  /// In en, this message translates to:
  /// **'Harder levels are worth more points. Answering fast and keeping a streak gives bonuses. A hint costs 75% of the plate’s points. You can skip a plate at any time, and a plate you solved never appears again at that level.'**
  String get helpScoreBody;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @chooseBattle.
  ///
  /// In en, this message translates to:
  /// **'Choose your battle'**
  String get chooseBattle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String welcomeBack(String name);

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total score'**
  String get totalScore;

  /// No description provided for @platesSolved.
  ///
  /// In en, this message translates to:
  /// **'Plates solved'**
  String get platesSolved;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @levelEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get levelEasy;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelAdvanced;

  /// No description provided for @levelHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get levelHard;

  /// No description provided for @levelEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'The whole arsenal, including floor, ceiling and fractional division.'**
  String get levelEasyDesc;

  /// No description provided for @levelIntermediateDesc.
  ///
  /// In en, this message translates to:
  /// **'Roots, powers and factorials. Divisions must be exact.'**
  String get levelIntermediateDesc;

  /// No description provided for @levelAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Square root and factorial only. Divisions must be exact.'**
  String get levelAdvancedDesc;

  /// No description provided for @levelHardDesc.
  ///
  /// In en, this message translates to:
  /// **'Just the four operations, parentheses and the absolute value.'**
  String get levelHardDesc;

  /// No description provided for @pointsPerPlate.
  ///
  /// In en, this message translates to:
  /// **'{points} pts per plate'**
  String pointsPerPlate(int points);

  /// No description provided for @solvedAtLevel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No plates solved yet} =1{1 plate solved} other{{count} plates solved}}'**
  String solvedAtLevel(int count);

  /// No description provided for @startLevel.
  ///
  /// In en, this message translates to:
  /// **'Fight'**
  String get startLevel;

  /// No description provided for @loadingGraveyard.
  ///
  /// In en, this message translates to:
  /// **'Digging up unsolved plates…'**
  String get loadingGraveyard;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your data: {error}'**
  String loadError(String error);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak ×{count}'**
  String streak(int count);

  /// No description provided for @livesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 life left} other{{count} lives left}}'**
  String livesLeft(int count);

  /// No description provided for @zenMode.
  ///
  /// In en, this message translates to:
  /// **'Zen mode: the zombie waits for you'**
  String get zenMode;

  /// No description provided for @fire.
  ///
  /// In en, this message translates to:
  /// **'Fire!'**
  String get fire;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @backToLevels.
  ///
  /// In en, this message translates to:
  /// **'Back to levels'**
  String get backToLevels;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Turn sound on'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Turn sound off'**
  String get soundOff;

  /// No description provided for @aimHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a gap to aim · tap an operator to load it'**
  String get aimHint;

  /// No description provided for @latexPreview.
  ///
  /// In en, this message translates to:
  /// **'LaTeX preview'**
  String get latexPreview;

  /// No description provided for @yourEquation.
  ///
  /// In en, this message translates to:
  /// **'Your equation'**
  String get yourEquation;

  /// No description provided for @plateLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate {number}'**
  String plateLabel(String number);

  /// No description provided for @hintTitle.
  ///
  /// In en, this message translates to:
  /// **'The oracle whispers…'**
  String get hintTitle;

  /// No description provided for @hintCost.
  ///
  /// In en, this message translates to:
  /// **'Using a hint reduces this plate’s reward by 75%.'**
  String get hintCost;

  /// No description provided for @hintThinking.
  ///
  /// In en, this message translates to:
  /// **'Consulting the oracle…'**
  String get hintThinking;

  /// No description provided for @hintNone.
  ///
  /// In en, this message translates to:
  /// **'Even the oracle could not find an answer. This may be one of the really hard plates — consider skipping it.'**
  String get hintNone;

  /// No description provided for @showHint.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get showHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @headshot.
  ///
  /// In en, this message translates to:
  /// **'Headshot! +{points}'**
  String headshot(int points);

  /// No description provided for @zombieGotYou.
  ///
  /// In en, this message translates to:
  /// **'The zombie got you!'**
  String get zombieGotYou;

  /// No description provided for @possibleSolution.
  ///
  /// In en, this message translates to:
  /// **'A possible solution:'**
  String get possibleSolution;

  /// No description provided for @noKnownSolution.
  ///
  /// In en, this message translates to:
  /// **'No solution was found for this plate.'**
  String get noKnownSolution;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get gameOver;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Run score: {score}'**
  String finalScore(int score);

  /// No description provided for @platesThisRun.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No plates this run} =1{1 plate this run} other{{count} plates this run}}'**
  String platesThisRun(int count);

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @allSolved.
  ///
  /// In en, this message translates to:
  /// **'You have solved every plate at this level. Legendary!'**
  String get allSolved;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Plate skipped'**
  String get skipped;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your progress: {error}'**
  String saveFailed(String error);

  /// No description provided for @valuesDiffer.
  ///
  /// In en, this message translates to:
  /// **'Both sides differ: {left} ≠ {right}'**
  String valuesDiffer(String left, String right);

  /// No description provided for @errEmptyPlate.
  ///
  /// In en, this message translates to:
  /// **'The plate is empty.'**
  String get errEmptyPlate;

  /// No description provided for @errMissingEquals.
  ///
  /// In en, this message translates to:
  /// **'Add an \"=\" sign.'**
  String get errMissingEquals;

  /// No description provided for @errMultipleEquals.
  ///
  /// In en, this message translates to:
  /// **'Use only one \"=\" sign.'**
  String get errMultipleEquals;

  /// No description provided for @errEmptySide.
  ///
  /// In en, this message translates to:
  /// **'Both sides of \"=\" need digits.'**
  String get errEmptySide;

  /// No description provided for @errMissingOperator.
  ///
  /// In en, this message translates to:
  /// **'Two numbers without an operator between them.'**
  String get errMissingOperator;

  /// No description provided for @errUnexpectedToken.
  ///
  /// In en, this message translates to:
  /// **'This operator is in the wrong place.'**
  String get errUnexpectedToken;

  /// No description provided for @errMissingOperand.
  ///
  /// In en, this message translates to:
  /// **'An operator is missing its number.'**
  String get errMissingOperand;

  /// No description provided for @errUnclosedBracket.
  ///
  /// In en, this message translates to:
  /// **'This bracket was never closed.'**
  String get errUnclosedBracket;

  /// No description provided for @errUnmatchedClose.
  ///
  /// In en, this message translates to:
  /// **'This bracket closes nothing (or the wrong kind).'**
  String get errUnmatchedClose;

  /// No description provided for @errOperatorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This operator is not allowed at this level.'**
  String get errOperatorNotAllowed;

  /// No description provided for @errDivisionByZero.
  ///
  /// In en, this message translates to:
  /// **'Division by zero.'**
  String get errDivisionByZero;

  /// No description provided for @errNonIntegerDivision.
  ///
  /// In en, this message translates to:
  /// **'Only exact (integer) divisions are allowed at this level.'**
  String get errNonIntegerDivision;

  /// No description provided for @errNegativeSqrt.
  ///
  /// In en, this message translates to:
  /// **'Square root of a negative number.'**
  String get errNegativeSqrt;

  /// No description provided for @errFactorialNotInteger.
  ///
  /// In en, this message translates to:
  /// **'Factorial only works with whole numbers.'**
  String get errFactorialNotInteger;

  /// No description provided for @errFactorialNegative.
  ///
  /// In en, this message translates to:
  /// **'Factorial of a negative number.'**
  String get errFactorialNegative;

  /// No description provided for @errFactorialTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That factorial is too big.'**
  String get errFactorialTooLarge;

  /// No description provided for @errPowerUndefined.
  ///
  /// In en, this message translates to:
  /// **'This power is undefined.'**
  String get errPowerUndefined;

  /// No description provided for @errOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'The result is too large or too small.'**
  String get errOutOfRange;

  /// No description provided for @opPlus.
  ///
  /// In en, this message translates to:
  /// **'Addition'**
  String get opPlus;

  /// No description provided for @opMinus.
  ///
  /// In en, this message translates to:
  /// **'Subtraction or negative sign'**
  String get opMinus;

  /// No description provided for @opTimes.
  ///
  /// In en, this message translates to:
  /// **'Multiplication'**
  String get opTimes;

  /// No description provided for @opDivide.
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get opDivide;

  /// No description provided for @opLparen.
  ///
  /// In en, this message translates to:
  /// **'Open parenthesis'**
  String get opLparen;

  /// No description provided for @opRparen.
  ///
  /// In en, this message translates to:
  /// **'Close parenthesis'**
  String get opRparen;

  /// No description provided for @opPower.
  ///
  /// In en, this message translates to:
  /// **'Power (**)'**
  String get opPower;

  /// No description provided for @opSqrt.
  ///
  /// In en, this message translates to:
  /// **'Square root'**
  String get opSqrt;

  /// No description provided for @opCbrt.
  ///
  /// In en, this message translates to:
  /// **'Cube root'**
  String get opCbrt;

  /// No description provided for @opFactorial.
  ///
  /// In en, this message translates to:
  /// **'Factorial'**
  String get opFactorial;

  /// No description provided for @opAbs.
  ///
  /// In en, this message translates to:
  /// **'Absolute value'**
  String get opAbs;

  /// No description provided for @opFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get opFloor;

  /// No description provided for @opCeil.
  ///
  /// In en, this message translates to:
  /// **'Ceiling'**
  String get opCeil;

  /// No description provided for @opEquals.
  ///
  /// In en, this message translates to:
  /// **'Equals sign'**
  String get opEquals;

  /// No description provided for @rankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Hall of Survivors'**
  String get rankingTitle;

  /// No description provided for @rankingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No survivors yet. Be the first!'**
  String get rankingEmpty;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @pointsShort.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsShort(int points);

  /// No description provided for @platesShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plate} other{{count} plates}}'**
  String platesShort(int count);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Graveyard of solved plates'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plates solved yet. The horde is waiting.'**
  String get historyEmpty;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLevels;

  /// No description provided for @withHint.
  ///
  /// In en, this message translates to:
  /// **'with hint'**
  String get withHint;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themePresets.
  ///
  /// In en, this message translates to:
  /// **'Ready-made themes'**
  String get themePresets;

  /// No description provided for @presetClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get presetClassic;

  /// No description provided for @presetToxic.
  ///
  /// In en, this message translates to:
  /// **'Toxic'**
  String get presetToxic;

  /// No description provided for @presetBloodMoon.
  ///
  /// In en, this message translates to:
  /// **'Blood moon'**
  String get presetBloodMoon;

  /// No description provided for @presetMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get presetMidnight;

  /// No description provided for @presetFog.
  ///
  /// In en, this message translates to:
  /// **'Graveyard fog'**
  String get presetFog;

  /// No description provided for @presetPumpkin.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin'**
  String get presetPumpkin;

  /// No description provided for @seedColor.
  ///
  /// In en, this message translates to:
  /// **'Seed color'**
  String get seedColor;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hue;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get fontFamily;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @fontPreview.
  ///
  /// In en, this message translates to:
  /// **'The quick zombie solves 8 1 3 1.'**
  String get fontPreview;

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsDesc.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Shots, groans and chimes.'**
  String get soundEffectsDesc;

  /// No description provided for @zombieSpeed.
  ///
  /// In en, this message translates to:
  /// **'Zombie speed'**
  String get zombieSpeed;

  /// No description provided for @speedOff.
  ///
  /// In en, this message translates to:
  /// **'Zen'**
  String get speedOff;

  /// No description provided for @speedSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  /// No description provided for @speedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get speedNormal;

  /// No description provided for @speedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname shown in the ranking'**
  String get nickname;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @nicknameSaved.
  ///
  /// In en, this message translates to:
  /// **'Nickname saved'**
  String get nicknameSaved;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Restore default settings'**
  String get resetSettings;

  /// No description provided for @anonymousSurvivor.
  ///
  /// In en, this message translates to:
  /// **'Anonymous survivor'**
  String get anonymousSurvivor;
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
