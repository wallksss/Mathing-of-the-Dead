import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/user_repository.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/common.dart';

/// Top players, read from Firestore.
class RankingPage extends ConsumerStatefulWidget {
  const RankingPage({super.key});

  @override
  ConsumerState<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends ConsumerState<RankingPage> {
  late Future<List<RankingEntry>> _future = _load();

  Future<List<RankingEntry>> _load() =>
      ref.read(userRepositoryProvider).ranking();

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    ref.listen(dataVersionProvider, (_, _) => _reload());
    final l = AppLocalizations.of(context);
    final me = ref.watch(currentUserProvider)?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.rankingTitle),
        actions: [
          IconButton(
            tooltip: l.retry,
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<RankingEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorRetry(error: snapshot.error!, onRetry: _reload);
          }
          if (!snapshot.hasData) return const GraveLoader();
          final entries = snapshot.data!;
          if (entries.isEmpty) {
            return Center(child: Text(l.rankingEmpty));
          }
          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: _RankTile(
                    position: i + 1,
                    entry: entries[i],
                    isMe: entries[i].uid == me,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.position,
    required this.entry,
    required this.isMe,
  });

  final int position;
  final RankingEntry entry;
  final bool isMe;

  static const _medals = [
    Color(0xFFFFC107),
    Color(0xFFB0BEC5),
    Color(0xFFCD7F32),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final medal = position <= 3 ? _medals[position - 1] : null;
    final name = entry.nickname.isEmpty ? l.anonymousSurvivor : entry.nickname;
    return Card(
      margin: EdgeInsets.zero,
      color: isMe ? scheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: medal ?? scheme.surfaceContainerHighest,
          foregroundColor: medal != null ? Colors.black87 : scheme.onSurface,
          child: medal != null
              ? const Icon(Icons.emoji_events_rounded)
              : Text('$position'),
        ),
        title: Text(
          isMe ? '$name (${l.you})' : name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(l.platesShort(entry.solved)),
        trailing: Text(
          l.pointsShort(entry.score),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
        ),
      ),
    );
  }
}
