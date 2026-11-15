import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models.dart';
import '../../data/user_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routing/router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../engine/difficulty.dart';
import '../widgets/ammo_belt.dart';

/// Home page: player stats (Firestore) and the four levels.
class LevelSelectPage extends ConsumerStatefulWidget {
  const LevelSelectPage({super.key});

  @override
  ConsumerState<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends ConsumerState<LevelSelectPage> {
  late Future<PlayerProfile> _future = _load();

  Future<PlayerProfile> _load() {
    final user = ref.read(currentUserProvider);
    if (user == null) return Future.error(StateError('Not signed in'));
    return ref.read(userRepositoryProvider).loadProfile(user);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    ref.listen(dataVersionProvider, (_, _) => _reload());
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<PlayerProfile>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorRetry(error: snapshot.error!, onRetry: _reload);
            }
            if (!snapshot.hasData) {
              return GraveLoader(message: l.loadingGraveyard);
            }
            final profile = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: _Header(profile: profile),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.crossAxisExtent;
                        final columns = w >= 1200 ? 4 : (w >= 640 ? 2 : 1);
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 300,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _LevelCard(
                              level: Difficulty.values[i],
                              solved: profile.solvedAt(Difficulty.values[i]),
                            ),
                            childCount: Difficulty.values.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final stats = <(IconData, String, String)>[
      (Icons.stars_rounded, l.totalScore, '${profile.score}'),
      (Icons.task_alt_rounded, l.platesSolved, '${profile.solved}'),
      (Icons.bolt_rounded, l.bestStreak, '${profile.bestStreak}'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.appTitle,
          style: horrorTitleStyle(size: 38, color: scheme.primary),
        ),
        Text(
          l.welcomeBack(
            profile.nickname.isEmpty ? l.anonymousSurvivor : profile.nickname,
          ),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (icon, label, value) in stats)
              Container(
                constraints: const BoxConstraints(minWidth: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(l.chooseBattle, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.solved});

  final Difficulty level;
  final int solved;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final heat = Difficulty.values.indexOf(level) / 3;
    final accent = Color.lerp(scheme.primary, scheme.error, heat)!;
    return Card(
      child: InkWell(
        onTap: () => context.go(Routes.game(level)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    child: Icon(levelIcon(level)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          levelName(l, level),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l.pointsPerPlate(level.basePoints),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                levelDescription(l, level),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final b in level.buttons)
                        Tooltip(
                          message: opButtonName(l, b),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              b.label,
                              style: TextStyle(
                                color: scheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l.solvedAtLevel(solved),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go(Routes.game(level)),
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    icon: const Icon(Icons.gps_fixed_rounded),
                    label: Text(l.startLevel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
