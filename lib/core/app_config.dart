import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// Camada de configuração do app, com três níveis de precedência (do menor
/// para o maior):
///
/// 1. **Bundle** — `assets/config.json`, embarcado no app.
/// 2. **Build** — `--dart-define` (ex.: `SITE_BASE_URL`, `REMOTE_CONFIG_URL`),
///    útil para ambientes (dev/staging/prod) sem rebuild de assets.
/// 3. **Remoto** — um JSON hospedado em [remoteConfigUrl]. Buscado no boot e
///    mesclado por cima. É isto que permite **controlar o app remotamente no
///    futuro** (trocar a live, URLs, ligar modo manutenção, flags) sem publicar
///    uma nova versão na loja.
///
/// Uso:
/// ```dart
/// await AppConfig.instance.load();          // bundle + dart-define
/// await AppConfig.instance.refreshRemote(); // aplica override remoto (se houver)
/// final url = AppConfig.instance.siteBaseUrl;
/// ```
class AppConfig {
  AppConfig._();
  static final AppConfig instance = AppConfig._();

  Map<String, dynamic> _data = {};
  bool _loaded = false;

  /// Carrega o config embarcado e aplica overrides de `--dart-define`.
  Future<void> load() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      _data = json.decode(raw) as Map<String, dynamic>;
    } catch (e) {
      _data = {};
      debugPrint('AppConfig: falha ao ler assets/config.json: $e');
    }
    _applyDartDefines();
    _loaded = true;
  }

  /// Busca o config remoto (se [remoteConfigUrl] estiver definido) e mescla
  /// por cima do atual. Falha silenciosamente para não quebrar o boot offline.
  Future<void> refreshRemote() async {
    final url = remoteConfigUrl;
    if (url == null || url.isEmpty) return;
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final remote = json.decode(res.body) as Map<String, dynamic>;
        _data = _deepMerge(_data, remote);
      }
    } catch (e) {
      debugPrint('AppConfig: config remoto indisponível: $e');
    }
  }

  void _applyDartDefines() {
    const siteBase = String.fromEnvironment('SITE_BASE_URL');
    const remoteCfg = String.fromEnvironment('REMOTE_CONFIG_URL');
    if (siteBase.isNotEmpty) _data['siteBaseUrl'] = siteBase;
    if (remoteCfg.isNotEmpty) _data['remoteConfigUrl'] = remoteCfg;
  }

  // --- Acesso tipado -------------------------------------------------------

  String get siteBaseUrl =>
      _str(['siteBaseUrl']) ?? 'https://diaestudio.com/site';
  String? get remoteConfigUrl => _str(['remoteConfigUrl']);
  bool get enableRemoteRefresh => _bool(['enableRemoteRefresh'], true);

  String get liveFallbackVideoId =>
      _str(['live', 'fallbackVideoId']) ?? 'Df3g76Y25gs';
  String get liveTitle => _str(['live', 'title']) ?? 'diatv: Ao Vivo';

  String? get supabaseUrl => _str(['supabase', 'url']);
  String? get supabasePublishableKey => _str(['supabase', 'publishableKey']);

  String get loginUrl =>
      _str(['links', 'login']) ?? 'https://diaestudio.com/site/entrar';
  String get ingressosUrl =>
      _str(['links', 'ingressos']) ??
      'https://www.eventim.com.br/artist/diatv/?affiliate=ZR4';
  String get privacidadeUrl =>
      _str(['links', 'privacidade']) ??
      'https://diaestudio.com/site/privacidade';
  String get sobreUrl => _str(['links', 'sobre']) ?? 'https://diaestudio.com/site';

  Map<String, String> get social {
    final m = _data['social'];
    if (m is Map) {
      return {
        for (final e in m.entries)
          if (e.value != null) '${e.key}': '${e.value}'
      };
    }
    return const {};
  }

  bool get maintenanceMode => _bool(['features', 'maintenanceMode'], false);
  String get maintenanceMessage => _str(['features', 'maintenanceMessage']) ?? '';
  bool get showIngressos => _bool(['features', 'showIngressos'], true);

  /// Lê uma flag arbitrária de `features`, para flags adicionadas remotamente
  /// sem alterar o app.
  bool feature(String name, {bool fallback = false}) =>
      _bool(['features', name], fallback);

  // --- Helpers -------------------------------------------------------------

  String? _str(List<String> path) {
    final v = _dig(path);
    return v is String ? v : null;
  }

  bool _bool(List<String> path, bool fallback) {
    final v = _dig(path);
    return v is bool ? v : fallback;
  }

  dynamic _dig(List<String> path) {
    dynamic cur = _data;
    for (final k in path) {
      if (cur is Map && cur.containsKey(k)) {
        cur = cur[k];
      } else {
        return null;
      }
    }
    return cur;
  }

  static Map<String, dynamic> _deepMerge(
      Map<String, dynamic> base, Map<String, dynamic> over) {
    final out = Map<String, dynamic>.from(base);
    over.forEach((k, v) {
      final existing = out[k];
      if (existing is Map<String, dynamic> && v is Map<String, dynamic>) {
        out[k] = _deepMerge(existing, v);
      } else {
        out[k] = v;
      }
    });
    return out;
  }
}
