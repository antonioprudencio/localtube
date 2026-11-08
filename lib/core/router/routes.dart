/// Caminhos das rotas do app.
abstract final class Routes {
  static const home = '/';
  static const search = '/search';
  static const settings = '/settings';
  static const folders = '/folders';
  static String folder(int id) => '/folders/$id';
  static const playlists = '/playlists';
  static String playlist(int id) => '/playlists/$id';
  static const library = '/library';
  static const watch = '/watch';
}
