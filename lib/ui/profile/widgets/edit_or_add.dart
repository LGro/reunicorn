// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../utils.dart';
import 'utils.dart';

Future<void> onAddDetail({
  required BuildContext context,
  required String headlineSuffix,
  required Map<String, String> circles,
  required Map<String, List<String>> circleMemberships,
  required Future<void> Function(
    String label,
    String value,
    List<(String, String, bool)> selectedCircles,
  )
  onAdd,
  String? defaultLabel,
  String? valueHintText,
  String? labelHelperText,
  List<String> existingLabels = const [],
}) => showModalBottomSheet<void>(
  context: context,
  isDismissible: true,
  isScrollControlled: true,
  builder: (buildContext) => DraggableScrollableSheet(
    expand: false,
    maxChildSize: 0.9,
    initialChildSize: 0.9,
    builder: (_, scrollController) => SingleChildScrollView(
      controller: scrollController,
      child: EditOrAddWidget(
        isEditing: false,
        circles: circles
            .map(
              (cId, cLabel) => MapEntry(cId, (
                cId,
                cLabel,
                false,
                circleMemberships.values
                    .where((circles) => circles.contains(cId))
                    .length,
              )),
            )
            .values
            .toList(),
        headlineSuffix: headlineSuffix,
        valueHintText: valueHintText,
        labelHelperText: labelHelperText,
        label: defaultLabel,
        existingLabels: existingLabels,
        onAddOrSave: (label, number, circlesWithSelection) =>
            onAdd(label, number, circlesWithSelection).then(
              (_) => (buildContext.mounted)
                  ? Navigator.of(buildContext).pop()
                  : {},
            ),
      ),
    ),
  ),
);

