import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/models/video_item.dart';
import '../data/playlist_repository.dart';

part 'playlists_providers.g.dart';

@riverpod
Stream<List<PlaylistSummary>> playlistSummaries(Ref ref) =>
    ref.watch(playlistRepositoryProvider).watchPlaylists();

@riverpod
Stream<PlaylistRow?> playlistById(Ref ref, int id) =>
    ref.watch(playlistRepositoryProvider).watchPlaylist(id);

@riverpod
Stream<List<VideoItem>> playlistItems(Ref ref, int playlistId) =>
    ref.watch(playlistRepositoryProvider).watchItems(playlistId);
