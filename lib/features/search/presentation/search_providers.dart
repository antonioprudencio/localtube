import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/video_item.dart';
import '../../library/data/video_repository.dart';
import '../data/search_repository.dart';

part 'search_providers.g.dart';

@riverpod
Stream<List<String>> searchHistory(Ref ref) =>
    ref.watch(searchRepositoryProvider).watchHistory();

@riverpod
Future<List<VideoItem>> searchResults(Ref ref, String term) =>
    ref.watch(videoRepositoryProvider).search(term);
