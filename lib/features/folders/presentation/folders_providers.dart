import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/database.dart';
import '../../../core/models/video_item.dart';
import '../../library/data/video_repository.dart';
import '../data/folder_repository.dart';

part 'folders_providers.g.dart';

@riverpod
Stream<List<FolderSummary>> folderSummaries(Ref ref) =>
    ref.watch(folderRepositoryProvider).watchSummaries();

@riverpod
Stream<FolderRow?> folderById(Ref ref, int id) =>
    ref.watch(folderRepositoryProvider).watchFolder(id);

@riverpod
Stream<List<VideoItem>> folderVideos(Ref ref, int folderId) =>
    ref.watch(videoRepositoryProvider).watchAll(folderId: folderId);
