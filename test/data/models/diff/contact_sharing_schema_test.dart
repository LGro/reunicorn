import 'package:reunicorn/data/models/diff/base.dart';
import 'package:reunicorn/data/models/diff/contact_details.dart';
import 'package:reunicorn/data/models/diff/contact_sharing_schema.dart';
import 'package:test/test.dart';

void main() {
  test('are all keep', () {
    const minimalKeep = ContactSharingSchemaDiff(
      details: ContactDetailsDiff(
        picture: DiffStatus.keep,
        names: {},
        phones: {},
        emails: {},
        websites: {},
        socialMedias: {},
        events: {},
        organizations: {},
        misc: {},
        tags: {},
      ),
      addressLocations: {},
      temporaryLocations: {},
      introductions: DiffStatus.keep,
    );

    expect(minimalKeep.areAllKeep, equals(true));
  });
  test('full all keep', () {
    const minimalKeep = ContactSharingSchemaDiff(
      details: ContactDetailsDiff(
        picture: DiffStatus.keep,
        names: {'nl': DiffStatus.keep},
        phones: {'pl': DiffStatus.keep},
        emails: {'@l': DiffStatus.keep},
        websites: {'wl': DiffStatus.keep},
        socialMedias: {'sl': DiffStatus.keep},
        events: {'el': DiffStatus.keep},
        organizations: {'ol': DiffStatus.keep},
        misc: {'ml': DiffStatus.keep},
        tags: {'tl': DiffStatus.keep},
      ),
      addressLocations: {'al': DiffStatus.keep},
      temporaryLocations: {'tl': DiffStatus.keep},
      introductions: DiffStatus.keep,
    );

    expect(minimalKeep.areAllKeep, equals(true));
  });
  test('full not all keep', () {
    const minimalKeep = ContactSharingSchemaDiff(
      details: ContactDetailsDiff(
        picture: DiffStatus.keep,
        names: {'nl': DiffStatus.keep},
        phones: {'pl': DiffStatus.keep},
        emails: {'@l': DiffStatus.keep},
        websites: {'wl': DiffStatus.keep},
        socialMedias: {'sl': DiffStatus.keep},
        events: {'el': DiffStatus.keep},
        // Odd one out -> add
        organizations: {'ol': DiffStatus.add},
        misc: {'ml': DiffStatus.keep},
        tags: {'tl': DiffStatus.keep},
      ),
      addressLocations: {'al': DiffStatus.keep},
      temporaryLocations: {'tl': DiffStatus.keep},
      introductions: DiffStatus.keep,
    );

    expect(minimalKeep.areAllKeep, equals(false));
  });

  test('diff lists', () {
    expect(diffLists(['a', 'b'], ['a', 'b']), equals(DiffStatus.keep));
    expect(diffLists([1, 2], [1, 2]), equals(DiffStatus.keep));
    expect(diffLists([1], [2]), equals(DiffStatus.change));
    expect(diffLists([], []), equals(DiffStatus.keep));
  });
}
