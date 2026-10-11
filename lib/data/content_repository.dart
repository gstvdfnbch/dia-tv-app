import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../models/models.dart';

/// Repositório de conteúdo da diatv.
///
/// Fonte primária: conteúdo empacotado (assets/content.json), extraído
/// observando exatamente as respostas que o próprio site entrega — o payload
/// RSC embutido no HTML de diaestudio.com/site e os dados de criadores.
///
/// [refreshFromSite] tenta reproduzir, em tempo de execução, a mesma requisição
/// que o site faz para montar a home (GET /site) e a de criadores, extraindo o
/// mesmo payload (`self.__next_f.push`). Se a requisição for bloqueada
/// (checkpoint do Vercel) ou o formato mudar, mantém o conteúdo empacotado.
class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  String get base => AppConfig.instance.siteBaseUrl;
  SiteContent? _cache;

  Future<SiteContent> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/content.json');
    _cache = SiteContent.fromJson(json.decode(raw));
    return _cache!;
  }

  /// Best-effort: busca o conteúdo ao vivo do site. Retorna o conteúdo
  /// atualizado quando consegue, ou o atual (empacotado) em caso de falha.
  Future<SiteContent> refreshFromSite() async {
    final current = await load();
    try {
      final headers = {
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile Safari/604.1',
        'Accept': 'text/html,application/xhtml+xml',
      };
      final homeRes = await http
          .get(Uri.parse(base), headers: headers)
          .timeout(const Duration(seconds: 12));
      if (homeRes.statusCode != 200 ||
          homeRes.body.contains('Vercel Security')) {
        return current;
      }
      final home = _decodePushes(homeRes.body);

      String videoId = current.live.videoId;
      final vm = RegExp(r'"videoId":"([^"]+)"').firstMatch(home);
      if (vm != null) videoId = vm.group(1)!;

      final scheduleRaw = _grab(home, 'programs');
      final schedule = scheduleRaw != null
          ? (json.decode(scheduleRaw) as List)
              .map((e) => ScheduleBlock.fromJson(e))
              .toList()
          : current.schedule;

      final videosRaw = _grab(home, 'videos');
      final sections = videosRaw != null
          ? [
              HomeSection(
                title: 'Não perca nada',
                videos: (json.decode(videosRaw) as List)
                    .map((e) => VideoItem.fromJson(e))
                    .toList(),
              )
            ]
          : current.sections;

      var creators = current.creators;
      try {
        final crRes = await http
            .get(Uri.parse('$base/criadores'), headers: headers)
            .timeout(const Duration(seconds: 12));
        if (crRes.statusCode == 200 &&
            !crRes.body.contains('Vercel Security')) {
          final cr = _decodePushes(crRes.body);
          final crRaw = _grab(cr, 'creators');
          if (crRaw != null) {
            creators = (json.decode(crRaw) as List)
                .map((e) => Creator.fromJson(e))
                .toList();
          }
        }
      } catch (_) {}

      _cache = SiteContent(
        live: LiveInfo(videoId: videoId, title: current.live.title),
        schedule: schedule,
        creators: creators,
        sections: sections,
      );
      return _cache!;
    } catch (_) {
      return current;
    }
  }

  /// Reconstrói o texto do payload RSC a partir das chamadas
  /// `self.__next_f.push([1,"..."])` espalhadas no HTML — o mesmo mecanismo
  /// que o site usa para hidratar o conteúdo no cliente.
  String _decodePushes(String html) {
    final re = RegExp(r'self\.__next_f\.push\((\[.*?\])\)', dotAll: true);
    final sb = StringBuffer();
    for (final m in re.allMatches(html)) {
      try {
        final arr = json.decode(m.group(1)!);
        if (arr is List && arr.length > 1 && arr[1] is String) {
          sb.write(arr[1]);
        }
      } catch (_) {}
    }
    return sb.toString();
  }

  /// Extrai o array JSON balanceado que segue `"key":[`.
  String? _grab(String txt, String key) {
    final start = txt.indexOf('"$key":[');
    if (start < 0) return null;
    final open = txt.indexOf('[', start);
    var depth = 0;
    var inStr = false;
    var esc = false;
    for (var i = open; i < txt.length; i++) {
      final c = txt[i];
      if (inStr) {
        if (esc) {
          esc = false;
        } else if (c == '\\') {
          esc = true;
        } else if (c == '"') {
          inStr = false;
        }
        continue;
      }
      if (c == '"') {
        inStr = true;
      } else if (c == '[') {
        depth++;
      } else if (c == ']') {
        depth--;
        if (depth == 0) return txt.substring(open, i + 1);
      }
    }
    return null;
  }
}
