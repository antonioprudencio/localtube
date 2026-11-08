// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Versão "ao vivo" de um vídeo (favorito, assistir mais tarde etc.).

@ProviderFor(videoById)
final videoByIdProvider = VideoByIdFamily._();

/// Versão "ao vivo" de um vídeo (favorito, assistir mais tarde etc.).

final class VideoByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<VideoItem?>,
          VideoItem?,
          Stream<VideoItem?>
        >
    with $FutureModifier<VideoItem?>, $StreamProvider<VideoItem?> {
  /// Versão "ao vivo" de um vídeo (favorito, assistir mais tarde etc.).
  VideoByIdProvider._({
    required VideoByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'videoByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoByIdHash();

  @override
  String toString() {
    return r'videoByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<VideoItem?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<VideoItem?> create(Ref ref) {
    final argument = this.argument as int;
    return videoById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoByIdHash() => r'563ef4fb558fe3de354018c3bdd44da8a85c6a72';

/// Versão "ao vivo" de um vídeo (favorito, assistir mais tarde etc.).

final class VideoByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<VideoItem?>, int> {
  VideoByIdFamily._()
    : super(
        retry: null,
        name: r'videoByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Versão "ao vivo" de um vídeo (favorito, assistir mais tarde etc.).

  VideoByIdProvider call(int id) =>
      VideoByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'videoByIdProvider';
}

/// `true` enquanto a tela Watch está aberta (o mini-player se esconde).

@ProviderFor(WatchScreenVisible)
final watchScreenVisibleProvider = WatchScreenVisibleProvider._();

/// `true` enquanto a tela Watch está aberta (o mini-player se esconde).
final class WatchScreenVisibleProvider
    extends $NotifierProvider<WatchScreenVisible, bool> {
  /// `true` enquanto a tela Watch está aberta (o mini-player se esconde).
  WatchScreenVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchScreenVisibleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchScreenVisibleHash();

  @$internal
  @override
  WatchScreenVisible create() => WatchScreenVisible();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$watchScreenVisibleHash() =>
    r'e2e6f45aad8a81c76d652cc3b948b4d7c6623ab7';

/// `true` enquanto a tela Watch está aberta (o mini-player se esconde).

abstract class _$WatchScreenVisible extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Modo Picture-in-Picture do Android.

@ProviderFor(pipMode)
final pipModeProvider = PipModeProvider._();

/// Modo Picture-in-Picture do Android.

final class PipModeProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Modo Picture-in-Picture do Android.
  PipModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pipModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pipModeHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return pipMode(ref);
  }
}

String _$pipModeHash() => r'9a06863e3e52ae3d99cc037200d1c804838cf222';
