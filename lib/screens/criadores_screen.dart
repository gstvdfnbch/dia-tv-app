import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class CriadoresScreen extends StatefulWidget {
  final SiteContent content;
  const CriadoresScreen({super.key, required this.content});

  @override
  State<CriadoresScreen> createState() => _CriadoresScreenState();
}

class _CriadoresScreenState extends State<CriadoresScreen> {
  static const double _viewport = 0.6;
  late final PageController _controller;
  double _page = 0;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewport);
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creators = widget.content.creators;
    final selected = creators[_selected.clamp(0, creators.length - 1)];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: DiaColors.bg,
          titleSpacing: 16,
          title: const Text('Criadores e Conteúdos',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Conheça quem faz a diatv e navegue por todos os programas.',
              style: TextStyle(color: DiaColors.textDim),
            ),
          ),
        ),
        // Coverflow carousel
        SliverToBoxAdapter(
          child: SizedBox(
            height: 380,
            child: PageView.builder(
              controller: _controller,
              clipBehavior: Clip.none,
              itemCount: creators.length,
              onPageChanged: (i) => setState(() => _selected = i),
              itemBuilder: (context, i) {
                final delta = (i - _page);
                final abs = delta.abs().clamp(0.0, 1.0);
                final scale = 1 - abs * 0.22;
                final rotation = delta * -0.12;
                return Center(
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: 1 - abs * 0.45,
                        child: _CreatorCoverCard(
                          creator: creators[i],
                          highlighted: abs < 0.5,
                          onTap: () {
                            if (i == _selected) {
                              _openProfile(creators[i]);
                            } else {
                              _controller.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Dots
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < creators.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _selected ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _selected
                          ? DiaColors.magenta
                          : DiaColors.stroke,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Selected creator info card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: _CreatorInfoCard(
              creator: selected,
              onVerPerfil: () => _openProfile(selected),
            ),
          ),
        ),
      ],
    );
  }

  void _openProfile(Creator c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreatorDetailScreen(creator: c)),
    );
  }
}

class _CreatorCoverCard extends StatelessWidget {
  final Creator creator;
  final bool highlighted;
  final VoidCallback onTap;
  const _CreatorCoverCard(
      {required this.creator,
      required this.highlighted,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlighted ? DiaColors.magenta : Colors.transparent,
            width: 2,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: DiaColors.magenta.withValues(alpha: 0.45),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(creator.avatarUrl ?? ''),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 14,
              child: Text(
                creator.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorInfoCard extends StatelessWidget {
  final Creator creator;
  final VoidCallback onVerPerfil;
  const _CreatorInfoCard(
      {required this.creator, required this.onVerPerfil});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DiaColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DiaColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: NetImage(creator.avatarUrl ?? ''),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(creator.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    if (creator.bio != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        creator.bio!,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: DiaColors.textDim, height: 1.4, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final e in creator.socials.entries)
                if (_socialMeta.containsKey(e.key))
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _SocialIcon(
                        icon: _socialMeta[e.key]!.$1, url: e.value),
                  ),
              const Spacer(),
              GradientPill(
                  label: 'Ver perfil',
                  icon: Icons.arrow_forward,
                  onTap: onVerPerfil),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;
  const _SocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: DiaColors.surfaceHi,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: DiaColors.text),
      ),
    );
  }
}

const _socialMeta = <String, (IconData, String)>{
  'youtube': (Icons.smart_display, 'YouTube'),
  'instagram': (Icons.camera_alt_outlined, 'Instagram'),
  'tiktok': (Icons.music_note, 'TikTok'),
  'x': (Icons.close, 'X'),
  'facebook': (Icons.facebook, 'Facebook'),
  'linkedin': (Icons.work_outline, 'LinkedIn'),
  'twitch': (Icons.videogame_asset_outlined, 'Twitch'),
  'whatsapp': (Icons.chat_outlined, 'WhatsApp'),
};

class CreatorDetailScreen extends StatelessWidget {
  final Creator creator;
  const CreatorDetailScreen({super.key, required this.creator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiaColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            backgroundColor: DiaColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(creator.avatarUrl ?? ''),
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
                  Text(creator.name,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                  if (creator.bio != null) ...[
                    const SizedBox(height: 12),
                    Text(creator.bio!,
                        style: const TextStyle(
                            color: DiaColors.textDim, height: 1.5)),
                  ],
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final e in creator.socials.entries)
                        if (_socialMeta.containsKey(e.key))
                          OutlinedButton.icon(
                            onPressed: () async {
                              final uri = Uri.tryParse(e.value);
                              if (uri != null) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DiaColors.text,
                              side: const BorderSide(color: DiaColors.stroke),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999)),
                            ),
                            icon: Icon(_socialMeta[e.key]!.$1, size: 18),
                            label: Text(_socialMeta[e.key]!.$2),
                          ),
                    ],
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
