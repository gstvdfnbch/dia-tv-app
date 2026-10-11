# diatv app (Flutter)

Reprodução, em Flutter, do site [diaestudio.com/site](https://diaestudio.com/site) — a
"televisão de graça na internet" da diatv. Replica a experiência de navegação em
quatro abas e consome o mesmo conteúdo que o site usa.

## Tab bar

| Aba | Tela | Espelha |
|-----|------|---------|
| **Home** | `screens/home_screen.dart` | `/site` — ao vivo, carrosséis de vídeos e programas |
| **Programação** | `screens/programacao_screen.dart` | `/site/programacao` — grade 24h com "no ar agora" |
| **Criadores** | `screens/criadores_screen.dart` | `/site/criadores` — 16 criadores, bio e redes |
| **Conta** | `screens/conta_screen.dart` | `/site/entrar` — login, favoritos, notificações |

## De onde vem o conteúdo

O site é um app **Next.js** (App Router). O conteúdo não vem de uma API REST
pública no cliente: ele é entregue **server-rendered**, embutido no HTML como
payload RSC (React Server Components) através de chamadas
`self.__next_f.push([1,"..."])`. As imagens ficam no **storage público do
Supabase** (`…supabase.co/storage/v1/object/public/…`) com fallback para as
thumbs do YouTube (`i.ytimg.com`). O player ao vivo e os vídeos usam o **embed do
YouTube** (`youtube.com/embed/<id>`).

Este app reproduz esse fluxo:

1. **`assets/content.json`** — conteúdo extraído observando exatamente a resposta
   do site (payload RSC da home e da página de criadores): vídeo ao vivo, grade
   de programação (64 blocos com horário/dias), 16 criadores e vídeos recentes.
2. **`data/content_repository.dart`** — carrega o conteúdo empacotado e, em
   seguida, tenta `refreshFromSite()`: faz `GET /site` e `/site/criadores`,
   reconstrói o payload a partir dos `self.__next_f.push(...)` (mesmo mecanismo do
   site) e extrai os arrays `programs`, `videos`, `creators` e o `videoId` da
   live. Se a requisição for bloqueada (checkpoint do Vercel) ou o formato mudar,
   mantém o conteúdo empacotado — o app nunca fica vazio.

Modelos de dados em `models/models.dart` espelham os objetos reais do site
(`ScheduleBlock`, `VideoItem`, `Creator`, etc.).

## Configuração (controle remoto)

`core/app_config.dart` + `assets/config.json` centralizam tudo que pode mudar
sem recompilar: base URL do site, URLs de login/ingressos/privacidade, redes
sociais, fallback da live, dados do Supabase e feature flags
(`maintenanceMode`, `showIngressos`, …). Precedência, do menor para o maior:

1. **Bundle** — `assets/config.json`.
2. **Build** — `--dart-define=SITE_BASE_URL=…` / `--dart-define=REMOTE_CONFIG_URL=…`.
3. **Remoto** — um JSON hospedado em `remoteConfigUrl`, buscado no boot e
   mesclado por cima (deep-merge). É o que permite **controlar o app
   remotamente** depois de publicado: trocar a live, URLs ou ligar o modo
   manutenção sem passar pela loja.

Para ativar o controle remoto, basta apontar `remoteConfigUrl` (no
`assets/config.json` ou via dart-define) para um JSON com as chaves a
sobrescrever, por exemplo:

```json
{ "live": { "fallbackVideoId": "NOVO_ID" }, "features": { "showIngressos": false } }
```

## Rodar

```bash
flutter pub get
flutter run        # iOS Simulator, Android, etc.
```

Dependências principais: `youtube_player_iframe` (player), `cached_network_image`
(capas/thumbs), `url_launcher` (login/redes), `http` (refresh do conteúdo).
