import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/content_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'player_screen.dart';

const _weekNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

class ProgramDetailScreen extends StatefulWidget {
  final String slug;
  const ProgramDetailScreen({super.key, required this.slug});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  SiteContent? _content;

  @override
  void initState() {
    super.initState();
    ContentRepository.instance.load().then((c) {
      if (mounted) setState(() => _content = c);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _content;
    if (c == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final blocks =
        c.schedule.where((b) => b.slug == widget.slug).toList();
    if (blocks.isEmpty) {
      return const Scaffold(body: Center(child: Text('Programa não encontrado')));
    }
    final program = blocks.first;
    final onNow = c.onNow;
    final isOnNow = onNow?.slug == widget.slug;

    final days = <int>{for (final b in blocks) ...b.weekdays}.toList()..sort();

    return Scaffold(
      backgroundColor: DiaColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: DiaColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(program.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, DiaColors.bg],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(program.title,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  if (isOnNow)
                    GradientPill(
                      label: 'Assistir ao vivo',
                      icon: Icons.play_arrow_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(
                            videoId: c.live.videoId,
                            title: program.title,
                            subtitle: 'Ao vivo agora',
                            isLive: true,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 22),
                  const Text('Dias',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final d in days)
                        Chip(
                          backgroundColor: DiaColors.surfaceHi,
                          side: BorderSide.none,
                          label: Text(_weekNames[d % 7]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('Horários na grade',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  for (final b in blocks)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: DiaColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 18, color: DiaColors.pink),
                          const SizedBox(width: 10),
                          Text('${b.startsAt} – ${b.endsAt}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Text(
                            b.weekdays
                                .map((d) => _weekNames[d % 7])
                                .join(', '),
                            style: const TextStyle(color: DiaColors.textDim),
                          ),
                        ],
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
