import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/video_item.dart';
import '../data/video_repository.dart';

part 'library_providers.g.dart';

@riverpod
Stream<List<VideoItem>> history(Ref ref) =>
    ref.watch(videoRepositoryProvider).watchHistory();

@riverpod
Stream<List<VideoItem>> favorites(Ref ref) =>
    ref.watch(videoRepositoryProvider).watchFavorites();

@riverpod
Stream<List<VideoItem>> watchLater(Ref ref) =>
    ref.watch(videoRepositoryProvider).watchWatchLater();
