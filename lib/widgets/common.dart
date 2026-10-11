import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Logo textual "diatv" com o ponto final em magenta, como no site.
class DiaLogo extends StatelessWidget {
  final double size;
  const DiaLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          margin: const EdgeInsets.only(right: 6),
          decoration: const BoxDecoration(
            gradient: DiaColors.accent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.play_arrow_rounded,
              size: size * 0.7, color: Colors.white),
        ),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: DiaColors.text,
            ),
            children: const [
              TextSpan(text: 'diatv'),
              TextSpan(text: '.', style: TextStyle(color: DiaColors.magenta)),
            ],
          ),
        ),
      ],
    );
  }
}

class GradientPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  const GradientPill({super.key, required this.label, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: DiaColors.accent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(color: DiaColors.surfaceHi);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, __) => Container(color: DiaColors.surfaceHi),
      errorWidget: (_, __, ___) => Container(
        color: DiaColors.surfaceHi,
        child: const Icon(Icons.image_not_supported_outlined,
            color: DiaColors.textDim),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      color: DiaColors.pink, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

String formatViews(int? n) {
  if (n == null) return '';
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)} mil';
  return '$n';
}
