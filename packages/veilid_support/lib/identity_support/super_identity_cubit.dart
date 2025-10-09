import 'package:async_tools/async_tools.dart';

import '../veilid_support.dart';
import 'super_identity_migration_codec.dart';

typedef SuperIdentityState = AsyncValue<SuperIdentity>;

class SuperIdentityCubit extends DefaultDHTRecordCubit<SuperIdentity> {
  SuperIdentityCubit({required RecordKey superRecordKey})
    : super(
        open: () => _open(superRecordKey: superRecordKey),
        migrationCodec: SuperIdentityMigrationCodec(),
      );

  static Future<DHTRecord> _open({required RecordKey superRecordKey}) {
    final pool = DHTRecordPool.instance;

    return pool.openRecordRead(
      superRecordKey,
      debugName: 'SuperIdentityCubit::_open::SuperIdentityRecord',
    );
  }
}
