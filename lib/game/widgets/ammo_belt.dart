import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import '../engine/difficulty.dart';
import '../engine/tokens.dart';

String opButtonName(AppLocalizations l, OpButton b) => switch (b) {
  OpButton.plus => l.opPlus,
  OpButton.minus => l.opMinus,
  OpButton.times => l.opTimes,
  OpButton.divide => l.opDivide,
  OpButton.lparen => l.opLparen,
  OpButton.rparen => l.opRparen,
  OpButton.power => l.opPower,
  OpButton.sqrt => l.opSqrt,
  OpButton.cbrt => l.opCbrt,
  OpButton.factorial => l.opFactorial,
  OpButton.abs => l.opAbs,
  OpButton.floor => l.opFloor,
  OpButton.ceil => l.opCeil,
  OpButton.equals => l.opEquals,
};

/// Keyboard shortcut shown on each cartridge.
String opButtonShortcut(OpButton b) => switch (b) {
  OpButton.power => '**',
  OpButton.sqrt => 's',
  OpButton.cbrt => 'c',
  OpButton.floor => '[ ]',
  OpButton.ceil => '{ }',
  OpButton.abs => '|',
  OpButton.times => '*',
  OpButton.divide => '/',
  OpButton.minus => '-',
  _ => b.ops.first.plain,
};

/// The operators available at the level, as "cartridges" on an ammo belt.
class AmmoBelt extends StatelessWidget {
  const AmmoBelt({
    super.key,
    required this.level,
    required this.buttonKeys,
    required this.onPressed,
    this.enabled = true,
  });

  final Difficulty level;
  final Map<OpButton, GlobalKey> buttonKeys;
  final ValueChanged<OpButton> onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final buttons = OpButton.values
        .where((b) => level.buttons.contains(b))
        .toList();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final b in buttons)
            _Cartridge(
              key: buttonKeys.putIfAbsent(
                b,
                () => GlobalKey(debugLabel: b.name),
              ),
              button: b,
              enabled: enabled,
              onTap: () => onPressed(b),
            ),
        ],
      ),
    );
  }
}

class _Cartridge extends StatelessWidget {
  const _Cartridge({
    super.key,
    required this.button,
    required this.enabled,
    required this.onTap,
  });

  final OpButton button;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isEquals = button == OpButton.equals;
    final top = isEquals ? scheme.tertiaryContainer : scheme.secondaryContainer;
    final fg = isEquals
        ? scheme.onTertiaryContainer
        : scheme.onSecondaryContainer;
    return Tooltip(
      message: '${opButtonName(l, button)}  ⌨ ${opButtonShortcut(button)}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: 58,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [top, Color.lerp(top, scheme.shadow, 0.12)!],
              ),
              border: Border.all(color: Color.lerp(top, scheme.shadow, 0.25)!),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    button.label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: enabled ? fg : fg.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  bottom: 2,
                  child: Text(
                    opButtonShortcut(button),
                    style: TextStyle(
                      fontSize: 9,
                      color: fg.withValues(alpha: 0.6),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
