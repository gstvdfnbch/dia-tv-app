import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'program_detail_screen.dart';

class ProgramacaoScreen extends StatelessWidget {
  final SiteContent content;
  const ProgramacaoScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final blocks = [...content.schedule]
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final onNow = content.onNow;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: DiaColors.bg,
          titleSpacing: 16,
          title: const Text('Programação',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              'A grade da diatv, 24 horas por dia, 7 dias por semana.',
              style: TextStyle(color: DiaColors.textDim),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final b = blocks[i];
              final isNow = onNow?.slug == b.slug &&
                  onNow?.startsAt == b.startsAt;
              return _ScheduleRow(block: b, isNow: isNow);
            },
            childCount: blocks.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final ScheduleBlock block;
  final bool isNow;
  const _ScheduleRow({required this.block, required this.isNow});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProgramDetailScreen(slug: block.slug)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isNow ? DiaColors.surfaceHi : DiaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: isNow
              ? Border.all(color: DiaColors.magenta, width: 1.4)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Column(
                children: [
                  Text(block.startsAt,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(block.endsAt,
                      style: const TextStyle(
                          color: DiaColors.textDim, fontSize: 12)),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 96,
                height: 56,
                child: NetImage(block.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNow)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: DiaColors.magenta,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text('NO AR',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                    ),
                  Text(block.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: DiaColors.textDim),
          ],
        ),
      ),
    );
  }
}
