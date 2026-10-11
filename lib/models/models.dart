// Modelos que espelham o payload de conteúdo do site diatv.

class LiveInfo {
  final String videoId;
  final String title;
  const LiveInfo({required this.videoId, required this.title});

  factory LiveInfo.fromJson(Map<String, dynamic> j) =>
      LiveInfo(videoId: j['videoId'] ?? '', title: j['title'] ?? 'Ao Vivo');
}

/// Um bloco da grade de programação (programs[] no site).
class ScheduleBlock {
  final String slug;
  final String title;
  final String startsAt; // "HH:mm"
  final String endsAt;
  final String? imageUrl;
  final List<String> fallbackImageUrls;
  final String? href;
  final List<int> weekdays; // 0=dom ... 6=sab

  const ScheduleBlock({
    required this.slug,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    this.imageUrl,
    this.fallbackImageUrls = const [],
    this.href,
    this.weekdays = const [],
  });

  factory ScheduleBlock.fromJson(Map<String, dynamic> j) => ScheduleBlock(
        slug: j['slug'] ?? '',
        title: j['title'] ?? '',
        startsAt: j['startsAt'] ?? '',
        endsAt: j['endsAt'] ?? '',
        imageUrl: j['imageUrl'],
        fallbackImageUrls:
            (j['fallbackImageUrls'] as List?)?.map((e) => '$e').toList() ??
                const [],
        href: j['href'],
        weekdays:
            (j['weekdays'] as List?)?.map((e) => (e as num).toInt()).toList() ??
                const [],
      );

  String get cover =>
      imageUrl ?? (fallbackImageUrls.isNotEmpty ? fallbackImageUrls.first : '');

  int get startMinutes {
    final p = startsAt.split(':');
    if (p.length < 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  /// Minuto de término no dia; se o bloco vira a meia-noite, soma 24h.
  int get endMinutes {
    final p = endsAt.split(':');
    if (p.length < 2) return startMinutes;
    var e = (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
    if (e <= startMinutes) e += 24 * 60;
    return e;
  }
}

class VideoItem {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final String? durationLabel;
  final int? viewCount;
  final int? likeCount;
  final String? publishedAt;
  final String? liveBroadcastContent;

  const VideoItem({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    this.durationLabel,
    this.viewCount,
    this.likeCount,
    this.publishedAt,
    this.liveBroadcastContent,
  });

  factory VideoItem.fromJson(Map<String, dynamic> j) => VideoItem(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        thumbnailUrl: j['thumbnailUrl'],
        durationLabel: j['durationLabel'],
        viewCount: (j['viewCount'] as num?)?.toInt(),
        likeCount: (j['likeCount'] as num?)?.toInt(),
        publishedAt: j['publishedAt'],
        liveBroadcastContent: j['liveBroadcastContent'],
      );

  bool get isLive => liveBroadcastContent == 'live';
}

class HomeSection {
  final String title;
  final List<VideoItem> videos;
  const HomeSection({required this.title, required this.videos});
}

class Creator {
  final String id;
  final String name;
  final String slug;
  final String? avatarUrl;
  final String? bio;
  final Map<String, String> socials;

  const Creator({
    required this.id,
    required this.name,
    required this.slug,
    this.avatarUrl,
    this.bio,
    this.socials = const {},
  });

  factory Creator.fromJson(Map<String, dynamic> j) {
    final raw = (j['socials'] as Map?) ?? {};
    final socials = <String, String>{};
    raw.forEach((k, v) {
      if (v != null && '$v'.isNotEmpty) socials['$k'] = '$v';
    });
    return Creator(
      id: j['id'] ?? '',
      name: j['name'] ?? '',
      slug: j['slug'] ?? '',
      avatarUrl: j['avatarUrl'],
      bio: j['bio'],
      socials: socials,
    );
  }
}

/// Programa único (derivado da grade) para a aba Programação / catálogo.
class Program {
  final String slug;
  final String title;
  final String cover;
  final String? href;
  const Program({
    required this.slug,
    required this.title,
    required this.cover,
    this.href,
  });
}

class SiteContent {
  final LiveInfo live;
  final List<ScheduleBlock> schedule;
  final List<Creator> creators;
  final List<HomeSection> sections;

  const SiteContent({
    required this.live,
    required this.schedule,
    required this.creators,
    required this.sections,
  });

  factory SiteContent.fromJson(Map<String, dynamic> j) => SiteContent(
        live: LiveInfo.fromJson(j['live'] ?? {}),
        schedule: (j['schedule'] as List? ?? [])
            .map((e) => ScheduleBlock.fromJson(e))
            .toList(),
        creators: (j['creators'] as List? ?? [])
            .map((e) => Creator.fromJson(e))
            .toList(),
        sections: (j['sections'] as List? ?? [])
            .map((e) => HomeSection(
                  title: (e['title'] ?? 'Novidades').toString(),
                  videos: (e['videos'] as List? ?? [])
                      .map((v) => VideoItem.fromJson(v))
                      .toList(),
                ))
            .toList(),
      );

  /// Catálogo de programas únicos, preservando a ordem da grade.
  List<Program> get programs {
    final seen = <String>{};
    final out = <Program>[];
    for (final b in schedule) {
      if (b.slug.isEmpty || seen.contains(b.slug)) continue;
      seen.add(b.slug);
      out.add(Program(
        slug: b.slug,
        title: b.title,
        cover: b.cover,
        href: b.href,
      ));
    }
    out.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return out;
  }

  /// O que está no ar agora, com base no horário local.
  ScheduleBlock? get onNow {
    if (schedule.isEmpty) return null;
    final now = DateTime.now();
    final mins = now.hour * 60 + now.minute;
    for (final b in schedule) {
      final s = b.startMinutes;
      final eP = b.endsAt.split(':');
      var e = eP.length >= 2
          ? (int.tryParse(eP[0]) ?? 0) * 60 + (int.tryParse(eP[1]) ?? 0)
          : s;
      if (e <= s) e += 24 * 60; // vira o dia
      if (mins >= s && mins < e) return b;
      if (mins + 24 * 60 >= s && mins + 24 * 60 < e) return b;
    }
    return schedule.first;
  }
}
