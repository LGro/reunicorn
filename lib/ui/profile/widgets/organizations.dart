// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../data/models/models.dart';
import '../../utils.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';

// TODO: Tackle redundancies with other details add or edit widget
class _EditOrAddWidget extends StatefulWidget {
  const _EditOrAddWidget({
    required this.isEditing,
    required this.headlineSuffix,
    required this.onAddOrSave,
    required this.circles,
    this.id,
    this.company,
    this.department,
    this.title,
    this.onDelete,
    this.valueHintText,
    this.existingLabels = const [],
  });

  final bool isEditing;
  final String headlineSuffix;
  final String? valueHintText;
  final String? id;
  final String? company;
  final String? title;
  final String? department;
  final VoidCallback? onDelete;
  final void Function(
    String? existingId,
    Organization value,
    List<(String, String, bool)> selectedCircles,
  )
  onAddOrSave;
  final List<(String, String, bool, int)> circles;
  final List<String> existingLabels;
  @override
  State<_EditOrAddWidget> createState() => __EditOrAddWidgetState();
}

class __EditOrAddWidgetState extends State<_EditOrAddWidget> {
  final _formKey = GlobalKey<FormState>();
  final _companyFieldKey = GlobalKey<FormFieldState<String>>();
  final _titleFieldKey = GlobalKey<FormFieldState<String>>();
  final _departmentFieldKey = GlobalKey<FormFieldState<String>>();
  late List<(String, String, bool, int)> _circles;
  late final TextEditingController _newCircleNameController;

  String? _company;
  String? _title;
  String? _department;

  @override
  void initState() {
    super.initState();
    _circles = [...widget.circles];
    _newCircleNameController = TextEditingController();
    _company = widget.company;
    _title = widget.title;
    _department = widget.department;
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
        onPressed: () => (_formKey.currentState!.validate() && _company != null)
            ? widget.onAddOrSave(
                widget.id,
                Organization(
                  company: _company?.trim() ?? '',
                  title: _title?.trim() ?? '',
                  department: _department?.trim() ?? '',
                ),
                _circles.map((e) => (e.$1, e.$2, e.$3)).toList(),
              )
            : null,
        icon: const Icon(Icons.check),
      ),
      children: [
        // Company
        TextFormField(
          key: _companyFieldKey,
          initialValue: _company,
          autocorrect: false,
          decoration: InputDecoration(
            isDense: true,
            hintText: context.loc.organization,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a company name.';
            }
            return null;
          },
          onChanged: (value) {
            if (_companyFieldKey.currentState?.validate() ?? false) {
              setState(() {
                _company = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        // Title
        TextFormField(
          key: _titleFieldKey,
          initialValue: _title,
          autocorrect: false,
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'title',
            border: OutlineInputBorder(),
          ),
          validator: (value) => null,
          onChanged: (value) {
            if (_titleFieldKey.currentState?.validate() ?? false) {
              setState(() {
                _title = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        // Department
        TextFormField(
          key: _departmentFieldKey,
          initialValue: _department,
          autocorrect: false,
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'department',
            border: OutlineInputBorder(),
          ),
          validator: (value) => null,
          onChanged: (value) {
            if (_departmentFieldKey.currentState?.validate() ?? false) {
              setState(() {
                _department = value;
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

class ProfileOrganizationsWidget extends StatelessWidget {
  const ProfileOrganizationsWidget(
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
    contact.organizations.map(
      (key, value) => MapEntry(
        key,
        [
          value.company,
          value.title,
          value.department,
        ].where((v) => v.isNotEmpty).join('\n'),
      ),
    ),
    title: Text(
      context.loc.organizations.capitalize(),
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    getDetailSharingSettings: (l) => profileSharingSettings.organizations[l],
    circles: circles,
    circleMemberships: circleMemberships,
    hideLabel: true,
    deleteCallback: (id) => context.read<ProfileCubit>().updateDetails(
      contact.copyWith(organizations: {...contact.organizations}..remove(id)),
    ),
    editCallback: (id) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (buildContext) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.9,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: _EditOrAddWidget(
            isEditing: true,
            circles: circles
                .map(
                  (cId, cLabel) => MapEntry(cId, (
                    cId,
                    cLabel,
                    profileSharingSettings.organizations[id]?.contains(cId) ??
                        false,
                    circleMemberships.values
                        .where((circles) => circles.contains(cId))
                        .length,
                  )),
                )
                .values
                .toList(),
            headlineSuffix: context.loc.organization,
            id: id,
            company: contact.organizations[id]?.company ?? '',
            title: contact.organizations[id]?.title ?? '',
            department: contact.organizations[id]?.department ?? '',
            onDelete: () async {
              await context.read<ProfileCubit>().updateDetails(
                contact.copyWith(
                  organizations: {...contact.organizations}..remove(id),
                ),
              );
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
            },
            onAddOrSave: (existingId, value, circlesWithSelection) async {
              await context.read<ProfileCubit>().updateOrganization(
                existingId,
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
          child: _EditOrAddWidget(
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
            headlineSuffix: context.loc.organization,
            valueHintText: null,
            existingLabels: contact.events.keys.toList(),
            onAddOrSave: (id, value, circlesWithSelection) async {
              await context.read<ProfileCubit>().updateOrganization(
                id,
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
