// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeFilterState)
final homeFilterStateProvider = HomeFilterStateProvider._();

final class HomeFilterStateProvider
    extends $NotifierProvider<HomeFilterState, HomeFilter> {
  HomeFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeFilterStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeFilterStateHash();

  @$internal
  @override
  HomeFilterState create() => HomeFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeFilter>(value),
    );
  }
}

String _$homeFilterStateHash() => r'e65dfe723a1429404ae638dbe67bac027bbb833e';

abstract class _$HomeFilterState extends $Notifier<HomeFilter> {
  HomeFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeFilter, HomeFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeFilter, HomeFilter>,
              HomeFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(allVideos)
final allVideosProvider = AllVideosProvider._();

final class AllVideosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VideoItem>>,
          List<VideoItem>,
          Stream<List<VideoItem>>
        >
    with $FutureModifier<List<VideoItem>>, $StreamProvider<List<VideoItem>> {
  AllVideosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allVideosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allVideosHash();

  @$internal
  @override
  $StreamProviderElement<List<VideoItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VideoItem>> create(Ref ref) {
    return allVideos(ref);
  }
}

String _$allVideosHash() => r'af50a670e56bce617954d3cbbf732cdeb3bc4574';

@ProviderFor(folders)
final foldersProvider = FoldersProvider._();

final class FoldersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FolderRow>>,
          List<FolderRow>,
          Stream<List<FolderRow>>
        >
    with $FutureModifier<List<FolderRow>>, $StreamProvider<List<FolderRow>> {
  FoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foldersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foldersHash();

  @$internal
  @override
  $StreamProviderElement<List<FolderRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FolderRow>> create(Ref ref) {
    return folders(ref);
  }
}

String _$foldersHash() => r'0c0dc1810c64e997cb445b21f7b358b49f2e751e';

@ProviderFor(containers)
final containersProvider = ContainersProvider._();

final class ContainersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  ContainersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containersHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return containers(ref);
  }
}

String _$containersHash() => r'1335f850f9800262216f36161d044e0e3d763c1d';

@ProviderFor(continueWatching)
final continueWatchingProvider = ContinueWatchingProvider._();

final class ContinueWatchingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VideoItem>>,
          List<VideoItem>,
          Stream<List<VideoItem>>
        >
    with $FutureModifier<List<VideoItem>>, $StreamProvider<List<VideoItem>> {
  ContinueWatchingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'continueWatchingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$continueWatchingHash();

  @$internal
  @override
  $StreamProviderElement<List<VideoItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VideoItem>> create(Ref ref) {
    return continueWatching(ref);
  }
}

String _$continueWatchingHash() => r'9a2ffead83b6754df48a52aaf8019b8dcb12f3f1';

/// Vídeos da grade da tela Início, já filtrados.

@ProviderFor(homeVideos)
final homeVideosProvider = HomeVideosProvider._();

/// Vídeos da grade da tela Início, já filtrados.

final class HomeVideosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VideoItem>>,
          AsyncValue<List<VideoItem>>,
          AsyncValue<List<VideoItem>>
        >
    with $Provider<AsyncValue<List<VideoItem>>> {
  /// Vídeos da grade da tela Início, já filtrados.
  HomeVideosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeVideosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeVideosHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<VideoItem>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<VideoItem>> create(Ref ref) {
    return homeVideos(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<VideoItem>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<VideoItem>>>(value),
    );
  }
}

String _$homeVideosHash() => r'5afbf46ae1176ba31aee35dd693698255c677a77';
