import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'player_screen.dart';
import 'program_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final SiteContent content;
  final VoidCallback? onVerProgramacao;
  const HomeScreen({super.key, required this.content, this.onVerProgramacao});

  @override
  Widget build(BuildContext context) {
    final now = content.onNow;
    final upcoming = _upcoming(content.schedule);
    final videoSection =
        content.sections.isNotEmpty ? content.sections.first : null;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: DiaColors.bg,
          titleSpacing: 16,
          title: const DiaLogo(),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => showSearch(
                  context: context, delegate: _DiaSearch(content)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 4),
              child: GradientPill(label: 'Ingressos', onTap: () {}),
            ),
          ],
        ),
        SliverToBoxAdapter(child: _LiveHero(live: content.live, onNow: now)),
        if (videoSection != null)
          SliverToBoxAdapter(
            child: _VideoCarousel(
                title: videoSection.title == 'null'
                    ? 'Não perca nada'
                    : videoSection.title,
                videos: videoSection.videos),
          ),
        SliverToBoxAdapter(
          child: SectionHeader('Programação de hoje',
              action: 'Ver tudo', onAction: onVerProgramacao),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 212,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: upcoming.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _ScheduleCard(block: upcoming[i]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionHeader('Programas', action: 'Ver tudo', onAction: onVerProgramacao),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: content.programs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = content.programs[i];
                return _ProgramPoster(program: p);
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // Blocos a partir de agora (os próximos da grade), completando com o começo.
  List<ScheduleBlock> _upcoming(List<ScheduleBlock> all) {
    if (all.isEmpty) return all;
    final now = DateTime.now();
    final mins = now.hour * 60 + now.minute;
    final sorted = [...all]..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final after = sorted.where((b) => b.startMinutes >= mins).toList();
    final before = sorted.where((b) => b.startMinutes < mins).toList();
    return [...after, ...before];
  }
}

class _LiveHero extends StatelessWidget {
  final LiveInfo live;
  final ScheduleBlock? onNow;
  const _LiveHero({required this.live, this.onNow});

  @override
  Widget build(BuildContext context) {
    final cover = onNow?.cover ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              videoId: live.videoId,
              title: onNow?.title ?? live.title,
              subtitle: onNow != null
                  ? '${onNow!.startsAt} – ${onNow!.endsAt} · Ao vivo agora'
                  : 'Ao vivo agora',
              isLive: true,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: DiaColors.magenta,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.circle, size: 8, color: Colors.white),
                      SizedBox(width: 6),
                      Text('AO VIVO',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                    ]),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AGORA NA DIATV',
                          style: TextStyle(
                              color: DiaColors.pink,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(onNow?.title ?? live.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      GradientPill(
                          label: 'Assistir', icon: Icons.play_arrow_rounded),
                    ],
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

class _VideoCarousel extends StatelessWidget {
  final String title;
  final List<VideoItem> videos;
  const _VideoCarousel({required this.title, required this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title),
        SizedBox(
          height: 182,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _VideoCard(video: videos[i]),
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoItem video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerScreen(
            videoId: video.id,
            title: video.title,
            subtitle: video.viewCount != null
                ? '${formatViews(video.viewCount)} visualizações'
                : null,
            isLive: video.isLive,
          ),
        ),
      ),
      child: SizedBox(
        width: 230,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetImage(video.thumbnailUrl ?? ''),
                    if (video.durationLabel != null)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.isLive ? 'AO VIVO' : video.durationLabel!,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, height: 1.25)),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleBlock block;
  const _ScheduleCard({required this.block});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProgramDetailScreen(slug: block.slug)),
      ),
      child: SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: NetImage(block.cover),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: DiaColors.surfaceHi,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${block.startsAt} – ${block.endsAt}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: DiaColors.pink)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(block.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ProgramPoster extends StatelessWidget {
  final Program program;
  const _ProgramPoster({required this.program});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProgramDetailScreen(slug: program.slug)),
      ),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: NetImage(program.cover),
              ),
            ),
            const SizedBox(height: 6),
            Text(program.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

class _DiaSearch extends SearchDelegate {
  final SiteContent content;
  _DiaSearch(this.content);

  @override
  ThemeData appBarTheme(BuildContext context) =>
      buildDiaTheme().copyWith(scaffoldBackgroundColor: DiaColors.bg);

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _results();

  @override
  Widget buildSuggestions(BuildContext context) => _results();

  Widget _results() {
    final q = query.toLowerCase().trim();
    final progs = content.programs
        .where((p) => q.isEmpty || p.title.toLowerCase().contains(q))
        .toList();
    return Container(
      color: DiaColors.bg,
      child: ListView(
        children: [
          for (final p in progs)
            Builder(builder: (context) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                      width: 52, height: 52, child: NetImage(p.cover)),
                ),
                title: Text(p.title),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProgramDetailScreen(slug: p.slug)),
                ),
              );
            }),
        ],
      ),
    );
  }
}
