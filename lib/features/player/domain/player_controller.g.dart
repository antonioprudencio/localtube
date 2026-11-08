// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controlador único de reprodução. O mesmo [Player] é usado pela tela
/// Watch e pelo mini-player, então a reprodução continua ao navegar.

@ProviderFor(PlayerController)
final playerControllerProvider = PlayerControllerProvider._();

/// Controlador único de reprodução. O mesmo [Player] é usado pela tela
/// Watch e pelo mini-player, então a reprodução continua ao navegar.
final class PlayerControllerProvider
    extends $NotifierProvider<PlayerController, PlayerSession> {
  /// Controlador único de reprodução. O mesmo [Player] é usado pela tela
  /// Watch e pelo mini-player, então a reprodução continua ao navegar.
  PlayerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerControllerHash();

  @$internal
  @override
  PlayerController create() => PlayerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerSession>(value),
    );
  }
}

String _$playerControllerHash() => r'a4f8073a669d8f27cf867b1a54cdef28534bf266';

/// Controlador único de reprodução. O mesmo [Player] é usado pela tela
/// Watch e pelo mini-player, então a reprodução continua ao navegar.

abstract class _$PlayerController extends $Notifier<PlayerSession> {
  PlayerSession build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlayerSession, PlayerSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerSession, PlayerSession>,
              PlayerSession,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
