import 'package:flutter/material.dart';
import 'package:reunicorn/ui/widgets/introductions_summary.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: IntroductionsSummary)
Widget buildIntroductionsSummaryUseCase(BuildContext context) {
  return IntroductionsSummary([
    ('Peter', false),
    ('Anne', true),
    ('Kim', false),
  ]);
}
