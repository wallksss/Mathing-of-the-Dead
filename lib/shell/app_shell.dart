import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../widgets/help_dialog.dart';

/// Scaffold shared by every page after the login, with the curved navigation
/// bar always visible at the bottom.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _helpIndex = 4;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final current = navigationShell.currentIndex;
    final items = <(IconData, String)>[
      (Icons.sports_esports_rounded, l.navPlay),
      (Icons.leaderboard_rounded, l.navRanking),
      (Icons.history_edu_rounded, l.navHistory),
      (Icons.settings_rounded, l.navSettings),
      (Icons.help_outline_rounded, l.navHelp),
    ];
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CurvedNavigationBar(
        index: current,
        height: 62,
        color: scheme.primaryContainer,
        buttonBackgroundColor: scheme.primary,
        backgroundColor: scheme.surface,
        animationDuration: const Duration(milliseconds: 350),
        items: [
          for (var i = 0; i < items.length; i++)
            Tooltip(
              message: items[i].$2,
              child: Semantics(
                label: items[i].$2,
                selected: i == current,
                button: true,
                child: Icon(
                  items[i].$1,
                  size: 28,
                  color: i == current
                      ? scheme.onPrimary
                      : scheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
        // The help button opens a dialog instead of switching pages.
        letIndexChange: (index) {
          if (index == _helpIndex) {
            showHelpDialog(context);
            return false;
          }
          return true;
        },
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
