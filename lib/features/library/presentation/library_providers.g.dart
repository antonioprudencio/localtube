// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(history)
final historyProvider = HistoryProvider._();

final class HistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VideoItem>>,
          List<VideoItem>,
          Stream<List<VideoItem>>
        >
    with $FutureModifier<List<VideoItem>>, $StreamProvider<List<VideoItem>> {
  HistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyHash();

  @$internal
  @override
  $StreamProviderElement<List<VideoItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VideoItem>> create(Ref ref) {
    return history(ref);
  }
}

String _$historyHash() => r'fdeaaaa9ed72a2be19daad8ec2b26c32d6ec3675';

@ProviderFor(favorites)
final favoritesProvider = FavoritesProvider._();

final class FavoritesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VideoItem>>,
          List<VideoItem>,
          Stream<List<VideoItem>>
        >
    with $FutureModifier<List<VideoItem>>, $StreamProvider<List<VideoItem>> {
  FavoritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesHash();

  @$internal
  @override
  $StreamProviderElement<List<VideoItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VideoItem>> create(Ref ref) {
    return favorites(ref);
  }
}

String _$favoritesHash() => r'3106470f4069118fc50181e0e7e7815e79820241';

@ProviderFor(watchLater)
final watchLaterProvider = WatchLaterProvider._();

final class WatchLaterProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VideoItem>>,
          List<VideoItem>,
          Stream<List<VideoItem>>
        >
    with $FutureModifier<List<VideoItem>>, $StreamProvider<List<VideoItem>> {
  WatchLaterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchLaterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchLaterHash();

  @$internal
  @override
  $StreamProviderElement<List<VideoItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VideoItem>> create(Ref ref) {
    return watchLater(ref);
  }
}

String _$watchLaterHash() => r'74c39bc7d599f72f1a28f430495da46dfb9d1438';
