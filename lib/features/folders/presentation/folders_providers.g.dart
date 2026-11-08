// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folders_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(folderSummaries)
final folderSummariesProvider = FolderSummariesProvider._();

final class FolderSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FolderSummary>>,
          List<FolderSummary>,
          Stream<List<FolderSummary>>
        >
    with
        $FutureModifier<List<FolderSummary>>,
        $StreamProvider<List<FolderSummary>> {
  FolderSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderSummariesHash();

  @$internal
  @override
  $StreamProviderElement<List<FolderSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FolderSummary>> create(Ref ref) {
    return folderSummaries(ref);
  }
}

String _$folderSummariesHash() => r'afe3315689faa1639b8c2376874b0e17859c3ad3';

@ProviderFor(folderById)
final folderByIdProvider = FolderByIdFamily._();

final class FolderByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<FolderRow?>,
          FolderRow?,
          Stream<FolderRow?>
        >
    with $FutureModifier<FolderRow?>, $StreamProvider<FolderRow?> {
  FolderByIdProvider._({
    required FolderByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'folderByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderByIdHash();

  @override
  String toString() {
    return r'folderByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<FolderRow?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<FolderRow?> create(Ref ref) {
    final argument = this.argument as int;
    return folderById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderByIdHash() => r'a867faf81437f7a80aeb9c65a6bfcb8e6f34acf9';

final class FolderByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<FolderRow?>, int> {
  FolderByIdFamily._()
    : super(
        retry: null,
        name: r'folderByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FolderByIdProvider call(int id) =>
      FolderByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'folderByIdProvider';
}

@ProviderFor(folderVideos)
final folderVideosProvider = FolderVideosFamily._();

final class FolderVideosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VideoItem>>,
          List<VideoItem>,
          Stream<List<VideoItem>>
        >
    with $FutureModifier<List<VideoItem>>, $StreamProvider<List<VideoItem>> {
  FolderVideosProvider._({
    required FolderVideosFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'folderVideosProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$folderVideosHash();

  @override
  String toString() {
    return r'folderVideosProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<VideoItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VideoItem>> create(Ref ref) {
    final argument = this.argument as int;
    return folderVideos(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderVideosProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderVideosHash() => r'5b3a30f205b9cd0d2815de1d1a1a355e5d86e6d7';

final class FolderVideosFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<VideoItem>>, int> {
  FolderVideosFamily._()
    : super(
        retry: null,
        name: r'folderVideosProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FolderVideosProvider call(int folderId) =>
      FolderVideosProvider._(argument: folderId, from: this);

  @override
  String toString() => r'folderVideosProvider';
}
