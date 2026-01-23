import 'package:flutter/material.dart';
import 'package:reunicorn/ui/map/page.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class _TimeSelectionSlider extends StatefulWidget {
  @override
  State<_TimeSelectionSlider> createState() => _TimeSelectionSliderState();
}

class _TimeSelectionSliderState extends State<_TimeSelectionSlider> {
  DateTime? selection;

  @override
  Widget build(BuildContext context) => TimeSelectionSlider(
    selection: selection,
    labels: [
      DateTime(2020, 1),
      DateTime(2020, 3),
      DateTime(2020, 5),
      DateTime(2021, 5),
    ],
    callback: (v) {
      setState(() {
        selection = v;
      });
    },
  );
}

@widgetbook.UseCase(name: 'Default', type: TimeSelectionSlider)
Widget buildTimeSelectionSliderUseCase(BuildContext context) =>
    _TimeSelectionSlider();
