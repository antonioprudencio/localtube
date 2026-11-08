# Prompt — LocalTube: app Flutter de reprodução local de vídeos (interface estilo YouTube)

Você é um desenvolvedor Flutter sênior. Crie um app completo, pronto para rodar, chamado **LocalTube**: um player de vídeos **100% local/offline** com interface inspirada no YouTube.

## 0. Identidade do app
- Nome exibido: **LocalTube** (título da janela no Windows, rótulo do app no Android, AppBar e tela "Sobre").
- Nome do pacote Dart (`pubspec.yaml`): `localtube`.
- `applicationId` / namespace Android: `com.localtube.app`.
- Executável Windows: `LocalTube.exe` (ajustar `BINARY_NAME` no CMake e os metadados em `Runner.rc`: ProductName e FileDescription = "LocalTube").
- Criar o projeto com: `flutter create --org com.localtube --project-name localtube --platforms android,windows .`
- Logo próprio simples (ícone de "play" estilizado + texto "LocalTube"), sem usar a marca do YouTube. Gerar ícones com `flutter_launcher_icons` para Android e Windows.

## 1. Objetivo
Permitir ao usuário escolher pastas do dispositivo, indexar todos os vídeos encontrados e navegá-los/reproduzi-los numa interface familiar ao YouTube (grade de miniaturas, tela de reprodução com lista "A seguir", histórico, playlists). Nenhum recurso depende de internet.

## 2. Plataformas
- Somente **Android** (mínimo API 24 / Android 7.0) e **Windows** (10 e 11, x64). Não é necessário suporte a iOS, macOS, Linux ou Web — remova essas pastas do projeto.
- Layout responsivo: celular (retrato/paisagem) e tablet no Android; janela redimensionável no Windows (largura mínima 800 px).

## 3. Stack técnica (usar versões estáveis mais recentes)
- Flutter stable, Dart 3, null-safety, Material 3.
- **Reprodução:** `media_kit`, `media_kit_video`, `media_kit_libs_video` (baseado em libmpv/FFmpeg — garante suporte amplo a formatos no Android e no Windows).
- **Estado:** `flutter_riverpod` (com code generation `riverpod_annotation`).
- **Navegação:** `go_router` (com ShellRoute para manter a navegação inferior/lateral e o mini-player).
- **Banco local:** `drift` (SQLite) para biblioteca, histórico, progresso, favoritos e playlists. Arquivo do banco: `localtube.db`.
- **Arquivos/permissões:** `file_picker` (seleção de pastas), `permission_handler` (Android), `path_provider`, `path`.
- **Outros:** `wakelock_plus` (tela ligada durante reprodução), `screen_brightness` (gesto de brilho no Android), `window_manager` (tela cheia, tamanho mínimo e título "LocalTube" da janela no Windows), `shared_preferences` (configurações simples), `flutter_launcher_icons` (ícones).
- Miniaturas: gerar capturando um frame (~10% da duração) via `Player.screenshot()` do media_kit em um player oculto; salvar em cache no disco (`getApplicationSupportDirectory()/thumbs`).

## 4. Formatos suportados
- Contêineres: **mp4, mkv, avi, mov, webm, flv, wmv, m4v, 3gp, ts, m2ts, mpg/mpeg, ogv**.
- Codecs: H.264, H.265/HEVC, VP8/VP9, AV1, MPEG-2/4, e áudio AAC, MP3, AC3/E-AC3, DTS, Opus, FLAC.
- Legendas: embutidas (múltiplas faixas) e externas **.srt, .ass/.ssa, .vtt** — carregar automaticamente legenda com o mesmo nome do vídeo na mesma pasta.
- Múltiplas faixas de áudio selecionáveis.
- Arquivo não reproduzível: mostrar mensagem amigável, sem travar o app.

## 5. Interface (inspirada no YouTube — sem usar logo, nome ou marcas do YouTube)
**Tema:** escuro por padrão (opção claro/sistema), cor de destaque vermelha, tipografia Roboto, cantos arredondados nas miniaturas (12 px).

**Estrutura de navegação**
- Android (celular): `NavigationBar` inferior com **Início**, **Pastas**, **Playlists**, **Biblioteca** (histórico + favoritos).
- Windows e tablets largos: `NavigationRail`/drawer lateral recolhível com os mesmos itens.
- AppBar: logo do LocalTube à esquerda, ícone/campo de **busca**, botão de **adicionar pasta**, menu de configurações.

