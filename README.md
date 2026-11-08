# LocalTube

Player de vídeos **100% local e offline** para **Android** e **Windows**, com interface inspirada no YouTube: grade de miniaturas, tela de reprodução com lista "A seguir", mini-player, histórico, favoritos e playlists.

Nenhum recurso depende de internet e nenhum dado sai do dispositivo.

## Funcionalidades

- **Biblioteca:** escolha pastas, e o LocalTube indexa os vídeos recursivamente em um *Isolate* (sem travar a interface), extrai duração, resolução e codecs, e gera miniaturas em fila (2 por vez).
- **Atualização automática:** detecta arquivos novos, alterados e removidos a cada abertura e ao reescanear. No Windows, também vigia as pastas com `Directory.watch`.
- **Unidades externas:** se uma pasta fica inacessível (pendrive, HD externo, unidade de rede), os vídeos são marcados como indisponíveis, sem apagar histórico nem favoritos.
- **Formatos:** mp4, mkv, avi, mov, webm, flv, wmv, m4v, 3gp, ts, m2ts, mpg/mpeg e ogv, reproduzidos via libmpv/FFmpeg (`media_kit`).
- **Legendas e áudio:** faixas embutidas e legendas externas `.srt`, `.ass`/`.ssa` e `.vtt`. A legenda com o mesmo nome do vídeo é carregada automaticamente. Há ajuste de atraso da legenda e escolha da faixa de áudio.
- **Player:**
  - velocidade de 0,25× a 2×, proporção (ajustar, preencher, 16:9, 4:3), repetir um ou repetir a lista, reprodução automática do próximo;
  - retoma de onde parou (posição salva a cada 5 s; acima de 95 % o vídeo conta como assistido).
- **Android:**
  - toque duplo para ±10 s; arrastar vertical para brilho (lado esquerdo) e volume (lado direito);
  - pinça para zoom; bloqueio de controles;
  - Picture-in-Picture, inclusive automático ao sair do app;
  - girar para paisagem entra em tela cheia.
- **Windows:**
  - layout em duas colunas e modo teatro;
  - arrastar e soltar arquivos ou pastas na janela;
  - "Abrir com", roda do mouse para volume e teclas de mídia;
  - atalhos de teclado (tabela abaixo).
- **Telas:** Início (chips de filtro e "Continuar assistindo"), Pastas (estilo "página de canal"), Playlists (reordenar arrastando, tocar tudo ou aleatório), Biblioteca (Histórico, Favoritos, Assistir mais tarde), Busca (instantânea, com histórico) e Configurações.

### Atalhos de teclado (Windows)

| Tecla | Ação |
|---|---|
| K / Espaço | Play/pause |
| J / L | −10 s / +10 s |
| ← / → | −5 s / +5 s |
| ↑ / ↓ | Volume |
| F | Tela cheia |
| Esc | Sair da tela cheia |
| M | Mudo |
| C | Legendas liga/desliga |
| 0–9 | Pular para 0–90 % |
| Shift+N / Shift+P | Próximo / anterior |
| < / > | Diminuir / aumentar velocidade |
| Ctrl+F | Busca |
| F5 | Reescanear a biblioteca |

## Pré-requisitos

- Flutter **3.47+** (canal stable) e Dart 3.13+.
- **Android:** Android SDK com a plataforma **API 37** instalada (exigida pelo `permission_handler`) e JDK 17+. O Android Studio já inclui os dois. Aparelho com Android 7.0 (API 24) ou superior.
- **Windows:** Windows 10 ou 11 x64 e **Visual Studio 2022** com a carga de trabalho **"Desenvolvimento para desktop com C++"**. O executável do Windows só pode ser gerado em uma máquina Windows.

Confira o ambiente com:

```bash
flutter doctor -v
```

## Como rodar

```bash
flutter pub get
dart run build_runner build   # gera o código do drift e do Riverpod (*.g.dart, *.drift.dart)
flutter run -d windows        # ou: flutter run -d <id-do-aparelho-android>
```

O código gerado já vem no repositório. Rode o `build_runner` de novo sempre que alterar tabelas do banco ou providers anotados com `@riverpod`. Use `dart run build_runner watch` para gerar automaticamente durante o desenvolvimento.

## Builds de release

### Android (APK / AAB)

```bash
flutter build apk --release          # APK universal
flutter build apk --split-per-abi    # APKs menores, um por arquitetura
flutter build appbundle --release    # AAB para a Play Store
```

