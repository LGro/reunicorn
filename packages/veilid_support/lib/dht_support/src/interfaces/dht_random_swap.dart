////////////////////////////////////////////////////////////////////////////
// Writer interface
// ignore: one_member_abstracts
abstract class DHTRandomSwap {
  /// Swap items at position 'aPos' and 'bPos' in the DHTArray.
  /// Throws an IndexError if either of the positions swapped exceeds the length
  /// of the container
  Future<void> swap(int aPos, int bPos);
}
