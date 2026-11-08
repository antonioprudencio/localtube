import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/models/video_item.dart';
import '../../folders/data/folder_repository.dart';
import '../../library/data/video_repository.dart';
import '../domain/home_filter.dart';

part 'home_providers.g.dart';

@riverpod
class HomeFilterState extends _$HomeFilterState {
  @override
  HomeFilter build() => const AllFilter();

  void select(HomeFilter filter) => state = filter;
}

@riverpod
Stream<List<VideoItem>> allVideos(Ref ref) =>
    ref.watch(videoRepositoryProvider).watchAll();

@riverpod
Stream<List<FolderRow>> folders(Ref ref) =>
    ref.watch(folderRepositoryProvider).watchFolders();

@riverpod
Stream<List<String>> containers(Ref ref) =>
    ref.watch(videoRepositoryProvider).watchContainers();

@riverpod
Stream<List<VideoItem>> continueWatching(Ref ref) =>
    ref.watch(videoRepositoryProvider).watchContinueWatching();

/// Vídeos da grade da tela Início, já filtrados.
@riverpod
AsyncValue<List<VideoItem>> homeVideos(Ref ref) {
  final filter = ref.watch(homeFilterStateProvider);
  return ref
      .watch(allVideosProvider)
      .whenData((videos) => applyHomeFilter(videos, filter));
}