Os arquivos ficam em `build/app/outputs/`. O build de release usa a chave de debug por padrão. Para publicar, configure sua própria chave de assinatura em `android/app/build.gradle.kts`.

### Windows (executável)

```bash
flutter build windows --release
```

O resultado fica em `build\windows\x64\runner\Release\`. Distribua a **pasta inteira**, não só o `LocalTube.exe`, porque ela contém as DLLs do Flutter e do mpv.

### Instalador para Windows

**Opção 1 – MSIX** (já configurado em `pubspec.yaml`, seção `msix_config`, com `display_name: LocalTube`):

```bash
flutter build windows --release
dart run msix:create
```

O pacote `.msix` é gerado em `build\windows\x64\runner\Release\`. Para instalar fora da Microsoft Store, assine o pacote com um certificado confiável (veja a documentação do pacote [`msix`](https://pub.dev/packages/msix)).

**Opção 2 – Inno Setup:** instale o [Inno Setup 6](https://jrsoftware.org/isinfo.php), gere o build de release e compile o script:

```bash
iscc installer\localtube.iss
```

O instalador (`LocalTube-Setup-1.0.0.exe`) é gerado em `build\installer\` e já registra o LocalTube no "Abrir com".

## Testes

```bash
flutter test
```

A suíte cobre:
- os repositórios (drift em memória);
- a lógica de indexação: diff entre disco e banco, scanner (`.nomedia`, `Android/data`, tamanho mínimo) e o indexador com um extrator de metadados falso;
- os filtros da tela Início e o agrupamento do histórico;
- os formatadores;
- testes de widget do `VideoCard` e da tela Início.

## Arquitetura

```
lib/
├── main.dart                 # inicializa MediaKit, janela (Windows), banco e ProviderScope
├── app.dart                  # LocalTubeApp: tema, rotas, localização, PiP e ciclo de vida
├── l10n/                     # textos em pt-BR (ARB) → AppLocalizations
├── core/
│   ├── db/                   # drift: tabelas e AppDatabase (localtube.db)
│   ├── models/               # VideoItem (vídeo + pasta + progresso)
│   ├── platform/             # android_*.dart, windows_*.dart (PiP, brilho, janela, registro)
│   ├── router/               # go_router com StatefulShellRoute + AppShell
│   ├── theme/                # tema escuro/claro, destaque vermelho, Roboto
│   ├── utils/                # formatadores pt-BR, extensões de vídeo
│   └── widgets/              # VideoCard, VideoListTile, DurationBadge, ProgressOverlay,
│                             # FilterChipsBar, LocalTubeLogo, menu de ações…
└── features/
    ├── home/                 # tela Início, filtros
    ├── folders/              # scanner (Isolate), diff, indexador, extração de metadados
    ├── player/               # PlayerController global, Watch, mini-player, controles, atalhos
    ├── library/              # histórico, favoritos, assistir mais tarde
    ├── playlists/            # playlists
    ├── search/               # busca e histórico de buscas
    └── settings/             # configurações (shared_preferences)
```

- **Estado:** Riverpod com geração de código. Os repositórios expõem streams reativas do drift (`watch`), e a interface se atualiza sozinha.
- **Player único:** o `PlayerController` (provider mantido vivo) guarda um único `Player` do media_kit, compartilhado entre a tela Watch e o mini-player.
- **Banco:** `localtube.db` na pasta de suporte do app. As miniaturas ficam em `<suporte>/thumbs`.

## Observações e limitações

- **"Abrir com" e arrastar arquivos:** se o arquivo não estiver na biblioteca, a pasta dele é adicionada, para que progresso, histórico e "A seguir" funcionem.
- **Aceleração por hardware:** a mudança vale a partir da próxima abertura do app.
- **Remover vídeo da biblioteca:** o arquivo não é apagado do disco, só ocultado. O LocalTube guarda o caminho numa lista de ignorados para não adicioná-lo de novo no próximo scan.
- **Recursos opcionais do pedido original que não foram implementados:**
  - controles na notificação ou na tela de bloqueio para áudio em segundo plano (Android);
  - prévia animada ao passar o mouse sobre o card (Windows; há apenas o efeito de hover).
- **Caminhos longos no Windows:** o executável já declara `longPathAware`, mas o recurso também precisa estar habilitado no sistema (`LongPathsEnabled`).
# localtube
