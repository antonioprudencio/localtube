import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/folders/presentation/folder_detail_screen.dart';
import '../../features/folders/presentation/folders_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/player/presentation/watch_screen.dart';
import '../../features/playlists/presentation/playlist_detail_screen.dart';
import '../../features/playlists/presentation/playlists_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    routes: [
      // ShellRoute com estado por aba: mantém a navegação e o mini-player.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.home,
              builder: (_, _) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  builder: (_, _) => const SearchScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (_, _) => const SettingsScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.folders,
              builder: (_, _) => const FoldersScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => FolderDetailScreen(
                    folderId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.playlists,
              builder: (_, _) => const PlaylistsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => PlaylistDetailScreen(
                    playlistId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.library,
              builder: (_, _) => const LibraryScreen(),
            ),
          ]),
        ],
      ),
      // Tela de reprodução cobre o shell (o mini-player assume ao voltar).
      GoRoute(
        path: Routes.watch,
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WatchScreen(),
          transitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (_, animation, _, child) => SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic))
                .animate(animation),
            child: child,
          ),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
