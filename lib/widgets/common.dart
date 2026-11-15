import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../game/engine/ast.dart';
import '../game/engine/difficulty.dart';
import '../l10n/generated/app_localizations.dart';
import '../settings/app_settings.dart';

/// Non-default progress indicator used for every Firestore load.
class GraveLoader extends StatelessWidget {
  const GraveLoader({super.key, this.message, this.size = 56});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(
              color: scheme.primary,
              size: size,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error box with a retry button (used by FutureBuilders).
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(l.loadError('$error'), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l.retry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Supported languages, with the country flag shown for each.
const supportedLanguages = <({String code, String country})>[
  (code: 'pt', country: 'BR'),
  (code: 'en', country: 'US'),
  (code: 'es', country: 'ES'),
];

String languageName(String code) =>
    lookupAppLocalizations(Locale(code)).languageName;

/// Row of flag buttons to change the language.
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final lang in supportedLanguages)
          Tooltip(
            message: languageName(lang.code),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  ref.read(settingsProvider.notifier).setLocale(lang.code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: current == lang.code
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: Border.all(
                    color: current == lang.code
                        ? scheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountryFlag.fromCountryCode(
                      lang.country,
                      theme: const ImageTheme(
                        width: 28,
                        height: 20,
                        shape: RoundedRectangle(4),
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 8),
                      Text(
                        languageName(lang.code),
                        style: TextStyle(
                          fontWeight: current == lang.code
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: current == lang.code
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Renders LaTeX, scrolling horizontally if it does not fit.
class MathView extends StatelessWidget {
  const MathView(this.tex, {super.key, this.fontSize = 22, this.color});

  final String tex;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        tex.isEmpty ? r'\square = \square' : tex,
        mathStyle: MathStyle.display,
        textStyle: style,
        onErrorFallback: (err) => Text(tex, style: style),
      ),
    );
  }
}

/// Localized level name.
String levelName(AppLocalizations l, Difficulty d) => switch (d) {
  Difficulty.easy => l.levelEasy,
  Difficulty.intermediate => l.levelIntermediate,
  Difficulty.advanced => l.levelAdvanced,
  Difficulty.hard => l.levelHard,
};

String levelDescription(AppLocalizations l, Difficulty d) => switch (d) {
  Difficulty.easy => l.levelEasyDesc,
  Difficulty.intermediate => l.levelIntermediateDesc,
  Difficulty.advanced => l.levelAdvancedDesc,
  Difficulty.hard => l.levelHardDesc,
};

IconData levelIcon(Difficulty d) => switch (d) {
  Difficulty.easy => Icons.sentiment_satisfied_alt_rounded,
  Difficulty.intermediate => Icons.local_fire_department_rounded,
  Difficulty.advanced => Icons.whatshot_rounded,
  Difficulty.hard => Icons.dangerous_rounded,
};

/// Localized message for an engine error.
String mathErrorMessage(AppLocalizations l, MathError e) => switch (e.code) {
  MathErrorCode.emptyPlate => l.errEmptyPlate,
  MathErrorCode.missingEquals => l.errMissingEquals,
  MathErrorCode.multipleEquals => l.errMultipleEquals,
  MathErrorCode.emptySide => l.errEmptySide,
  MathErrorCode.missingOperator => l.errMissingOperator,
  MathErrorCode.unexpectedToken => l.errUnexpectedToken,
  MathErrorCode.missingOperand => l.errMissingOperand,
  MathErrorCode.unclosedBracket => l.errUnclosedBracket,
  MathErrorCode.unmatchedClose => l.errUnmatchedClose,
  MathErrorCode.operatorNotAllowed => l.errOperatorNotAllowed,
  MathErrorCode.divisionByZero => l.errDivisionByZero,
  MathErrorCode.nonIntegerDivision => l.errNonIntegerDivision,
  MathErrorCode.negativeSqrt => l.errNegativeSqrt,
  MathErrorCode.factorialNotInteger => l.errFactorialNotInteger,
  MathErrorCode.factorialNegative => l.errFactorialNegative,
  MathErrorCode.factorialTooLarge => l.errFactorialTooLarge,
  MathErrorCode.powerUndefined => l.errPowerUndefined,
  MathErrorCode.outOfRange => l.errOutOfRange,
  MathErrorCode.notEqual => l.valuesDiffer(
    formatNumber(e.left ?? 0),
    formatNumber(e.right ?? 0),
  ),
};

/// Short readable number (integers without decimals).
String formatNumber(double v) {
  if (isInteger(v) && v.abs() < 1e15) return v.round().toString();
  if (v.abs() >= 1e6 || v.abs() < 1e-3) return v.toStringAsExponential(4);
  return double.parse(v.toStringAsFixed(6)).toString();
}