Future<void> onEditDetail({
  required BuildContext context,
  required String headlineSuffix,
  required String label,
  required String value,
  required Map<String, String> circles,
  required Map<String, List<String>> circleMemberships,
  required Map<String, List<String>> detailSharingSettings,
  required Future<void> Function(
    String oldLabel,
    String label,
    String value,
    List<(String, String, bool)> circlesWithSelection,
  )
  onSave,
  required Future<void> Function() onDelete,
  String? valueHintText,
  String? labelHelperText,
  bool hideLabel = false,
  List<String> existingLabels = const [],
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (buildContext) => DraggableScrollableSheet(
    expand: false,
    maxChildSize: 0.9,
    initialChildSize: 0.9,
    builder: (_, scrollController) => SingleChildScrollView(
      controller: scrollController,
      child: EditOrAddWidget(
        isEditing: true,
        circles: circlesWithStatus(
          circles: circles,
          circleMemberships: circleMemberships,
          detailSharingSettingsForLabel: detailSharingSettings[label] ?? [],
        ),
        headlineSuffix: headlineSuffix,
        valueHintText: valueHintText,
        labelHelperText: labelHelperText,
        hideLabel: hideLabel,
        existingLabels: [...existingLabels]..remove(label),
        label: label,
        value: value,
        onDelete: () => onDelete().then(
          (_) =>
              (buildContext.mounted) ? Navigator.of(buildContext).pop() : null,
        ),
        onAddOrSave: (newLabel, newValue, circlesWithSelection) =>
            onSave(label, newLabel, newValue, circlesWithSelection).then(
              (_) => (buildContext.mounted)
                  ? Navigator.of(buildContext).pop()
                  : null,
            ),
      ),
    ),
  ),
);

// TODO: Pass other labels to prevent duplicates
class EditOrAddWidget extends StatefulWidget {
  const EditOrAddWidget({
    super.key,
    required this.isEditing,
    required this.headlineSuffix,
    required this.onAddOrSave,
    required this.circles,
    this.value,
    this.label,
    this.onDelete,
    this.valueHintText,
    this.labelHelperText,
    this.hideLabel = false,
    this.existingLabels = const [],
  });

  final bool isEditing;
  final bool hideLabel;
  final String headlineSuffix;
  final String? labelHelperText;
  final String? valueHintText;
  final String? label;
  final String? value;
  final VoidCallback? onDelete;
  final void Function(
    String label,
    String value,
    List<(String, String, bool)> selectedCircles,
  )
  onAddOrSave;
  final List<(String, String, bool, int)> circles;
  final List<String> existingLabels;
  @override
  State<EditOrAddWidget> createState() => _EditOrAddWidgetState();
}

class _EditOrAddWidgetState extends State<EditOrAddWidget> {
  final _formKey = GlobalKey<FormState>();
  final _valueFieldKey = GlobalKey<FormFieldState>();
  final _labelFieldKey = GlobalKey<FormFieldState>();
  late List<(String, String, bool, int)> _circles;
  late final TextEditingController _newCircleNameController;

  String? _value;
  String? _label;

  @override
  void initState() {
    super.initState();
    _circles = [...widget.circles];
    _newCircleNameController = TextEditingController();
    _value = widget.value;
    _label = widget.label;
  }

  @override
  void dispose() {
    _newCircleNameController.dispose();
    super.dispose();
  }

  void _addNewCircle() {
    if (_newCircleNameController.text.trim().isNotEmpty &&
        !_circles.any((e) => e.$2 == _newCircleNameController.text.trim())) {
      setState(() {
        _circles.insert(0, (
          const Uuid().v4(),
          _newCircleNameController.text.trim(),
          true,
          0,
        ));
      });
      _newCircleNameController.clear();
    }
  }

  void _updateCircleMembership(int index, bool isSelected) {
    setState(() {
      _circles[index] = (
        _circles[index].$1,
        _circles[index].$2,
        isSelected,
        _circles[index].$4,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: buildEditOrAddWidgetSkeleton(
      context,
      title: (widget.isEditing)
          ? context.loc.profileEditHeadline(widget.headlineSuffix)
          : context.loc.profileAddHeadline(widget.headlineSuffix),
      onSaveWidget: IconButton.filled(
        onPressed: () => (_formKey.currentState!.validate())
            ? widget.onAddOrSave(
                (_label ?? '').trim(),
                (_value ?? '').trim(),
                _circles.map((e) => (e.$1, e.$2, e.$3)).toList(),
              )
            : null,
        icon: const Icon(Icons.check),
      ),
      children: [
        if (!widget.hideLabel) ...[
          const SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: 0.5,
            child: TextFormField(
              key: _labelFieldKey,
              initialValue: _label,
              decoration: InputDecoration(
                labelText: 'label',
                isDense: true,
                helperText: widget.labelHelperText,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please specify a label.';
                }
                if (widget.existingLabels
                    .map((l) => l.toLowerCase())
                    .contains(value?.toLowerCase())) {
                  return 'This label already exists.';
                }
                return null;
              },
              onChanged: (label) {
                if (_labelFieldKey.currentState?.validate() ?? false) {
                  setState(() {
                    _label = label;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          key: _valueFieldKey,
          initialValue: _value,
          autocorrect: false,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.valueHintText ?? widget.headlineSuffix,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if ((_label?.isNotEmpty ?? false) && (value?.isEmpty ?? true)) {
              return 'Please enter a value.';
            }
            return null;
          },
          onChanged: (value) {
            if (_valueFieldKey.currentState?.validate() ?? false) {
              setState(() {
                _value = value;
              });
            }
          },
        ),

        const SizedBox(height: 16),
        Text(
          context.loc.profileAndShareWithHeadline,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        // If we don't need wrapping but go for a list, use CheckboxListTile
        Wrap(
          spacing: 8,
          runSpacing: -4,
          children: List.generate(
            _circles.length,
            (index) => GestureDetector(
              onTap: () => _updateCircleMembership(index, !_circles[index].$3),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _circles[index].$3,
                    onChanged: (value) => (value == null)
                        ? null
                        : _updateCircleMembership(index, value),
                  ),
                  Text('${_circles[index].$2} (${_circles[index].$4})'),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
        // const SizedBox(height: 8),
        // Row(children: [
        //   Expanded(
        //       child: TextField(
        //     controller: _newCircleNameController,
        //     decoration: InputDecoration(
        //       isDense: true,
        //       labelText: context.loc.newCircle,
        //       border: const OutlineInputBorder(),
        //     ),
        //   )),
        //   const SizedBox(width: 8),
        //   FilledButton.tonal(
        //     onPressed: _addNewCircle,
        //     child: Text(context.loc.add.capitalize()),
        //   ),
        // ]),
        const SizedBox(height: 16),
        if (widget.onDelete != null)
          Center(
            child: TextButton(
              onPressed: widget.onDelete,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.error,
                ),
              ),
              child: Text(
                'Remove ${widget.headlineSuffix}',
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
            ),
          ),
      ],
    ),
  );
}
