import 'package:reunicorn/data/models/models.dart';
import 'package:test/test.dart';

void main() {
  test('test contact schema equals', () {
    const s1 = ContactSharingSchema(
      details: ContactDetails(),
      addressLocations: {},
      temporaryLocations: {},
      connectionAttestations: [],
      introductions: [],
    );
    const s2 = ContactSharingSchema(
      details: ContactDetails(phones: {'p1': '1234'}),
      addressLocations: {},
      temporaryLocations: {},
      connectionAttestations: [],
      introductions: [],
    );
    expect(s1, isNot(equals(s2)));
  });
}
