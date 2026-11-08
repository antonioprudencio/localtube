// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlists_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playlistSummaries)
final playlistSummariesProvider = PlaylistSummariesProvider._();

final class PlaylistSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlaylistSummary>>,
          List<PlaylistSummary>,
          Stream<List<PlaylistSummary>>
        >
    with
        $FutureModifier<List<PlaylistSummary>>,
        $StreamProvider<List<PlaylistSummary>> {
  PlaylistSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playlistSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playlistSummariesHash();

  @$internal
  @override
  $StreamProviderElement<List<PlaylistSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PlaylistSummary>> create(Ref ref) {
    return playlistSummaries(ref);
  }
}

String _$playlistSummariesHash() => r'683336c572a769da68628fae37e9645acda4cfea';

@ProviderFor(playlistById)
final playlistByIdProvider = PlaylistByIdFamily._();

final class PlaylistByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlaylistRow?>,
          PlaylistRow?,
          Stream<PlaylistRow?>
        >
    with $FutureModifier<PlaylistRow?>, $StreamProvider<PlaylistRow?> {
  PlaylistByIdProvider._({
    required PlaylistByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'playlistByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playlistByIdHash();

  @override
  String toString() {
    return r'playlistByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PlaylistRow?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PlaylistRow?> create(Ref ref) {
    final argument = this.argument as int;
    return playlistById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaylistByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistByIdHash() => r'6e41ce5f3c229894422bc106d698961f6add90dd';

final class PlaylistByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PlaylistRow?>, int> {
  PlaylistByIdFamily._()
    : super(
        retry: null,
        name: r'playlistByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlaylistByIdProvider call(int id) =>
      PlaylistByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'playlistByIdProvider';
}

@ProviderFor(playlistItems)
final playlistItemsProvider = PlaylistItemsFamily._();

final class PlaylistItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VideoItem>>,
          List<VideoItem>,
          Stream<List<VideoItem>>
        >
    with $FutureModifier<List<VideoItem>>, $StreamProvider<List<VideoItem>> {
  PlaylistItemsProvider._({
    required PlaylistItemsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'playlistItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playlistItemsHash();

  @override
  String toString() {
    return r'playlistItemsProvider'
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
    return playlistItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaylistItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistItemsHash() => r'e39cb08425ec51b220990ba6f738a3d045f286ed';

final class PlaylistItemsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<VideoItem>>, int> {
  PlaylistItemsFamily._()
    : super(
        retry: null,
        name: r'playlistItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlaylistItemsProvider call(int playlistId) =>
      PlaylistItemsProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'playlistItemsProvider';
}
