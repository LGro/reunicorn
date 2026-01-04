// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/models/contact_location.dart';
import '../../../data/models/profile_sharing_settings.dart';
import '../../../data/providers/geocoding/maptiler.dart';
import '../../locations/schedule/widget.dart';
import '../../utils.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';

// TODO: Tackle redundancies with other details add or edit widget
class EditOrAddAddressWidget extends StatefulWidget {
  const EditOrAddAddressWidget({
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
    this.existingLabels = const [],
  });

  final bool isEditing;
  final String headlineSuffix;
  final String? labelHelperText;
  final String? valueHintText;
  final String? label;
  final ContactAddressLocation? value;
  final VoidCallback? onDelete;
  final void Function(
    String?,
    String label,
    ContactAddressLocation value,
    List<(String, String, bool)> selectedCircles,
  )
  onAddOrSave;
  final List<(String, String, bool, int)> circles;
  final List<String> existingLabels;
  @override
  State<EditOrAddAddressWidget> createState() => _EditOrAddAddressWidgetState();
}

class _EditOrAddAddressWidgetState extends State<EditOrAddAddressWidget> {
  final _formKey = GlobalKey<FormState>();
  final _labelFieldKey = GlobalKey<FormFieldState>();
  late List<(String, String, bool, int)> _circles;
  late final TextEditingController _newCircleNameController;

  ContactAddressLocation? _value;
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
                _value!,
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
        // TODO: Validate empty field with hint?
        SizedBox(
          height: 350,
          child: MapWidget(
            initialLocation: (_value == null)
                ? null
                : SearchResult(
                    longitude: _value!.longitude,
                    latitude: _value!.latitude,
                    placeName: _value!.address ?? '',
                    id: '',
                  ),
            onSelected: (l) {
              setState(() {
                _value = ContactAddressLocation(
                  longitude: l.longitude,
                  latitude: l.latitude,
                  address: l.placeName,
                );
              });
            },
          ),
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

class ProfileAddressesWidget extends StatelessWidget {
  const ProfileAddressesWidget(
    this.contact,
    this.addressLocations,
    this.profileSharingSettings,
    this.circles,
    this.circleMemberships, {
    super.key,
  });

  final ContactDetails contact;
  final Map<String, ContactAddressLocation> addressLocations;
  final ProfileSharingSettings profileSharingSettings;
  final Map<String, String> circles;
  final Map<String, List<String>> circleMemberships;

  @override
  Widget build(BuildContext context) => DetailsList(
    addressLocations.map(
      (label, address) =>
          MapEntry(label, commasToNewlines(address.address ?? '')),
    ),
    title: Text(
      context.loc.addresses.capitalize(),
      textScaler: const TextScaler.linear(1.4),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    getDetailSharingSettings: (l) => profileSharingSettings.addresses[l],
    circles: circles,
    circleMemberships: circleMemberships,
    deleteCallback: (label) => context
        .read<ProfileCubit>()
        .updateAddressLocations({...addressLocations}..remove(label)),
    editCallback: (label) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (buildContext) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.9,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: EditOrAddAddressWidget(
            isEditing: true,
            circles: circles
                .map(
                  (cId, cLabel) => MapEntry(cId, (
                    cId,
                    cLabel,
                    profileSharingSettings.addresses[label]?.contains(cId) ??
                        false,
                    circleMemberships.values
                        .where((circles) => circles.contains(cId))
                        .length,
                  )),
                )
                .values
                .toList(),
            headlineSuffix: context.loc.address,
            labelHelperText: 'e.g. home or cabin',
            existingLabels: addressLocations.keys.toList()..remove(label),
            label: label,
            value: addressLocations[label],
            onDelete: () async {
              await context.read<ProfileCubit>().updateAddressLocations(
                {...addressLocations}..remove(label),
              );
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
            },
            onAddOrSave: (oldLabel, label, value, circlesWithSelection) async {
              await context.read<ProfileCubit>().updateAddressLocation(
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
          child: EditOrAddAddressWidget(
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
            headlineSuffix: context.loc.address,
            valueHintText: 'Street, City, Country',
            labelHelperText: 'e.g. home or cabin',
            label: (addressLocations.isEmpty) ? 'home' : null,
            existingLabels: addressLocations.keys.toList(),
            onAddOrSave: (oldLabel, label, value, circlesWithSelection) async {
              await context.read<ProfileCubit>().updateAddressLocation(
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
