import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../widgets/common.dart';

/// Aba Conta — espelha a área do usuário do site (entrar, favoritos,
/// continuar assistindo e notificações). A autenticação real usa o OAuth
/// do site (Supabase); aqui abrimos o fluxo de login oficial.
class ContaScreen extends StatelessWidget {
  const ContaScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: DiaColors.bg,
          titleSpacing: 16,
          title: const Text('Conta',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A1140), Color(0xFF3A0F2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DiaLogo(size: 24),
                  const SizedBox(height: 14),
                  const Text('Entre na diatv',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text(
                    'Salve favoritos, continue de onde parou e receba '
                    'novidades dos seus programas.',
                    style: TextStyle(color: DiaColors.textDim, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _open('https://diaestudio.com/site/entrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Entrar com Google',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SectionHeader('Minha diatv')),
        SliverToBoxAdapter(
          child: Column(
            children: const [
              _AccountTile(
                  icon: Icons.favorite_border,
                  title: 'Favoritos',
                  subtitle: 'Entre para ver seus programas salvos'),
              _AccountTile(
                  icon: Icons.history,
                  title: 'Continuar assistindo',
                  subtitle: 'Retome de onde parou'),
              _AccountTile(
                  icon: Icons.notifications_none,
                  title: 'Notificações',
                  subtitle: 'Avisos de novos episódios e lives'),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SectionHeader('diatv')),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _AccountTile(
                icon: Icons.confirmation_number_outlined,
                title: 'Ingressos',
                subtitle: 'Eventos e shows da diatv',
                onTap: () => _open(
                    'https://www.eventim.com.br/artist/diatv/?affiliate=ZR4'),
              ),
              _AccountTile(
                icon: Icons.info_outline,
                title: 'Quem somos',
                onTap: () => _open('https://diaestudio.com/site'),
              ),
              _AccountTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacidade',
                onTap: () => _open('https://diaestudio.com/site/privacidade'),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SectionHeader('Siga a diatv')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _social('YouTube', 'https://www.youtube.com/@DiaTV'),
                _social('Instagram', 'https://www.instagram.com/diaestudio'),
                _social('TikTok', 'https://www.tiktok.com/@diaestudio'),
                _social('Facebook', 'https://www.facebook.com/DiaEstudioBR'),
                _social('X', 'https://twitter.com/diaestudio'),
                _social('LinkedIn',
                    'https://www.linkedin.com/company/dia-estúdio'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _social(String label, String url) => Builder(
        builder: (context) => OutlinedButton(
          onPressed: () => _open(url),
          style: OutlinedButton.styleFrom(
            foregroundColor: DiaColors.text,
            side: const BorderSide(color: DiaColors.stroke),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
          ),
          child: Text(label),
        ),
      );
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _AccountTile(
      {required this.icon, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: DiaColors.surfaceHi,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: DiaColors.pink, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: DiaColors.textDim))
          : null,
      trailing: const Icon(Icons.chevron_right, color: DiaColors.textDim),
      onTap: onTap,
    );
  }
}
