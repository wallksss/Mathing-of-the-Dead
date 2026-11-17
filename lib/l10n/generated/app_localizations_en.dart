// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mathing of the Dead';

  @override
  String get tagline =>
      'Turn each zombie’s licence plate into a true equation before it reaches you.';

  @override
  String get developedBy => 'Developed by';

  @override
  String groupMember(int index, String name) {
    return 'Member $index — $name';
  }

  @override
  String get professorCredit => 'Based on Emplake, by Prof. Walter Carnielli';

  @override
  String get language => 'Language';

  @override
  String get languageName => 'English';

  @override
  String get firebaseMissingTitle => 'Firebase is not configured';

  @override
  String get firebaseMissingBody =>
      'Run \"flutterfire configure\" to generate lib/firebase_options.dart and restart the app.';

  @override
  String firebaseErrorBody(String error) {
    return 'Could not connect to Firebase: $error';
  }

  @override
  String get navPlay => 'Play';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navHistory => 'Graveyard';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHelp => 'Help';

  @override
  String get helpTitle => 'How to survive';

  @override
  String get helpGoalTitle => 'Goal';

  @override
  String get helpGoalBody =>
      'Each zombie carries a plate with four digits. Keep the digits in order and add operators and one \"=\" to build a true equation. Example: 8 1 3 1 → √(8 + 1) = 3**1.';

  @override
  String get helpBuildTitle => 'Loading the plate';

  @override
  String get helpBuildBody =>
      'Tap a gap between the digits to aim (the glowing cursor), then tap the operators on the ammo belt. Tap an operator on the plate to remove it. Digits can never be joined: 1 2 is not twelve.';

  @override
  String get helpKeyboardTitle => 'Keyboard (typing of the dead!)';

  @override
  String get helpKeyboardBody =>
      'Type + - * / ( ) ! = directly. ** or ^ is a power, s is √, c is ∛, | is the absolute value, [ ] is floor and { } is ceiling. Typing the next digit just moves past it. ← → move the cursor, Backspace removes, Enter fires and Esc clears.';

  @override
  String get helpLevelsTitle => 'Levels';

  @override
  String get helpLevelsBody =>
      'Easy has every operator and is the only level that accepts non-integer divisions such as 5/2. Intermediate drops floor and ceiling, Advanced also drops powers and the cube root, and Hard only keeps + - × ÷, parentheses and the absolute value.';

  @override
  String get helpScoreTitle => 'Score';

  @override
  String get helpScoreBody =>
      'Harder levels are worth more points. Answering fast and keeping a streak gives bonuses. A hint costs 75% of the plate’s points. You can skip a plate at any time, but the zombie keeps coming from where it was, and a plate you solved never appears again at that level.';

  @override
  String get close => 'Close';

  @override
  String get chooseBattle => 'Choose your battle';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get totalScore => 'Total score';

  @override
  String get platesSolved => 'Plates solved';

  @override
  String get bestStreak => 'Best streak';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelHard => 'Hard';

  @override
  String get levelEasyDesc =>
      'The whole arsenal, including floor, ceiling and fractional division.';

  @override
  String get levelIntermediateDesc =>
      'Roots, powers and factorials. Divisions must be exact.';

  @override
  String get levelAdvancedDesc =>
      'Square root and factorial only. Divisions must be exact.';

  @override
  String get levelHardDesc =>
      'Just the four operations, parentheses and the absolute value.';

  @override
  String pointsPerPlate(int points) {
    return '$points pts per plate';
  }

  @override
  String solvedAtLevel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plates solved',
      one: '1 plate solved',
      zero: 'No plates solved yet',
    );
    return '$_temp0';
  }

  @override
  String get startLevel => 'Fight';

  @override
  String get loadingGraveyard => 'Digging up unsolved plates…';

  @override
  String loadError(String error) {
    return 'Could not load your data: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get score => 'Score';

  @override
  String streak(int count) {
    return 'Streak ×$count';
  }

  @override
  String livesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lives left',
      one: '1 life left',
    );
    return '$_temp0';
  }

  @override
  String get zenMode => 'Zen mode: the zombie waits for you';

  @override
  String get fire => 'Fire!';

  @override
  String get clear => 'Clear';

  @override
  String get skip => 'Skip';

  @override
  String get hint => 'Hint';

  @override
  String get backToLevels => 'Back to levels';

  @override
  String get soundOn => 'Turn sound on';

  @override
  String get soundOff => 'Turn sound off';

  @override
  String get aimHint => 'Tap a gap to aim · tap an operator to load it';

  @override
  String get latexPreview => 'LaTeX preview';

  @override
  String get yourEquation => 'Your equation';

  @override
  String plateLabel(String number) {
    return 'Plate $number';
  }

  @override
  String get hintTitle => 'The oracle whispers…';

  @override
  String get hintCost => 'Using a hint reduces this plate’s reward by 75%.';

  @override
  String get hintThinking => 'Consulting the oracle…';

  @override
  String get hintNone =>
      'Even the oracle could not find an answer. This may be one of the really hard plates — consider skipping it.';

  @override
  String get showHint => 'Reveal';

  @override
  String get cancel => 'Cancel';

  @override
  String headshot(int points) {
    return 'Headshot! +$points';
  }

  @override
  String get zombieGotYou => 'The zombie got you!';

  @override
  String get possibleSolution => 'A possible solution:';

  @override
  String get noKnownSolution => 'No solution was found for this plate.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get gameOver => 'Game over';

  @override
  String finalScore(int score) {
    return 'Run score: $score';
  }

  @override
  String platesThisRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plates this run',
      one: '1 plate this run',
      zero: 'No plates this run',
    );
    return '$_temp0';
  }

  @override
  String get playAgain => 'Play again';

  @override
  String get allSolved =>
      'You have solved every plate at this level. Legendary!';

  @override
  String get skipped => 'Plate skipped';

  @override
  String saveFailed(String error) {
    return 'Could not save your progress: $error';
  }

  @override
  String valuesDiffer(String left, String right) {
    return 'Both sides differ: $left ≠ $right';
  }

  @override
  String get errEmptyPlate => 'The plate is empty.';

  @override
  String get errMissingEquals => 'Add an \"=\" sign.';

  @override
  String get errMultipleEquals => 'Use only one \"=\" sign.';

  @override
  String get errEmptySide => 'Both sides of \"=\" need digits.';

  @override
  String get errMissingOperator =>
      'Two numbers without an operator between them.';

  @override
  String get errUnexpectedToken => 'This operator is in the wrong place.';

  @override
  String get errMissingOperand => 'An operator is missing its number.';

  @override
  String get errUnclosedBracket => 'This bracket was never closed.';

  @override
  String get errUnmatchedClose =>
      'This bracket closes nothing (or the wrong kind).';

  @override
  String get errOperatorNotAllowed =>
      'This operator is not allowed at this level.';

  @override
  String get errDivisionByZero => 'Division by zero.';

  @override
  String get errNonIntegerDivision =>
      'Only exact (integer) divisions are allowed at this level.';

  @override
  String get errNegativeSqrt => 'Square root of a negative number.';

  @override
  String get errFactorialNotInteger =>
      'Factorial only works with whole numbers.';

  @override
  String get errFactorialNegative => 'Factorial of a negative number.';

  @override
  String get errFactorialTooLarge => 'That factorial is too big.';

  @override
  String get errPowerUndefined => 'This power is undefined.';

  @override
  String get errOutOfRange => 'The result is too large or too small.';

  @override
  String get opPlus => 'Addition';

  @override
  String get opMinus => 'Subtraction or negative sign';

  @override
  String get opTimes => 'Multiplication';

  @override
  String get opDivide => 'Division';

  @override
  String get opLparen => 'Open parenthesis';

  @override
  String get opRparen => 'Close parenthesis';

  @override
  String get opPower => 'Power (**)';

  @override
  String get opSqrt => 'Square root';

  @override
  String get opCbrt => 'Cube root';

  @override
  String get opFactorial => 'Factorial';

  @override
  String get opAbs => 'Absolute value';

  @override
  String get opFloor => 'Floor';

  @override
  String get opCeil => 'Ceiling';

  @override
  String get opEquals => 'Equals sign';

  @override
  String get rankingTitle => 'Hall of Survivors';

  @override
  String get rankingEmpty => 'No survivors yet. Be the first!';

  @override
  String get you => 'You';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String platesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plates',
      one: '1 plate',
    );
    return '$_temp0';
  }

  @override
  String get historyTitle => 'Graveyard of solved plates';

  @override
  String get historyEmpty => 'No plates solved yet. The horde is waiting.';

  @override
  String get allLevels => 'All';

  @override
  String get withHint => 'with hint';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themePresets => 'Ready-made themes';

  @override
  String get presetClassic => 'Classic';

  @override
  String get presetToxic => 'Toxic';

  @override
  String get presetBloodMoon => 'Blood moon';

  @override
  String get presetMidnight => 'Midnight';

  @override
  String get presetFog => 'Graveyard fog';

  @override
  String get presetPumpkin => 'Pumpkin';

  @override
  String get seedColor => 'Seed color';

  @override
  String get customColor => 'Custom color';

  @override
  String get hue => 'Hue';

  @override
  String get saturation => 'Saturation';

  @override
  String get fontFamily => 'Font';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontPreview => 'The quick zombie solves 8 1 3 1.';

  @override
  String get game => 'Game';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsDesc => 'Off by default. Shots, groans and chimes.';

  @override
  String get zombieSpeed => 'Zombie speed';

  @override
  String get speedOff => 'Zen';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Fast';

  @override
  String get account => 'Account';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get nickname => 'Nickname shown in the ranking';

  @override
  String get save => 'Save';

  @override
  String get nicknameSaved => 'Nickname saved';

  @override
  String get signOut => 'Sign out';

  @override
  String get resetSettings => 'Restore default settings';

  @override
  String get anonymousSurvivor => 'Anonymous survivor';
}
