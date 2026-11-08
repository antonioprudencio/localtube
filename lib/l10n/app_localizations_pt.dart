// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'LocalTube';

  @override
  String get navHome => 'Início';

  @override
  String get navFolders => 'Pastas';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionAddFolder => 'Adicionar pasta';

  @override
  String get actionSettings => 'Configurações';

  @override
  String get actionRescan => 'Reescanear biblioteca';

  @override
  String get actionMenu => 'Mais opções';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionRemove => 'Remover';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionCreate => 'Criar';

  @override
  String get actionRename => 'Renomear';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClear => 'Limpar';

  @override
  String get welcomeTitle => 'Bem-vindo ao LocalTube';

  @override
  String get welcomeBody =>
      'Adicione uma pasta com vídeos do seu dispositivo. Tudo fica no seu aparelho — nada é enviado para a internet.';

  @override
  String get welcomeButton => 'Adicionar pasta de vídeos';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterContinue => 'Continuar assistindo';

  @override
  String get filterRecent => 'Recentes';

  @override
  String get filterUnwatched => 'Não assistidos';

  @override
  String get emptyFilter => 'Nenhum vídeo encontrado com este filtro.';

  @override
  String get sectionContinue => 'Continuar assistindo';

  @override
  String get menuAddToPlaylist => 'Salvar na playlist';

  @override
  String get menuFavorite => 'Favoritar';

  @override
  String get menuUnfavorite => 'Remover dos favoritos';

  @override
  String get menuWatchLater => 'Assistir mais tarde';

  @override
  String get menuRemoveWatchLater => 'Remover de Assistir mais tarde';

  @override
  String get menuMarkWatched => 'Marcar como assistido';

  @override
  String get menuMarkUnwatched => 'Marcar como não assistido';

  @override
  String get menuInfo => 'Informações do arquivo';

  @override
  String get menuOpenInExplorer => 'Mostrar no Explorador de Arquivos';

  @override
  String get menuRemoveFromLibrary => 'Remover da biblioteca';

  @override
  String get menuRemoveFromHistory => 'Remover do histórico';

  @override
  String get removeFromLibraryConfirm =>
      'O arquivo não será apagado do disco, apenas ocultado do LocalTube.';

  @override
  String get infoPath => 'Caminho';

  @override
  String get infoSize => 'Tamanho';

  @override
  String get infoDuration => 'Duração';

  @override
  String get infoResolution => 'Resolução';

  @override
  String get infoVideoCodec => 'Codec de vídeo';

  @override
  String get infoAudioCodec => 'Codec de áudio';

  @override
  String get infoContainer => 'Formato';

  @override
  String get infoBitrate => 'Taxa de bits';

  @override
  String get infoModified => 'Modificado em';

  @override
  String get infoFolder => 'Pasta';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get unavailable => 'Indisponível';

  @override
  String get permissionTitle => 'Acesso aos vídeos';

  @override
  String get permissionBody =>
      'O LocalTube precisa acessar seus vídeos para montar a biblioteca. Os arquivos são lidos apenas no seu dispositivo e nunca saem dele.';

  @override
  String get permissionContinue => 'Continuar';

  @override
  String get permissionDenied =>
      'Sem permissão para acessar os vídeos. Permita o acesso nas configurações do sistema.';

  @override
  String get openSystemSettings => 'Abrir configurações';

  @override
  String folderAdded(String name) {
    return 'Pasta adicionada: $name';
  }

  @override
  String get scanning => 'Escaneando pastas…';

  @override
  String processing(int count) {
    return 'Gerando miniaturas ($count restantes)';
  }

  @override
  String get dropHere => 'Solte arquivos de vídeo ou pastas aqui';

  @override
  String get watchFavorite => 'Favoritar';

  @override
  String get watchFavorited => 'Favorito';

  @override
  String get watchSave => 'Salvar';

  @override
  String get watchRepeat => 'Repetir';

  @override
  String get watchInfo => 'Info';

  @override
  String get watchDetails => 'Detalhes técnicos';

  @override
  String get upNext => 'A seguir';

  @override
  String get autoplay => 'Reprodução automática';

  @override
  String get playerError => 'Não foi possível reproduzir este arquivo.';

  @override
  String get playerErrorDetail =>
      'O formato pode não ser suportado ou o arquivo pode estar corrompido.';

  @override
  String get fileUnavailable =>
      'Arquivo indisponível. Verifique se a unidade está conectada.';

  @override
  String get nothingPlaying => 'Nenhum vídeo em reprodução.';

  @override
  String get play => 'Reproduzir';

  @override
  String get pause => 'Pausar';

  @override
  String get next => 'Próximo';

  @override
  String get previous => 'Anterior';

  @override
  String get mute => 'Mudo';

  @override
  String get unmute => 'Ativar som';

  @override
  String get fullscreen => 'Tela cheia';

  @override
  String get exitFullscreen => 'Sair da tela cheia';

  @override
  String get playerSettings => 'Configurações do player';

  @override
  String get speed => 'Velocidade';

  @override
  String get subtitles => 'Legendas';

  @override
  String get subtitlesOff => 'Desativadas';

  @override
  String get subtitlesAuto => 'Automático';

  @override
  String get loadSubtitle => 'Carregar arquivo de legenda…';

  @override
  String get subtitleDelay => 'Atraso da legenda';

  @override
  String get audioTrack => 'Faixa de áudio';

  @override
  String get aspect => 'Proporção';

  @override
  String get aspectFit => 'Ajustar';

  @override
  String get aspectFill => 'Preencher';

  @override
  String get repeatOff => 'Não repetir';

  @override
  String get repeatOne => 'Repetir este vídeo';

  @override
  String get repeatAll => 'Repetir lista';

  @override
  String get lockControls => 'Bloquear controles';

  @override
  String get unlockHint => 'Toque no cadeado para desbloquear';

  @override
  String get pictureInPicture => 'Picture-in-Picture';

  @override
  String get theaterMode => 'Modo teatro';

  @override
  String trackN(int n) {
    return 'Faixa $n';
  }

  @override
  String seconds(String value) {
    return '$value s';
  }

  @override
  String volumeLabel(int value) {
    return 'Volume $value%';
  }

  @override
  String brightnessLabel(int value) {
    return 'Brilho $value%';
  }

  @override
  String get miniPlayerExpand => 'Abrir player';

  @override
  String get foldersEmpty => 'Nenhuma pasta adicionada ainda.';

  @override
  String videoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vídeos',
      one: '1 vídeo',
      zero: 'Nenhum vídeo',
    );
    return '$_temp0';
  }

  @override
  String get removeFolder => 'Remover pasta';

  @override
  String get removeFolderConfirm =>
      'Os vídeos desta pasta sairão da biblioteca, junto com o histórico e as playlists. Os arquivos no disco não serão apagados.';

  @override
  String lastScan(String date) {
    return 'Último scan: $date';
  }

  @override
  String get neverScanned => 'Ainda não escaneada';

  @override
  String get folderUnavailable => 'Pasta indisponível';

  @override
  String get newPlaylist => 'Nova playlist';

  @override
  String get playlistName => 'Nome da playlist';

  @override
  String get playlistsEmpty =>
      'Nenhuma playlist ainda. Crie uma para organizar seus vídeos.';

  @override
  String get playAll => 'Tocar tudo';

  @override
  String get shuffle => 'Aleatório';

  @override
  String get playlistEmpty =>
      'Esta playlist está vazia. Use \"Salvar na playlist\" no menu de um vídeo.';

  @override
  String get removeFromPlaylist => 'Remover da playlist';

  @override
  String deletePlaylistConfirm(String name) {
    return 'Excluir a playlist \"$name\"? Os vídeos não serão apagados.';
  }

  @override
  String savedToPlaylist(String name) {
    return 'Salvo em \"$name\"';
  }

  @override
  String removedFromPlaylist(String name) {
    return 'Removido de \"$name\"';
  }

  @override
  String get historyTab => 'Histórico';

  @override
  String get favoritesTab => 'Favoritos';

  @override
  String get watchLaterTab => 'Assistir mais tarde';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get clearHistoryConfirm =>
      'Limpar todo o histórico de reprodução? Favoritos e playlists não serão afetados.';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get older => 'Mais antigos';

  @override
  String get historyEmpty => 'Os vídeos que você assistir aparecerão aqui.';

  @override
  String get favoritesEmpty => 'Nenhum favorito ainda.';

  @override
  String get watchLaterEmpty => 'Nada salvo para assistir mais tarde.';

  @override
  String get searchHint => 'Buscar vídeos e pastas';

  @override
  String get recentSearches => 'Buscas recentes';

  @override
  String searchNoResults(String term) {
    return 'Nenhum resultado para \"$term\"';
  }

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get settingsLibrary => 'Biblioteca';

  @override
  String get settingsFolders => 'Pastas monitoradas';

  @override
  String get settingsExtensions => 'Extensões indexadas';

  @override
  String get settingsMinSize => 'Ignorar arquivos menores que';

  @override
  String megabytes(int value) {
    return '$value MB';
  }

  @override
  String get settingsPlayback => 'Reprodução';

  @override
  String get settingsAutoplay => 'Reproduzir o próximo automaticamente';

  @override
  String get settingsDefaultSpeed => 'Velocidade padrão';

  @override
  String get settingsSubLang => 'Idioma preferido de legenda';

  @override
  String get settingsAudioLang => 'Idioma preferido de áudio';

  @override
  String get settingsLangHint => 'Códigos separados por vírgula (ex.: por,eng)';

  @override
  String get settingsHwAccel => 'Aceleração por hardware';

  @override
  String get settingsHwAccelHint => 'Aplicada na próxima abertura do LocalTube';

  @override
  String get settingsMaintenance => 'Manutenção';

  @override
  String get settingsClearThumbs => 'Limpar cache de miniaturas';

  @override
  String get thumbsCleared => 'As miniaturas serão geradas novamente.';

  @override
  String get rescanStarted => 'Reescaneando a biblioteca…';

  @override
  String get settingsAbout => 'Sobre o LocalTube';

  @override
  String get aboutDescription =>
      'Player de vídeos 100% local e offline. Nenhum dado sai do seu dispositivo.';

  @override
  String get settingsAssociate => 'Associar extensões de vídeo (\"Abrir com\")';

  @override
  String get settingsAssociateHint =>
      'Adiciona o LocalTube ao menu \"Abrir com\" do Windows';

  @override
  String get associateDone =>
      'LocalTube adicionado ao \"Abrir com\" para os formatos de vídeo.';

  @override
  String get associateFailed => 'Não foi possível registrar as extensões.';

  @override
  String get noVideosInFolder => 'Nenhum vídeo nesta pasta.';
}
