import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../core/theme.dart';
import '../widgets/common.dart';

/// Player de vídeo via embed do YouTube — o mesmo mecanismo do site
/// (iframe `youtube.com/embed/<id>`).
class PlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String? subtitle;
  final bool isLive;
  const PlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    this.subtitle,
    this.isLive = false,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        enableJavaScript: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiaColors.bg,
      appBar: AppBar(title: const DiaLogo()),
      body: ListView(
        children: [
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isLive)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DiaColors.magenta,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('AO VIVO',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                  ),
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(widget.subtitle!,
                      style: const TextStyle(color: DiaColors.textDim)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
