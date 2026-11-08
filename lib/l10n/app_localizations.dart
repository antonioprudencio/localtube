import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'LocalTube'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navFolders.
  ///
  /// In pt, this message translates to:
  /// **'Pastas'**
  String get navFolders;

  /// No description provided for @navPlaylists.
  ///
  /// In pt, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Biblioteca'**
  String get navLibrary;

  /// No description provided for @actionSearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get actionSearch;

  /// No description provided for @actionAddFolder.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar pasta'**
  String get actionAddFolder;

  /// No description provided for @actionSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get actionSettings;

  /// No description provided for @actionRescan.
  ///
  /// In pt, this message translates to:
  /// **'Reescanear biblioteca'**
  String get actionRescan;

  /// No description provided for @actionMenu.
  ///
  /// In pt, this message translates to:
  /// **'Mais opções'**
  String get actionMenu;

  /// No description provided for @actionBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get actionBack;

  /// No description provided for @actionClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get actionClose;

  /// No description provided for @actionCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get actionRemove;

  /// No description provided for @actionSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get actionSave;

  /// No description provided for @actionCreate.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get actionCreate;

  /// No description provided for @actionRename.
  ///
  /// In pt, this message translates to:
  /// **'Renomear'**
  String get actionRename;

  /// No description provided for @actionDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get actionDelete;

  /// No description provided for @actionOk.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get actionClear;

  /// No description provided for @welcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao LocalTube'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In pt, this message translates to:
  /// **'Adicione uma pasta com vídeos do seu dispositivo. Tudo fica no seu aparelho — nada é enviado para a internet.'**
  String get welcomeBody;

  /// No description provided for @welcomeButton.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar pasta de vídeos'**
  String get welcomeButton;

  /// No description provided for @filterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar assistindo'**
  String get filterContinue;

  /// No description provided for @filterRecent.
  ///
  /// In pt, this message translates to:
  /// **'Recentes'**
  String get filterRecent;

  /// No description provided for @filterUnwatched.
  ///
  /// In pt, this message translates to:
  /// **'Não assistidos'**
  String get filterUnwatched;

  /// No description provided for @emptyFilter.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vídeo encontrado com este filtro.'**
  String get emptyFilter;

  /// No description provided for @sectionContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar assistindo'**
  String get sectionContinue;

  /// No description provided for @menuAddToPlaylist.
  ///
  /// In pt, this message translates to:
  /// **'Salvar na playlist'**
  String get menuAddToPlaylist;

  /// No description provided for @menuFavorite.
  ///
  /// In pt, this message translates to:
  /// **'Favoritar'**
  String get menuFavorite;

  /// No description provided for @menuUnfavorite.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get menuUnfavorite;

  /// No description provided for @menuWatchLater.
  ///
  /// In pt, this message translates to:
  /// **'Assistir mais tarde'**
  String get menuWatchLater;

  /// No description provided for @menuRemoveWatchLater.
  ///
  /// In pt, this message translates to:
  /// **'Remover de Assistir mais tarde'**
  String get menuRemoveWatchLater;

  /// No description provided for @menuMarkWatched.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como assistido'**
  String get menuMarkWatched;

  /// No description provided for @menuMarkUnwatched.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como não assistido'**
  String get menuMarkUnwatched;

  /// No description provided for @menuInfo.
  ///
  /// In pt, this message translates to:
  /// **'Informações do arquivo'**
  String get menuInfo;

  /// No description provided for @menuOpenInExplorer.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar no Explorador de Arquivos'**
  String get menuOpenInExplorer;

  /// No description provided for @menuRemoveFromLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Remover da biblioteca'**
  String get menuRemoveFromLibrary;

  /// No description provided for @menuRemoveFromHistory.
  ///
  /// In pt, this message translates to:
  /// **'Remover do histórico'**
  String get menuRemoveFromHistory;

  /// No description provided for @removeFromLibraryConfirm.
  ///
  /// In pt, this message translates to:
  /// **'O arquivo não será apagado do disco, apenas ocultado do LocalTube.'**
  String get removeFromLibraryConfirm;

  /// No description provided for @infoPath.
  ///
  /// In pt, this message translates to:
  /// **'Caminho'**
  String get infoPath;

  /// No description provided for @infoSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho'**
  String get infoSize;

  /// No description provided for @infoDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get infoDuration;

  /// No description provided for @infoResolution.
  ///
  /// In pt, this message translates to:
  /// **'Resolução'**
  String get infoResolution;

  /// No description provided for @infoVideoCodec.
  ///
  /// In pt, this message translates to:
  /// **'Codec de vídeo'**
  String get infoVideoCodec;

  /// No description provided for @infoAudioCodec.
  ///
  /// In pt, this message translates to:
  /// **'Codec de áudio'**
  String get infoAudioCodec;

  /// No description provided for @infoContainer.
  ///
  /// In pt, this message translates to:
  /// **'Formato'**
  String get infoContainer;

  /// No description provided for @infoBitrate.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de bits'**
  String get infoBitrate;

  /// No description provided for @infoModified.
  ///
  /// In pt, this message translates to:
  /// **'Modificado em'**
  String get infoModified;

  /// No description provided for @infoFolder.
  ///
  /// In pt, this message translates to:
  /// **'Pasta'**
  String get infoFolder;

  /// No description provided for @unknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecido'**
  String get unknown;

  /// No description provided for @unavailable.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get unavailable;

  /// No description provided for @permissionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesso aos vídeos'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In pt, this message translates to:
  /// **'O LocalTube precisa acessar seus vídeos para montar a biblioteca. Os arquivos são lidos apenas no seu dispositivo e nunca saem dele.'**
  String get permissionBody;

  /// No description provided for @permissionContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get permissionContinue;

  /// No description provided for @permissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissão para acessar os vídeos. Permita o acesso nas configurações do sistema.'**
  String get permissionDenied;

  /// No description provided for @openSystemSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir configurações'**
  String get openSystemSettings;

  /// No description provided for @folderAdded.
  ///
  /// In pt, this message translates to:
  /// **'Pasta adicionada: {name}'**
  String folderAdded(String name);

  /// No description provided for @folderAddedCount.
  ///
  /// In pt, this message translates to:
  /// **'Pasta \"{name}\" adicionada: {count, plural, =1{1 vídeo encontrado} other{{count} vídeos encontrados}}'**
  String folderAddedCount(String name, int count);

  /// No description provided for @folderAddedEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vídeo encontrado em \"{name}\". Verifique se a pasta contém vídeos e se o LocalTube tem permissão de acesso.'**
  String folderAddedEmpty(String name);

  /// No description provided for @scanning.
  ///
  /// In pt, this message translates to:
  /// **'Escaneando pastas…'**
  String get scanning;

  /// No description provided for @processing.
  ///
  /// In pt, this message translates to:
  /// **'Gerando miniaturas ({count} restantes)'**
  String processing(int count);

  /// No description provided for @dropHere.
  ///
  /// In pt, this message translates to:
  /// **'Solte arquivos de vídeo ou pastas aqui'**
  String get dropHere;

  /// No description provided for @watchFavorite.
  ///
  /// In pt, this message translates to:
  /// **'Favoritar'**
  String get watchFavorite;

  /// No description provided for @watchFavorited.
  ///
  /// In pt, this message translates to:
  /// **'Favorito'**
  String get watchFavorited;

  /// No description provided for @watchSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get watchSave;

  /// No description provided for @watchRepeat.
  ///
  /// In pt, this message translates to:
  /// **'Repetir'**
  String get watchRepeat;

  /// No description provided for @watchInfo.
  ///
  /// In pt, this message translates to:
  /// **'Info'**
  String get watchInfo;

  /// No description provided for @watchDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes técnicos'**
  String get watchDetails;

  /// No description provided for @upNext.
  ///
  /// In pt, this message translates to:
  /// **'A seguir'**
  String get upNext;

  /// No description provided for @autoplay.
  ///
  /// In pt, this message translates to:
  /// **'Reprodução automática'**
  String get autoplay;

  /// No description provided for @playerError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível reproduzir este arquivo.'**
  String get playerError;

  /// No description provided for @playerErrorDetail.
  ///
  /// In pt, this message translates to:
  /// **'O formato pode não ser suportado ou o arquivo pode estar corrompido.'**
  String get playerErrorDetail;

  /// No description provided for @fileUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo indisponível. Verifique se a unidade está conectada.'**
  String get fileUnavailable;

  /// No description provided for @nothingPlaying.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vídeo em reprodução.'**
  String get nothingPlaying;

  /// No description provided for @play.
  ///
  /// In pt, this message translates to:
  /// **'Reproduzir'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get pause;

  /// No description provided for @next.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In pt, this message translates to:
  /// **'Anterior'**
  String get previous;

  /// No description provided for @mute.
  ///
  /// In pt, this message translates to:
  /// **'Mudo'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In pt, this message translates to:
  /// **'Ativar som'**
  String get unmute;

  /// No description provided for @fullscreen.
  ///
  /// In pt, this message translates to:
  /// **'Tela cheia'**
  String get fullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In pt, this message translates to:
  /// **'Sair da tela cheia'**
  String get exitFullscreen;

  /// No description provided for @playerSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações do player'**
  String get playerSettings;

  /// No description provided for @speed.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade'**
  String get speed;

  /// No description provided for @subtitles.
  ///
  /// In pt, this message translates to:
  /// **'Legendas'**
  String get subtitles;

  /// No description provided for @subtitlesOff.
  ///
  /// In pt, this message translates to:
  /// **'Desativadas'**
  String get subtitlesOff;

  /// No description provided for @subtitlesAuto.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get subtitlesAuto;

  /// No description provided for @loadSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Carregar arquivo de legenda…'**
  String get loadSubtitle;

  /// No description provided for @subtitleDelay.
  ///
  /// In pt, this message translates to:
  /// **'Atraso da legenda'**
  String get subtitleDelay;

  /// No description provided for @audioTrack.
  ///
  /// In pt, this message translates to:
  /// **'Faixa de áudio'**
  String get audioTrack;

  /// No description provided for @aspect.
  ///
  /// In pt, this message translates to:
  /// **'Proporção'**
  String get aspect;

  /// No description provided for @aspectFit.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar'**
  String get aspectFit;

  /// No description provided for @aspectFill.
  ///
  /// In pt, this message translates to:
  /// **'Preencher'**
  String get aspectFill;

  /// No description provided for @repeatOff.
  ///
  /// In pt, this message translates to:
  /// **'Não repetir'**
  String get repeatOff;

  /// No description provided for @repeatOne.
  ///
  /// In pt, this message translates to:
  /// **'Repetir este vídeo'**
  String get repeatOne;

  /// No description provided for @repeatAll.
  ///
  /// In pt, this message translates to:
  /// **'Repetir lista'**
  String get repeatAll;

  /// No description provided for @lockControls.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear controles'**
  String get lockControls;

  /// No description provided for @unlockHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque no cadeado para desbloquear'**
  String get unlockHint;

  /// No description provided for @pictureInPicture.
  ///
  /// In pt, this message translates to:
  /// **'Picture-in-Picture'**
  String get pictureInPicture;

  /// No description provided for @theaterMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo teatro'**
  String get theaterMode;

  /// No description provided for @trackN.
  ///
  /// In pt, this message translates to:
  /// **'Faixa {n}'**
  String trackN(int n);

  /// No description provided for @seconds.
  ///
  /// In pt, this message translates to:
  /// **'{value} s'**
  String seconds(String value);

  /// No description provided for @volumeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Volume {value}%'**
  String volumeLabel(int value);

  /// No description provided for @brightnessLabel.
  ///
  /// In pt, this message translates to:
  /// **'Brilho {value}%'**
  String brightnessLabel(int value);

  /// No description provided for @miniPlayerExpand.
  ///
  /// In pt, this message translates to:
  /// **'Abrir player'**
  String get miniPlayerExpand;

  /// No description provided for @foldersEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma pasta adicionada ainda.'**
  String get foldersEmpty;

  /// No description provided for @videoCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhum vídeo} =1{1 vídeo} other{{count} vídeos}}'**
  String videoCount(int count);

  /// No description provided for @removeFolder.
  ///
  /// In pt, this message translates to:
  /// **'Remover pasta'**
  String get removeFolder;

  /// No description provided for @removeFolderConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Os vídeos desta pasta sairão da biblioteca, junto com o histórico e as playlists. Os arquivos no disco não serão apagados.'**
  String get removeFolderConfirm;

  /// No description provided for @lastScan.
  ///
  /// In pt, this message translates to:
  /// **'Último scan: {date}'**
  String lastScan(String date);

  /// No description provided for @neverScanned.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não escaneada'**
  String get neverScanned;

  /// No description provided for @folderUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Pasta indisponível'**
  String get folderUnavailable;

  /// No description provided for @newPlaylist.
  ///
  /// In pt, this message translates to:
  /// **'Nova playlist'**
  String get newPlaylist;

  /// No description provided for @playlistName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da playlist'**
  String get playlistName;

  /// No description provided for @playlistsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma playlist ainda. Crie uma para organizar seus vídeos.'**
  String get playlistsEmpty;

  /// No description provided for @playAll.
  ///
  /// In pt, this message translates to:
  /// **'Tocar tudo'**
  String get playAll;

  /// No description provided for @shuffle.
  ///
  /// In pt, this message translates to:
  /// **'Aleatório'**
  String get shuffle;

  /// No description provided for @playlistEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Esta playlist está vazia. Use \"Salvar na playlist\" no menu de um vídeo.'**
  String get playlistEmpty;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In pt, this message translates to:
  /// **'Remover da playlist'**
  String get removeFromPlaylist;

  /// No description provided for @deletePlaylistConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Excluir a playlist \"{name}\"? Os vídeos não serão apagados.'**
  String deletePlaylistConfirm(String name);

  /// No description provided for @savedToPlaylist.
  ///
  /// In pt, this message translates to:
  /// **'Salvo em \"{name}\"'**
  String savedToPlaylist(String name);

  /// No description provided for @removedFromPlaylist.
  ///
  /// In pt, this message translates to:
  /// **'Removido de \"{name}\"'**
  String removedFromPlaylist(String name);

  /// No description provided for @historyTab.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get historyTab;

  /// No description provided for @favoritesTab.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favoritesTab;

  /// No description provided for @watchLaterTab.
  ///
  /// In pt, this message translates to:
  /// **'Assistir mais tarde'**
  String get watchLaterTab;

  /// No description provided for @clearHistory.
  ///
  /// In pt, this message translates to:
  /// **'Limpar histórico'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Limpar todo o histórico de reprodução? Favoritos e playlists não serão afetados.'**
  String get clearHistoryConfirm;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @older.
  ///
  /// In pt, this message translates to:
  /// **'Mais antigos'**
  String get older;

  /// No description provided for @historyEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Os vídeos que você assistir aparecerão aqui.'**
  String get historyEmpty;

  /// No description provided for @favoritesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum favorito ainda.'**
  String get favoritesEmpty;

  /// No description provided for @watchLaterEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nada salvo para assistir mais tarde.'**
  String get watchLaterEmpty;

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar vídeos e pastas'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In pt, this message translates to:
  /// **'Buscas recentes'**
  String get recentSearches;

  /// No description provided for @searchNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado para \"{term}\"'**
  String searchNoResults(String term);

  /// No description provided for @settingsAppearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @settingsLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Biblioteca'**
  String get settingsLibrary;

  /// No description provided for @settingsFolders.
  ///
  /// In pt, this message translates to:
  /// **'Pastas monitoradas'**
  String get settingsFolders;

  /// No description provided for @settingsExtensions.
  ///
  /// In pt, this message translates to:
  /// **'Extensões indexadas'**
  String get settingsExtensions;

  /// No description provided for @settingsMinSize.
  ///
  /// In pt, this message translates to:
  /// **'Ignorar arquivos menores que'**
  String get settingsMinSize;

  /// No description provided for @megabytes.
  ///
  /// In pt, this message translates to:
  /// **'{value} MB'**
  String megabytes(int value);

  /// No description provided for @settingsPlayback.
  ///
  /// In pt, this message translates to:
  /// **'Reprodução'**
  String get settingsPlayback;

  /// No description provided for @settingsAutoplay.
  ///
  /// In pt, this message translates to:
  /// **'Reproduzir o próximo automaticamente'**
  String get settingsAutoplay;

  /// No description provided for @settingsDefaultSpeed.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade padrão'**
  String get settingsDefaultSpeed;

  /// No description provided for @settingsSubLang.
  ///
  /// In pt, this message translates to:
  /// **'Idioma preferido de legenda'**
  String get settingsSubLang;

  /// No description provided for @settingsAudioLang.
  ///
  /// In pt, this message translates to:
  /// **'Idioma preferido de áudio'**
  String get settingsAudioLang;

  /// No description provided for @settingsLangHint.
  ///
  /// In pt, this message translates to:
  /// **'Códigos separados por vírgula (ex.: por,eng)'**
  String get settingsLangHint;

  /// No description provided for @settingsHwAccel.
  ///
  /// In pt, this message translates to:
  /// **'Aceleração por hardware'**
  String get settingsHwAccel;

  /// No description provided for @settingsHwAccelHint.
  ///
  /// In pt, this message translates to:
  /// **'Aplicada na próxima abertura do LocalTube'**
  String get settingsHwAccelHint;

  /// No description provided for @settingsMaintenance.
  ///
  /// In pt, this message translates to:
  /// **'Manutenção'**
  String get settingsMaintenance;

  /// No description provided for @settingsClearThumbs.
  ///
  /// In pt, this message translates to:
  /// **'Limpar cache de miniaturas'**
  String get settingsClearThumbs;

  /// No description provided for @thumbsCleared.
  ///
  /// In pt, this message translates to:
  /// **'As miniaturas serão geradas novamente.'**
  String get thumbsCleared;

  /// No description provided for @rescanStarted.
  ///
  /// In pt, this message translates to:
  /// **'Reescaneando a biblioteca…'**
  String get rescanStarted;

  /// No description provided for @settingsAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o LocalTube'**
  String get settingsAbout;

  /// No description provided for @aboutDescription.
  ///
  /// In pt, this message translates to:
  /// **'Player de vídeos 100% local e offline. Nenhum dado sai do seu dispositivo.'**
  String get aboutDescription;

  /// No description provided for @settingsAssociate.
  ///
  /// In pt, this message translates to:
  /// **'Associar extensões de vídeo (\"Abrir com\")'**
  String get settingsAssociate;

  /// No description provided for @settingsAssociateHint.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona o LocalTube ao menu \"Abrir com\" do Windows'**
  String get settingsAssociateHint;

  /// No description provided for @associateDone.
  ///
  /// In pt, this message translates to:
  /// **'LocalTube adicionado ao \"Abrir com\" para os formatos de vídeo.'**
  String get associateDone;

  /// No description provided for @associateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível registrar as extensões.'**
  String get associateFailed;

  /// No description provided for @noVideosInFolder.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vídeo nesta pasta.'**
  String get noVideosInFolder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
