// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_indexer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fábrica de extratores. Nos testes é sobrescrita por um fake.

@ProviderFor(proberFactory)
final proberFactoryProvider = ProberFactoryProvider._();

/// Fábrica de extratores. Nos testes é sobrescrita por um fake.

final class ProberFactoryProvider
    extends
        $FunctionalProvider<
          Future<VideoProber> Function(),
          Future<VideoProber> Function(),
          Future<VideoProber> Function()
        >
    with $Provider<Future<VideoProber> Function()> {
  /// Fábrica de extratores. Nos testes é sobrescrita por um fake.
  ProberFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proberFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proberFactoryHash();

  @$internal
  @override
  $ProviderElement<Future<VideoProber> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<VideoProber> Function() create(Ref ref) {
    return proberFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<VideoProber> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<VideoProber> Function()>(
        value,
      ),
    );
  }
}

String _$proberFactoryHash() => r'4c7104969a3e70827ee8490f814f7f8a40fac7b4';

/// Coordena scan das pastas, sincronização com o banco e fila de metadados.

@ProviderFor(LibraryIndexer)
final libraryIndexerProvider = LibraryIndexerProvider._();

/// Coordena scan das pastas, sincronização com o banco e fila de metadados.
final class LibraryIndexerProvider
    extends $NotifierProvider<LibraryIndexer, IndexerState> {
  /// Coordena scan das pastas, sincronização com o banco e fila de metadados.
  LibraryIndexerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryIndexerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryIndexerHash();

  @$internal
  @override
  LibraryIndexer create() => LibraryIndexer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IndexerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IndexerState>(value),
    );
  }
}

String _$libraryIndexerHash() => r'2883019edda29da690f1717165686e2880e61c31';

/// Coordena scan das pastas, sincronização com o banco e fila de metadados.

abstract class _$LibraryIndexer extends $Notifier<IndexerState> {
  IndexerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<IndexerState, IndexerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IndexerState, IndexerState>,
              IndexerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
