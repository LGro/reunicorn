import '../../../veilid_support.dart';

/// Cubit that watches the default subkey value of a dhtrecord
class DefaultDHTRecordCubit<T> extends DHTRecordCubit<T> {
  MigrationCodec<T> migrationCodec;

  DefaultDHTRecordCubit({required super.open, required this.migrationCodec})
    : super(
        initialStateFunction: _makeInitialStateFunction(migrationCodec),
        stateFunction: _makeStateFunction(migrationCodec),
        watchFunction: _makeWatchFunction(),
      );

  static InitialStateFunction<T> _makeInitialStateFunction<T>(
    MigrationCodec<T> migrationCodec,
  ) =>
      (record) => record.getMigrated(migrationCodec);

  static StateFunction<T> _makeStateFunction<T>(
    MigrationCodec<T> migrationCodec,
  ) => (record, change) async {
    final defaultSubkey = record.subkeyOrDefault(-1);

    // Did the default subkey this cubit cares about change remotely
    if (change.remoteSubkeys.containsSubkey(defaultSubkey)) {
      final firstSubkey = change.remoteSubkeys.firstOrNull!.low;
      final remoteData = change.remoteData;
      if (firstSubkey != defaultSubkey || remoteData == null) {
        // We did not get a new value for the default subkey, so we need to
        // pull the default subkey from the record, migrate and return it
        // This was a remote change, so we use the network refresh mode
        return await record.getMigrated(
          migrationCodec,
          refreshMode: DHTRecordRefreshMode.network,
        );
      } else {
        return migrationCodec.fromBytes(remoteData).value;
      }
    }

    // Did the default subkey this cubit cares about change locally
    if (change.localSubkeys.containsSubkey(defaultSubkey)) {
      // Get the default subkey locally, does not access the network for
      // local changes
      return await record.getMigrated(
        migrationCodec,
        refreshMode: DHTRecordRefreshMode.local,
      );
    }

    return null;
  };

  static WatchFunction _makeWatchFunction() => (record) async {
    final defaultSubkey = record.subkeyOrDefault(-1);
    await record.watch(subkeys: [ValueSubkeyRange.single(defaultSubkey)]);
  };
}