**Tela Início**
- Linha de **chips de filtro** rolável horizontalmente: "Todos", nomes das pastas, "Continuar assistindo", "Recentes", "Não assistidos", formatos.
- **Grade responsiva** de cards (1 coluna no celular, 2–5 no Windows conforme largura da janela):
  - Miniatura 16:9 com **selo de duração** no canto inferior direito.
  - **Barra de progresso vermelha** na base da miniatura se o vídeo foi parcialmente assistido.
  - Abaixo: ícone circular da pasta (inicial da pasta como "avatar do canal"), título (máx. 2 linhas), linha de metadados: `nome da pasta • 1,2 GB • 1080p • há 3 dias`.
  - Menu "⋮" (e clique direito no Windows): adicionar à playlist, favoritar, marcar como assistido, informações do arquivo, abrir no Explorador de Arquivos (Windows), remover da biblioteca.
  - Windows: efeito de hover no card e prévia animada opcional ao passar o mouse.
- Seção "Continuar assistindo" no topo (lista horizontal) quando houver.
- Estado vazio (primeira execução): tela de boas-vindas "Bem-vindo ao LocalTube" com botão "Adicionar pasta de vídeos".
- Pull-to-refresh (Android) / botão e tecla F5 (Windows) para reescanear.
- Windows: aceitar **arrastar e soltar** arquivos ou pastas na janela para reproduzir/adicionar.

**Tela de reprodução (Watch)**
- Android: player no topo (16:9), abaixo título, metadados, linha de **botões em pílula** (Favoritar, Salvar na playlist, Repetir, Info), seção expansível de **detalhes técnicos** (caminho, codec, resolução, bitrate, tamanho), e lista **"A seguir"** (próximos vídeos da mesma pasta/playlist). Girar para paisagem entra em tela cheia.
- Windows: layout de **duas colunas** — player + detalhes à esquerda, "A seguir" à direita; modo teatro opcional. Título da janela: "<nome do vídeo> — LocalTube".
- **Mini-player:** ao voltar/navegar, o vídeo continua num mini-player (acima da barra inferior no Android; canto inferior direito no Windows). Arrastar para baixo minimiza, tocar/clicar expande, X fecha.

**Controles do player**
- Play/pause, barra de busca com prévia de tempo, tempo atual/total, próximo/anterior.
- Android: toque duplo esquerda/direita = −10 s/+10 s com animação; arrastar vertical à esquerda = brilho, à direita = volume; pinça = zoom/preencher; bloqueio de tela; **Picture-in-Picture**; controles na notificação/tela de bloqueio para áudio em segundo plano (opcional).
- Windows: clique no vídeo = play/pause, duplo clique = tela cheia, roda do mouse = volume; integração com teclas de mídia do teclado.
- Velocidade 0,25×–2×; seleção de legenda (incluindo carregar arquivo externo), atraso de legenda, faixa de áudio; proporção (ajustar, preencher, 16:9, 4:3); tela cheia; repetir um / repetir lista; reprodução automática do próximo.
- Atalhos de teclado (Windows): **K/Espaço** play/pause, **J/L** ±10 s, **←/→** ±5 s, **↑/↓** volume, **F** tela cheia, **M** mudo, **C** legendas, **0–9** pular para 0–90 %, **Shift+N/P** próximo/anterior, **<, >** velocidade, **Esc** sair da tela cheia, **Ctrl+F** busca.
- Controles se escondem após 3 s de inatividade (no Windows, o cursor também some).
- **Retomar de onde parou** (salvar posição a cada 5 s e ao sair; vídeo com >95 % assistido = concluído).

**Outras telas**
- **Pastas:** lista de pastas monitoradas com contagem e tamanho; abrir mostra a grade da pasta (estilo "página de canal" com banner e nome). Adicionar/remover pasta.
- **Playlists:** criar, renomear, excluir, reordenar itens (drag & drop), tocar tudo / aleatório.
- **Biblioteca:** Histórico (agrupado por Hoje/Ontem/Esta semana, com opção de limpar), Favoritos, Assistir mais tarde.
- **Busca:** por nome do arquivo e pasta, com resultados instantâneos e histórico de buscas.
- **Configurações:** tema, pastas, extensões indexadas, ignorar arquivos menores que X MB, reprodução automática, velocidade padrão, idioma preferido de legenda/áudio, aceleração por hardware on/off, limpar cache de miniaturas, reescanear biblioteca, **Sobre o LocalTube** (versão, licenças). No Windows: opção de associar o LocalTube às extensões de vídeo ("Abrir com").

