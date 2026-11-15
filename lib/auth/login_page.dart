import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../game/widgets/zombie_scene.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Sign-in with e-mail/password or Google (firebase_ui_auth). Shows the group
/// members and the language picker.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SignInScreen(
      breakpoint: 860,
      headerMaxExtent: 210,
      showPasswordVisibilityToggle: true,
      actions: [
        ForgotPasswordAction((context, email) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ForgotPasswordScreen(email: email),
            ),
          );
        }),
      ],
      // The header collapses while scrolling: scale it down and fade it out
      // so it never covers the form.
      headerBuilder: (context, constraints, shrinkOffset) => ClipRect(
        child: Opacity(
          opacity: (1 - shrinkOffset / 150).clamp(0.0, 1.0),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: _Brand(compact: true),
          ),
        ),
      ),
      sideBuilder: (context, constraints) => const _Brand(compact: false),
      subtitleBuilder: (context, action) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(l.tagline),
      ),
      footerBuilder: (context, action) => const _Footer(),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final title = Text(
      l.appTitle,
      textAlign: TextAlign.center,
      style: horrorTitleStyle(size: compact ? 34 : 56, color: scheme.primary),
    );
    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 110,
              width: 160,
              child: ZombieScene.still(plate: '8131', progress: 0.55),
            ),
            const SizedBox(height: 8),
            FittedBox(child: title),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520, maxHeight: 360),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: const AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ZombieScene.still(plate: '8131', progress: 0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          title,
          const SizedBox(height: 12),
          Text(
            l.tagline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          MathView(
            r'\sqrt{8 + 1} = 3^{1}',
            fontSize: 26,
            color: scheme.primary,
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Text(l.language, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          const LanguagePicker(),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(l.developedBy, style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final member in AppConfig.groupMembers)
                    Text(member, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    l.professorCredit,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
