import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../audio/sound_service.dart';
import '../../data/user_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routing/router.dart';
import '../../settings/app_settings.dart';
import '../../widgets/common.dart';
import '../engine/difficulty.dart';
import '../engine/solver.dart';
import '../engine/tokens.dart';
import '../game_controller.dart';
import '../widgets/ammo_belt.dart';
import '../widgets/flying_token.dart';
import '../widgets/plate_editor.dart';
import '../widgets/zombie_scene.dart';

/// Runs the solver (in a background isolate where available).
String? _solveTask((String, String) args) =>
    solvePlate(args.$1, Difficulty.fromName(args.$2))?.toLatex();

Future<String?> solveInBackground(String plate, Difficulty level) async {
  // Let the loading indicator paint before the (synchronous on web) search.
  await Future<void>.delayed(const Duration(milliseconds: 60));
  return compute(_solveTask, (plate, level.name));
}

/// Loads the plates already solved at [level] (Firestore, via FutureBuilder)
/// and then starts the game.
class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key, required this.level});

  final Difficulty level;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  late Future<Set<String>> _future = _load();

  Future<Set<String>> _load() async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw StateError('Not signed in');
    final solved = await ref
        .read(userRepositoryProvider)
        .solvedPlates(user.uid, widget.level);
    ref
        .read(gameControllerProvider.notifier)
        .start(widget.level, solved, user.uid);
    return solved;
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the (auto-disposed) controller alive while the page is shown.
    final game = ref.watch(gameControllerProvider);
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Set<String>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorRetry(
                error: snapshot.error!,
                onRetry: () => setState(() => _future = _load()),
              );
            }
            if (snapshot.connectionState != ConnectionState.done ||
                game == null ||
                game.level != widget.level) {
              return GraveLoader(message: l.loadingGraveyard, size: 72);
            }
            return const _GameView();
          },
        ),
      ),
    );
  }
}

class _GameView extends ConsumerStatefulWidget {
  const _GameView();

  @override
  ConsumerState<_GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<_GameView> {
  final _focus = FocusNode(debugLabel: 'game');
  final _stackKey = GlobalKey();
  final _tokenKeys = <int, GlobalKey>{};
  final _buttonKeys = <OpButton, GlobalKey>{};
  final _flights = <Flight>[];

  int _deathSerial = 0;
  int _biteSerial = 0;
  int _shakeSerial = 0;
  bool _dialogOpen = false;
  String? _banner;
  bool _bannerGood = true;
  Timer? _bannerTimer;

  GameController get _c => ref.read(gameControllerProvider.notifier);
  GameState get _s => ref.read(gameControllerProvider)!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _focus.dispose();
    super.dispose();
  }

  // ------------------------------------------------------- fly-back anim

