import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:veilid_support/veilid_support.dart';

import '../repository/processor_repository.dart';

class ConnectionStateCubit
    extends StreamWrapperCubit<ProcessorConnectionState> {
  ConnectionStateCubit(VeilidProcessorRepository processorRepository)
      : super(processorRepository.streamProcessorConnectionState(),
            defaultState: processorRepository.processorConnectionState);
}