## 6. Biblioteca e indexação
- Escanear pastas recursivamente em **Isolate** (não bloquear a UI), filtrando pelas extensões suportadas.
- Extrair metadados (duração, resolução, codecs, faixas) e gerar miniaturas de forma **incremental e em fila** com concorrência limitada (2–3 por vez); a UI mostra placeholder shimmer até a miniatura ficar pronta.
- Detectar arquivos novos/removidos/alterados (por caminho + tamanho + data de modificação) a cada abertura e ao reescanear; no Windows, usar `Directory.watch` para atualização automática.
- Android: tratar permissões `READ_MEDIA_VIDEO` (API 33+) e `READ_EXTERNAL_STORAGE` (≤ 32); explicar ao usuário antes de pedir ("O LocalTube precisa acessar seus vídeos…"). Ignorar pastas `Android/data` e arquivos `.nomedia`.
- Windows: suportar caminhos longos, unidades externas/USB e unidades de rede mapeadas; tratar unidade desconectada sem apagar o histórico (marcar vídeo como "indisponível").
- Windows: ao abrir o LocalTube por um arquivo (argumento de linha de comando / "Abrir com"), reproduzir esse arquivo direto.

## 7. Modelo de dados (drift)
- `folders(id, path, name, addedAt, lastScanAt)`
- `videos(id, folderId, path, fileName, title, sizeBytes, durationMs, width, height, videoCodec, audioCodec, container, modifiedAt, addedAt, thumbPath, isFavorite, watchLater, isAvailable)`
- `playback_state(videoId, positionMs, completed, lastPlayedAt, playCount, audioTrack, subtitleTrack, speed)`
- `playlists(id, name, createdAt)` e `playlist_items(playlistId, videoId, position)`
- `search_history(term, createdAt)`

## 8. Arquitetura
- Organização **feature-first**: `lib/core` (tema, rotas, utils, db, platform), `lib/features/{home,player,library,folders,playlists,search,settings}` cada uma com `data/`, `domain/`, `presentation/`.
- Classe raiz do app: `LocalTubeApp` em `lib/app.dart`; `main.dart` só inicializa `MediaKit.ensureInitialized()`, `window_manager` (Windows), banco e `ProviderScope`.
- Código específico de plataforma isolado em `lib/core/platform/` (ex.: `android_*.dart`, `windows_*.dart`) usando `Platform.isAndroid` / `Platform.isWindows`.
- Repositórios abstraem drift e sistema de arquivos; providers Riverpod expõem streams reativas (`watch` do drift) para a UI.
- Um único `PlayerController` global (provider mantido vivo) para o mini-player e a tela de reprodução compartilharem o mesmo `Player`.
- Widgets reutilizáveis: `VideoCard`, `VideoListTile`, `DurationBadge`, `ProgressOverlay`, `FilterChipsBar`, `PlayerControls`, `MiniPlayer`, `LocalTubeLogo`.

## 9. Requisitos não funcionais
- Rolagem fluida a 60 fps em bibliotecas com **5.000+ vídeos** (grades lazy, cache de imagens com `cacheWidth`).
- Abrir vídeo em < 1 s em arquivos locais.
- Funciona totalmente offline; nenhum dado sai do dispositivo.
- Interface em **português do Brasil** (estruturada com `flutter_localizations`/ARB para permitir outros idiomas).
- Acessibilidade: rótulos semânticos, áreas de toque ≥ 48 dp, contraste adequado, navegação completa por teclado no Windows.
- Tratamento de erros com mensagens claras; logs em modo debug.

## 10. Entregáveis
1. Projeto Flutter `localtube` completo apenas com as pastas `android/` e `windows/`, incluindo `pubspec.yaml` e configurações nativas: AndroidManifest com `android:label="LocalTube"`, permissões, PiP (`supportsPictureInPicture`) e `configChanges`; no Windows, `LocalTube.exe`, ícone, metadados do `Runner.rc` e tamanho mínimo da janela.
2. Código-fonte de todas as telas e funcionalidades acima.
3. Testes unitários dos repositórios e da lógica de indexação; teste de widget do `VideoCard` e da tela Início.
4. `README.md` do LocalTube com: como rodar, pré-requisitos (Visual Studio com "Desenvolvimento para desktop com C++" para Windows; Android SDK), como gerar **APK/AAB** (`flutter build apk --release`) e **executável Windows** (`flutter build windows --release`), e como empacotar um instalador Windows (MSIX via pacote `msix` com `display_name: LocalTube`, ou Inno Setup).

## 11. Ordem de implementação sugerida
1. Criação do projeto, identidade (nome, ícones), tema, rotas e navegação responsiva (barra inferior no Android, rail lateral no Windows).
2. Banco (drift) + adicionar pastas + scanner em isolate + permissões Android.
3. Tela Início com grade, chips, miniaturas e estado vazio.
4. Tela de reprodução com media_kit e controles completos (gestos no Android, teclado/mouse no Windows).
5. Retomar posição, histórico, favoritos.
6. Mini-player e PiP (Android).
7. Playlists, busca, configurações, arrastar e soltar e "Abrir com" (Windows).
8. Polimento, testes, README e builds de release.

Ao responder, entregue o código arquivo por arquivo, com o caminho completo de cada um, e não omita partes com "// resto do código".