  Rect? _rectOf(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.attached) return null;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: stack);
    return topLeft & box.size;
  }

  /// Captures where the operators are now and where they must fly to.
  List<Flight> _captureFlights(Iterable<OpToken> tokens) {
    final flights = <Flight>[];
    var i = 0;
    for (final t in tokens) {
      final from = _rectOf(_tokenKeys[t.id]);
      final to = _rectOf(_buttonKeys[OpButton.of(t.op)]);
      if (from == null || to == null) continue;
      flights.add(
        Flight(
          op: t.op,
          from: from,
          to: to,
          size: from.height * 0.85,
          delay: Duration(milliseconds: 45 * i++),
        ),
      );
    }
    return flights;
  }

  void _launch(List<Flight> flights) {
    if (flights.isEmpty) return;
    setState(() => _flights.addAll(flights));
  }

  Iterable<OpToken> get _ops => _s.tokens.whereType<OpToken>();

  // ------------------------------------------------------------ actions

  void _fire() {
    if (_s.gameOver || _s.allSolved) return;
    final flights = _captureFlights(_ops);
    final result = _c.fire();
    if (result.isCorrect) _launch(flights);
    _focus.requestFocus();
  }

  void _clear() {
    _launch(_captureFlights(_ops));
    _c.clear();
    _focus.requestFocus();
  }

  void _removeOperator(OpToken t) {
    _launch(_captureFlights([t]));
    _c.removeToken(t.id);
    _focus.requestFocus();
  }

  void _skip() {
    _launch(_captureFlights(_ops));
    _c.skip();
    _focus.requestFocus();
  }

  void _press(OpButton b) {
    ref.read(soundServiceProvider).play(Sfx.click);
    _c.press(b);
    _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _dialogOpen) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _c.moveCursor(-1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _c.moveCursor(1);
    } else if (key == LogicalKeyboardKey.home) {
      _c.setCursor(0);
    } else if (key == LogicalKeyboardKey.end) {
      _c.setCursor(_s.tokens.length);
    } else if (key == LogicalKeyboardKey.backspace) {
      final i = _s.cursor - 1;
      if (i >= 0 && _s.tokens[i] is OpToken) {
        _launch(_captureFlights([_s.tokens[i] as OpToken]));
      }
      _c.backspace();
    } else if (key == LogicalKeyboardKey.delete) {
      final i = _s.cursor;
      if (i < _s.tokens.length && _s.tokens[i] is OpToken) {
        _launch(_captureFlights([_s.tokens[i] as OpToken]));
      }
      _c.deleteForward();
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _fire();
    } else if (key == LogicalKeyboardKey.escape) {
      _clear();
    } else {
      final ch = event.character;
      if (ch == null || ch.isEmpty || !_c.type(ch)) {
        return KeyEventResult.ignored;
      }
    }
    return KeyEventResult.handled;
  }

  // ------------------------------------------------------------- events

  void _showBanner(String text, {required bool good}) {
    _bannerTimer?.cancel();
    setState(() {
      _banner = text;
      _bannerGood = good;
    });
    _bannerTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _banner = null);
    });
  }

  void _onEvent(GameEvent event) {
    final l = AppLocalizations.of(context);
    final sound = ref.read(soundServiceProvider);
    switch (event) {
      case HitEvent(:final points, :final latex):
        sound.play(Sfx.shot);
        Future.delayed(
          const Duration(milliseconds: 250),
          () => sound.play(Sfx.chime),
        );
        setState(() => _deathSerial++);
        // A clear, unmissable confirmation: let the zombie fall, then show
        // the solved equation until the player asks for the next zombie.
        setState(() => _dialogOpen = true);
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          _withDialog(
            () => showDialog<void>(
              context: context,
              builder: (context) => _HitDialog(latex: latex, points: points),
            ),
          );
        });
      case MissEvent():
        sound.play(Sfx.error);
        setState(() => _shakeSerial++);
      case BittenEvent(:final plate, :final level):
        sound.play(Sfx.bite);
        setState(() => _biteSerial++);
        _showSolutionDialog(plate, level);
      case SkipEvent():
        sound.play(Sfx.groan);
        _showBanner(l.skipped, good: false);
      case InvalidKeyEvent():
        sound.play(Sfx.error);
        setState(() => _shakeSerial++);
      case SaveFailedEvent(:final message):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.saveFailed(message))));
    }
  }

  Future<void> _withDialog(Future<void> Function() show) async {
    setState(() => _dialogOpen = true);
    await show();
    if (!mounted) return;
    setState(() => _dialogOpen = false);
    _focus.requestFocus();
  }

  void _showSolutionDialog(String plate, Difficulty level) {
    _withDialog(
      () => showDialog<void>(
        context: context,
        builder: (context) => _SolutionDialog(plate: plate, level: level),
      ),
    );
  }

  void _hint() {
    final s = _s;
    _withDialog(
      () => showDialog<void>(
        context: context,
        builder: (context) => _HintDialog(
          plate: s.plate,
          level: s.level,
          alreadyUsed: s.usedHint,
          onReveal: _c.useHint,
        ),
      ),
    );
  }

  // -------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    ref.listen(gameControllerProvider, (prev, next) {
      final event = next?.event;
      if (event != null && event.serial != prev?.event?.serial) {
        _onEvent(event);
      }
      if (next != null) {
        final ids = next.tokens.map((t) => t.id).toSet();
        _tokenKeys.removeWhere((id, _) => !ids.contains(id));
      }
    });
    final s = ref.watch(gameControllerProvider)!;
    final settings = ref.watch(settingsProvider);

    final speed = settings.zombieSpeed;
    final walk = speed == ZombieSpeed.off
        ? null
        : Duration(
            milliseconds: (s.level.zombieSeconds * 1000 * speed.durationFactor)
                .round(),
          );

    final scene = _Scene(
      state: s,
      walk: walk,
      paused: _dialogOpen || s.gameOver || s.allSolved,
      deathSerial: _deathSerial,
      biteSerial: _biteSerial,
      banner: _banner,
      bannerGood: _bannerGood,
      onArrived: _c.zombieArrived,
      onProgress: _c.reportProgress,
      onRestart: () {
        _c.restart();
        _focus.requestFocus();
      },
    );

    final controls = _Controls(
      state: s,
      tokenKeys: _tokenKeys,
      buttonKeys: _buttonKeys,
      shakeSerial: _shakeSerial,
      onGapTap: (i) {
        _c.setCursor(i);
        _focus.requestFocus();
      },
      onOperatorTap: _removeOperator,
      onButton: _press,
      onFire: _fire,
      onClear: _clear,
      onSkip: _skip,
      onHint: _hint,
    );

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _focus.requestFocus,
        child: Stack(
          key: _stackKey,
          children: [
            Column(
              children: [
                _Hud(state: s, zen: walk == null),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 920) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  8,
                                  16,
                                ),
                                child: scene,
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  8,
                                  8,
                                  16,
                                  24,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 720,
                                    ),
                                    child: controls,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      final sceneHeight = (constraints.maxHeight * 0.36).clamp(
                        150.0,
                        340.0,
                      );
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: Column(
                              children: [
                                SizedBox(height: sceneHeight, child: scene),
                                const SizedBox(height: 12),
                                controls,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Operators flying back to the belt.
            for (final f in _flights)
              FlyingToken(
                key: ValueKey(f.id),
                flight: f,
                onDone: () {
                  if (mounted) setState(() => _flights.remove(f));
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Top bar: back, level, score, streak, lives and sound toggle.
class _Hud extends ConsumerWidget {
  const _Hud({required this.state, required this.zen});

  final GameState state;
  final bool zen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sound = ref.watch(settingsProvider.select((s) => s.soundEnabled));
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: l.backToLevels,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go(Routes.play),
          ),
          Flexible(
            child: Chip(
              avatar: Icon(levelIcon(state.level), size: 18),
              label: Text(
                levelName(l, state.level),
                overflow: TextOverflow.ellipsis,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const Spacer(),
          if (state.streak > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: const Icon(Icons.bolt_rounded, size: 18),
                label: Text(l.streak(state.streak)),
                visualDensity: VisualDensity.compact,
                backgroundColor: scheme.tertiaryContainer,
              ),
            ),
          Tooltip(
            message: l.score,
            child: Row(
              children: [
                Icon(Icons.stars_rounded, color: scheme.primary),
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    '${state.score}',
                    key: ValueKey(state.score),
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (zen)
            Tooltip(
              message: l.zenMode,
              child: Icon(
                Icons.self_improvement_rounded,
                color: scheme.primary,
              ),
            )
          else
            Tooltip(
              message: l.livesLeft(state.lives),
              child: Row(
                children: [
                  for (var i = 0; i < maxLives; i++)
                    Icon(
                      i < state.lives
                          ? Icons.favorite_rounded
                          : Icons.heart_broken_outlined,
                      size: 20,
                      color: i < state.lives ? scheme.error : scheme.outline,
                    ),
                ],
              ),
            ),
          IconButton(
            tooltip: sound ? l.soundOff : l.soundOn,
            icon: Icon(
              sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            ),
            onPressed: () => ref.read(settingsProvider.notifier).toggleSound(),
          ),
        ],
      ),
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene({
    required this.state,
    required this.walk,
    required this.paused,
    required this.deathSerial,
    required this.biteSerial,
    required this.banner,
    required this.bannerGood,
    required this.onArrived,
    required this.onProgress,
    required this.onRestart,
  });

  final GameState state;
  final Duration? walk;
  final bool paused;
  final int deathSerial;
  final int biteSerial;
  final String? banner;
  final bool bannerGood;
  final VoidCallback onArrived;
  final ValueChanged<double> onProgress;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ZombieScene(
            plate: state.plate,
            plateSerial: state.plateSerial,
            walkDuration: walk,
            initialProgress: state.initialProgress,
            paused: paused,
            deathSerial: deathSerial,
            biteSerial: biteSerial,
            onArrived: onArrived,
            onProgress: onProgress,
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: anim,
                    curve: Curves.elasticOut,
                  ),
                  child: child,
                ),
                child: banner == null
                    ? const SizedBox.shrink()
                    : Container(
                        key: ValueKey(banner),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: bannerGood
                              ? const Color(0xFF1B5E20)
                              : scheme.inverseSurface,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          banner!,
                          style: TextStyle(
                            color: bannerGood
                                ? Colors.white
                                : scheme.onInverseSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (state.gameOver || state.allSolved)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.allSolved
                                ? Icons.emoji_events_rounded
                                : Icons.sentiment_very_dissatisfied_rounded,
                            size: 48,
                            color: scheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.allSolved ? l.allSolved : l.gameOver,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(l.finalScore(state.score)),
                          Text(l.platesThisRun(state.solvedThisRun)),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => context.go(Routes.play),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: Text(l.backToLevels),
                              ),
                              if (state.gameOver)
                                FilledButton.icon(
                                  onPressed: onRestart,
                                  icon: const Icon(Icons.replay_rounded),
                                  label: Text(l.playAgain),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plate, LaTeX preview, error line, ammo belt and action buttons.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.state,
    required this.tokenKeys,
    required this.buttonKeys,
    required this.shakeSerial,
    required this.onGapTap,
    required this.onOperatorTap,
    required this.onButton,
    required this.onFire,
    required this.onClear,
    required this.onSkip,
    required this.onHint,
  });

  final GameState state;
  final Map<int, GlobalKey> tokenKeys;
  final Map<OpButton, GlobalKey> buttonKeys;
  final int shakeSerial;
  final ValueChanged<int> onGapTap;
  final ValueChanged<OpToken> onOperatorTap;
  final ValueChanged<OpButton> onButton;
  final VoidCallback onFire;
  final VoidCallback onClear;
  final VoidCallback onSkip;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final blocked = state.gameOver || state.allSolved;
    final error = state.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.yourEquation,
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        PlateEditor(
          tokens: state.tokens,
          cursor: state.cursor,
          header: '${levelName(l, state.level)} · ${l.plateLabel(state.plate)}',
          tokenKeys: tokenKeys,
          errorIndex: error?.tokenIndex,
          shakeSerial: shakeSerial,
          onGapTap: onGapTap,
          onOperatorTap: onOperatorTap,
        ),
        const SizedBox(height: 10),
        // LaTeX rendering right below the equation being built.
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.functions_rounded,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l.latexPreview,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Center(child: MathView(state.latex, fontSize: 26)),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: error == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l.aimHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: scheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mathErrorMessage(l, error),
                          style: TextStyle(color: scheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        ExcludeFocus(
          child: AmmoBelt(
            level: state.level,
            buttonKeys: buttonKeys,
            enabled: !blocked,
            onPressed: onButton,
          ),
        ),
        const SizedBox(height: 12),
        ExcludeFocus(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: blocked ? null : onClear,
                icon: const Icon(Icons.cleaning_services_rounded),
                label: Text('${l.clear} (Esc)'),
              ),
              OutlinedButton.icon(
                onPressed: blocked ? null : onHint,
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: Text(l.hint),
              ),
              OutlinedButton.icon(
                onPressed: blocked ? null : onSkip,
                icon: const Icon(Icons.skip_next_rounded),
                label: Text(l.skip),
              ),
              FilledButton.icon(
                onPressed: blocked ? null : onFire,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                icon: const Icon(Icons.gps_fixed_rounded),
                label: Text('${l.fire} (Enter)'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HintDialog extends StatefulWidget {
  const _HintDialog({
    required this.plate,
    required this.level,
    required this.alreadyUsed,
    required this.onReveal,
  });

  final String plate;
  final Difficulty level;
  final bool alreadyUsed;
  final VoidCallback onReveal;

  @override
  State<_HintDialog> createState() => _HintDialogState();
}

class _HintDialogState extends State<_HintDialog> {
  Future<String?>? _future;

  @override
  void initState() {
    super.initState();
    if (widget.alreadyUsed) {
      _future = solveInBackground(widget.plate, widget.level);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      icon: const Icon(Icons.auto_awesome_rounded, size: 36),
      title: Text(l.hintTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, minWidth: 260),
        child: _future == null
            ? Text(l.hintCost)
            : FutureBuilder<String?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return GraveLoader(message: l.hintThinking, size: 40);
                  }
                  final latex = snapshot.data;
                  if (latex == null) return Text(l.hintNone);
                  return Center(child: MathView(latex, fontSize: 28));
                },
              ),
      ),
      actions: [
        if (_future == null) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              widget.onReveal();
              setState(
                () => _future = solveInBackground(widget.plate, widget.level),
              );
            },
            child: Text(l.showHint),
          ),
        ] else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.close),
          ),
      ],
    );
  }
}

/// Shown after a correct answer with the solved equation and the points.
class _HitDialog extends StatelessWidget {
  const _HitDialog({required this.latex, required this.points});

  final String latex;
  final int points;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.verified_rounded, size: 48, color: scheme.primary),
      title: Text(l.youGotIt),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, minWidth: 260),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MathView(latex, fontSize: 28),
            const SizedBox(height: 16),
            Text(
              l.headshot(points),
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: scheme.primary),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.nextZombie),
        ),
      ],
    );
  }
}

class _SolutionDialog extends StatefulWidget {
  const _SolutionDialog({required this.plate, required this.level});

  final String plate;
  final Difficulty level;

  @override
  State<_SolutionDialog> createState() => _SolutionDialogState();
}

class _SolutionDialogState extends State<_SolutionDialog> {
  late final Future<String?> _future = solveInBackground(
    widget.plate,
    widget.level,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plate = widget.plate;
    return AlertDialog(
      icon: Icon(
        Icons.sick_rounded,
        size: 40,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(l.zombieGotYou),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, minWidth: 260),
        child: FutureBuilder<String?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return GraveLoader(message: l.hintThinking, size: 40);
            }
            final latex = snapshot.data;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.plateLabel(plate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (latex == null)
                  Text(l.noKnownSolution)
                else ...[
                  Text(l.possibleSolution),
                  const SizedBox(height: 8),
                  MathView(latex, fontSize: 26),
                ],
              ],
            );
          },
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.continueLabel),
        ),
      ],
    );
  }
}
