import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'common.dart';

/// Help shown from the navigation bar.
Future<void> showHelpDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final l = AppLocalizations.of(context);
      final scheme = Theme.of(context).colorScheme;
      final sections = <(IconData, String, String)>[
        (Icons.flag_rounded, l.helpGoalTitle, l.helpGoalBody),
        (Icons.touch_app_rounded, l.helpBuildTitle, l.helpBuildBody),
        (Icons.keyboard_rounded, l.helpKeyboardTitle, l.helpKeyboardBody),
        (Icons.stairs_rounded, l.helpLevelsTitle, l.helpLevelsBody),
        (Icons.emoji_events_rounded, l.helpScoreTitle, l.helpScoreBody),
      ];
      return AlertDialog(
        icon: Icon(Icons.help_rounded, color: scheme.primary, size: 36),
        title: Text(l.helpTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (icon, title, body) in sections) ...[
                  Row(
                    children: [
                      Icon(icon, size: 20, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(body),
                  if (title == l.helpGoalTitle) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: MathView(r'\sqrt{8 + 1} = 3^{1}'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.close),
          ),
        ],
      );
    },
  );
}
