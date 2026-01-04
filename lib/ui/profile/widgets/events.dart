// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/models/profile_sharing_settings.dart';
import '../../utils.dart';
import '../cubit.dart';
import 'details_list.dart';

// TODO: Tackle redundancies with other details add or edit widget
class _EditOrAddEventWidget extends StatefulWidget {
  const _EditOrAddEventWidget({
    required this.isEditing,
    required this.headlineSuffix,
    required this.onAddOrSave,
    required this.circles,
    this.value,
    this.label,
    this.onDelete,
    this.valueHintText,
    this.labelHelperText,
    this.existingLabels = const [],
    super.key,
  });

  final bool isEditing;
  final String headlineSuffix;
  final String? labelHelperText;
  final String? valueHintText;
  final String? label;
  final String? value;
  final VoidCallback? onDelete;
  final void Function(
    String? oldLabel,
    String label,
    DateTime value,
    List<(String, String, bool)> selectedCircles,
  )
  onAddOrSave;
  final List<(String, String, bool, int)> circles;
  final List<String> existingLabels;
  @override
  State<_EditOrAddEventWidget> createState() => _EditOrAddEventWidgetState();
}

class _EditOrAddEventWidgetState extends State<_EditOrAddEventWidget> {
  final _formKey = GlobalKey<FormState>();
  final _labelFieldKey = GlobalKey<FormFieldState>();
  final _valueFieldKey = GlobalKey<FormFieldState>();
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
        onPressed: () => (_formKey.currentState!.validate() && _value != null)
            ? widget.onAddOrSave(
                widget.label,
                (_label ?? '').trim(),
                DateTime.parse(_value!),
                _circles.map((e) => (e.$1, e.$2, e.$3)).toList(),
              )
            : null,
        icon: const Icon(Icons.check),
      ),
      children: [
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
            } else if (DateTime.tryParse(value!) == null) {
              return 'Please enter a date in the format YYYY-MM-DD';
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

class ProfileEventsWidget extends StatelessWidget {
  const ProfileEventsWidget(
    this.contact,
    this.profileSharingSettings,
    this.circles,
    this.circleMemberships, {
    super.key,
  });

  final ContactDetails contact;
  final ProfileSharingSettings profileSharingSettings;
  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;

  @override
  Widget build(BuildContext context) => DetailsList(
    contact.events.map(
      (label, date) => MapEntry(
        label,
        DateFormat.yMd(
          Localizations.localeOf(context).languageCode,
        ).format(date),
      ),
    ),
    title: Text(
      'Dates',
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    getDetailSharingSettings: (l) => profileSharingSettings.events[l],
    circles: circles,
    circleMemberships: circleMemberships,
    deleteCallback: (label) => context.read<ProfileCubit>().updateDetails(
      contact.copyWith(events: {...contact.events}..remove(label)),
    ),
    editCallback: (label) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (buildContext) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.9,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: _EditOrAddEventWidget(
            isEditing: true,
            circles: circles
                .map(
                  (cId, cLabel) => MapEntry(cId, (
                    cId,
                    cLabel,
                    profileSharingSettings.events[label]?.contains(cId) ??
                        false,
                    circleMemberships.values
                        .where((circles) => circles.contains(cId))
                        .length,
                  )),
                )
                .values
                .toList(),
            headlineSuffix: 'date',
            existingLabels: [...contact.events.keys]..remove(label),
            label: label,
            value: (contact.events.containsKey(label))
                ? DateFormat('yyyy-MM-dd').format(contact.events[label]!)
                : null,
            onDelete: () async {
              await context.read<ProfileCubit>().updateDetails(
                contact.copyWith(events: {...contact.events}..remove(label)),
              );
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
            },
            onAddOrSave: (oldLabel, label, value, circlesWithSelection) async {
              await context.read<ProfileCubit>().updateEvent(
                oldLabel,
                label,
                value,
                circlesWithSelection,
              );
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
            },
          ),
        ),
      ),
    ),
    addCallback: () => showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (buildContext) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.9,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: _EditOrAddEventWidget(
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
            headlineSuffix: 'date',
            valueHintText: 'YYYY-MM-DD',
            label: (contact.events.isEmpty) ? 'birthday' : null,
            existingLabels: contact.events.keys.toList(),
            onAddOrSave: (oldLabel, label, value, circlesWithSelection) async {
              await context.read<ProfileCubit>().updateEvent(
                oldLabel,
                label,
                value,
                circlesWithSelection,
              );
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
            },
          ),
        ),
      ),
    ),
  );
}
