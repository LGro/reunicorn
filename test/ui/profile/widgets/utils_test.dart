import 'package:reunicorn/ui/profile/widgets/utils.dart';
import 'package:test/test.dart';

void main() {
  test('test circles with status', () {
    final res = circlesWithStatus(
      circles: {'c1': 'Circle1'},
      circleMemberships: {
        'contact1': ['c1'],
        'contact2': ['c1'],
      },
      detailSharingSettingsForLabel: ['c1'],
    );
    expect(res.length, 1);
    expect(res.first, ('c1', 'Circle1', true, 2));
  });
}
