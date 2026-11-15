import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/user_repository.dart';
import '../game/engine/difficulty.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Every plate the player solved (Firestore), with its LaTeX rendering.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late Future<List<SolveRecord>> _future = _load();
  Difficulty? _filter;

  Future<List<SolveRecord>> _load() {
    final user = ref.read(currentUserProvider);
    if (user == null) return Future.error(StateError('Not signed in'));
    return ref.read(userRepositoryProvider).history(user.uid);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    ref.listen(dataVersionProvider, (_, _) => _reload());
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.historyTitle),
        actions: [
          IconButton(
            tooltip: l.retry,
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l.allLevels),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final d in Difficulty.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      avatar: Icon(levelIcon(d), size: 18),
                      label: Text(levelName(l, d)),
                      selected: _filter == d,
                      onSelected: (_) => setState(() => _filter = d),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SolveRecord>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorRetry(error: snapshot.error!, onRetry: _reload);
                }
                if (!snapshot.hasData) {
                  return GraveLoader(message: l.loadingGraveyard);
                }
                final records = snapshot.data!
                    .where((r) => _filter == null || r.level == _filter)
                    .toList();
                if (records.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.historyEmpty, textAlign: TextAlign.center),
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = (constraints.maxWidth / 420).floor().clamp(
                      1,
                      3,
                    );
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: 150,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: records.length,
                      itemBuilder: (context, i) =>
                          _RecordCard(record: records[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final SolveRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final date = record.solvedAt == null
        ? ''
        : DateFormat.yMMMd(locale).add_Hm().format(record.solvedAt!.toLocal());
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF1F1F1F),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    record.plate.split('').join(' '),
                    style: plateTextStyle(
                      size: 18,
                      color: const Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(levelIcon(record.level), size: 18, color: scheme.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    levelName(l, record.level),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Text(
                  l.pointsShort(record.points),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(child: MathView(record.latex, fontSize: 22)),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (record.usedHint)
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        size: 14,
                        color: scheme.tertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(l.withHint, style: theme.textTheme.bodySmall),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
