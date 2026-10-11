import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class CriadoresScreen extends StatelessWidget {
  final SiteContent content;
  const CriadoresScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final creators = content.creators;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: DiaColors.bg,
          titleSpacing: 16,
          title: const Text('Criadores e Conteúdos',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'As vozes que fazem a diatv acontecer.',
              style: TextStyle(color: DiaColors.textDim),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _CreatorCard(creator: creators[i]),
              childCount: creators.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreatorCard extends StatelessWidget {
  final Creator creator;
  const _CreatorCard({required this.creator});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreatorDetailScreen(creator: creator)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: DiaColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: NetImage(creator.avatarUrl ?? '')),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(creator.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

const _socialMeta = {
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
            expandedHeight: 320,
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
                          _SocialButton(
                            icon: _socialMeta[e.key]!.$1,
                            label: _socialMeta[e.key]!.$2,
                            url: e.value,
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

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  const _SocialButton(
      {required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: DiaColors.text,
        side: const BorderSide(color: DiaColors.stroke),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
