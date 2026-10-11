import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/content_repository.dart';
import 'models/models.dart';
import 'screens/conta_screen.dart';
import 'screens/criadores_screen.dart';
import 'screens/home_screen.dart';
import 'screens/programacao_screen.dart';

void main() {
  runApp(const DiaTvApp());
}

class DiaTvApp extends StatelessWidget {
  const DiaTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'diatv',
      debugShowCheckedModeBanner: false,
      theme: buildDiaTheme(),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  SiteContent? _content;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Carrega o conteúdo empacotado (extraído do site) e exibe imediatamente.
    final c = await ContentRepository.instance.load();
    if (mounted) setState(() => _content = c);
    // Em seguida, tenta atualizar com o conteúdo ao vivo do site.
    final fresh = await ContentRepository.instance.refreshFromSite();
    if (mounted && !identical(fresh, c)) setState(() => _content = fresh);
  }

  @override
  Widget build(BuildContext context) {
    final c = _content;
    if (c == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = [
      HomeScreen(content: c, onVerProgramacao: () => setState(() => _index = 1)),
      ProgramacaoScreen(content: c),
      CriadoresScreen(content: c),
      const ContaScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: DiaColors.surface,
          indicatorColor: DiaColors.magenta.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: DiaColors.pink),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view, color: DiaColors.pink),
                label: 'Programação'),
            NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people, color: DiaColors.pink),
                label: 'Criadores'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: DiaColors.pink),
                label: 'Conta'),
          ],
        ),
      ),
    );
  }
}
