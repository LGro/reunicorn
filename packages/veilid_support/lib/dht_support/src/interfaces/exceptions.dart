class DHTExceptionOutdated implements Exception {
  final String cause;

  const DHTExceptionOutdated({
    this.cause = 'operation failed due to newer dht value',
  });

  @override
  String toString() => 'DHTExceptionOutdated: $cause';
}

class DHTConcurrencyLimit implements Exception {
  final String cause;

  final int limit;

  const DHTConcurrencyLimit({
    required this.limit,
    this.cause = 'failed due to maximum parallel operation limit',
  });

  @override
  String toString() => 'DHTConcurrencyLimit: $cause (limit=$limit)';
}

class DHTExceptionInvalidData implements Exception {
  final String cause;

  const DHTExceptionInvalidData({this.cause = 'data was invalid'});

  @override
  String toString() => 'DHTExceptionInvalidData: $cause';
}

class DHTExceptionCancelled implements Exception {
  final String cause;

  const DHTExceptionCancelled({this.cause = 'operation was cancelled'});

  @override
  String toString() => 'DHTExceptionCancelled: $cause';
}

class DHTExceptionNotAvailable implements Exception {
  final String cause;

  const DHTExceptionNotAvailable({
    this.cause = 'request could not be completed at this time',
  });

  @override
  String toString() => 'DHTExceptionNotAvailable: $cause';
}

class DHTExceptionNoRecord implements Exception {
  final String cause;

  const DHTExceptionNoRecord({this.cause = 'record could not be found'});

  @override
  String toString() => 'DHTExceptionNoRecord: $cause';
}
