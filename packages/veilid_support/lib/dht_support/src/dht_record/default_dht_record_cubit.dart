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
  ) => (record, subkeys, updatedata) async {
    final defaultSubkey = record.subkeyOrDefault(-1);
    if (subkeys.containsSubkey(defaultSubkey)) {
      final firstSubkey = subkeys.firstOrNull!.low;
      if (firstSubkey != defaultSubkey || updatedata == null) {
        final maybeData = await record.getMigrated(
          migrationCodec,
          refreshMode: DHTRecordRefreshMode.network,
        );
        if (maybeData == null) {
          return null;
        }
        return maybeData;
      } else {
        return migrationCodec.fromBytes(updatedata).value;
      }
    }
    return null;
  };

  static WatchFunction _makeWatchFunction() => (record) async {
    final defaultSubkey = record.subkeyOrDefault(-1);
    await record.watch(subkeys: [ValueSubkeyRange.single(defaultSubkey)]);
  };

  Future<void> refreshDefault() async {
    await initWait();
    final rec = record;
    if (rec != null) {
      final defaultSubkey = rec.subkeyOrDefault(-1);
      await refresh([
        ValueSubkeyRange(low: defaultSubkey, high: defaultSubkey),
      ]);
    }
  }
}
