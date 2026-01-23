import 'package:flutter/material.dart';
import 'package:reunicorn/data/models/models.dart';
import 'package:reunicorn/ui/profile/widgets/socials.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ProfileSocialsWidget)
Widget buildProfileSocialsWidgetUseCase(BuildContext context) {
  return ProfileSocialsWidget(
    ContactDetails(socialMedias: {'s1': 'Social1', 's2': 'Social2'}),
    ProfileSharingSettings(),
    {'c1': 'Circle1'},
    {'c1': []},
  );
}
