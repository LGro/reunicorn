// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/circle.dart';
import '../../../data/models/contact_location.dart';
import '../../../data/models/profile_info.dart';
import '../../../data/providers/geocoding/maptiler.dart';
import '../../../data/services/storage/base.dart';
import '../../../data/utils.dart';

/// Bottom sheet for sharing a selected location
class ShareLocationBottomSheet extends StatefulWidget {
  const ShareLocationBottomSheet({
    required this.location,
    this.isGpsLocation = false,
    this.onClose,
    super.key,
  });

  final SearchResult location;
  final bool isGpsLocation;
  final VoidCallback? onClose;

  @override
  State<ShareLocationBottomSheet> createState() =>
      _ShareLocationBottomSheetState();
}

class _ShareLocationBottomSheetState extends State<ShareLocationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  List<(String, String, bool, int)> _circles = [];
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _loadCircles();

    // If GPS location, set start time to now
    if (widget.isGpsLocation) {
      final now = DateTime.now();
      _startDate = now;
      _endDate = now.add(const Duration(hours: 1));
    }
  }

  Future<void> _loadCircles() async {
    final circleStorage = context.read<Storage<Circle>>();
    final circles = await circleStorage.getAll();

    if (!mounted) return;
    setState(() {
      _circles = circles.values
          .map((c) => (c.id, c.name, false, c.memberIds.length))
          .toList();
    });
  }

  bool get _isValid =>
      _titleController.text.isNotEmpty &&
      _startDate != null &&
      _endDate != null &&
      _circles.any((c) => c.$3);

  void _updateCircleSelection(int index, bool selected) {
    final circles = List<(String, String, bool, int)>.from(_circles);
    circles[index] = (
      circles[index].$1,
      circles[index].$2,
      selected,
      circles[index].$4,
    );
    setState(() => _circles = circles);
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now().add(const Duration(days: 1)),
      ),
    );

    if (range != null && mounted) {
      setState(() {
        _startDate = DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
          _startDate?.hour ?? 0,
          _startDate?.minute ?? 0,
        );
        _endDate = DateTime(
          range.end.year,
          range.end.month,
          range.end.day,
          _endDate?.hour ?? 23,
          _endDate?.minute ?? 59,
        );
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate ?? DateTime.now()),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (time != null && mounted) {
      setState(() {
        final date = _startDate ?? DateTime.now();
        _startDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _endDate ?? DateTime.now().add(const Duration(hours: 1)),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (time != null && mounted) {
      setState(() {
        final date = _endDate ?? DateTime.now();
        _endDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _onShare() async {
    if (!_formKey.currentState!.validate() || !_isValid) return;

    setState(() => _inProgress = true);

    try {
      final profileStorage = context.read<Storage<ProfileInfo>>();
      final profileInfo = await getProfileInfo(profileStorage);
      if (profileInfo == null || !mounted) {
        setState(() => _inProgress = false);
        return;
      }

      final locationId = const Uuid().v4();
      await profileStorage.set(
        profileInfo.id,
        profileInfo.copyWith(
          temporaryLocations: Map.fromEntries([
            ...profileInfo.temporaryLocations.entries.map(
              (l) => MapEntry(l.key, l.value.copyWith(checkedIn: false)),
            ),
            MapEntry(
              locationId,
              ContactTemporaryLocation(
                longitude: widget.location.longitude,
                latitude: widget.location.latitude,
                start: _startDate!,
                end: _endDate!,
                name: _titleController.text,
                details: _descriptionController.text,
                address: widget.location.placeName,
                circles: _circles.where((c) => c.$3).map((c) => c.$1).toList(),
                checkedIn: widget.isGpsLocation,
              ),
            ),
          ]),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Location "${_titleController.text}" successfully shared.',
              ),
            ),
          );
        widget.onClose?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Sharing location failed.')),
          );
        setState(() => _inProgress = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.95,
    minChildSize: 0.95,
    maxChildSize: 0.95,
    builder: (_, scrollController) => Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Share Location',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onClose?.call();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isGpsLocation
                          ? Icons.my_location
                          : Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.location.placeName,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Please enter a title' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Date/Time section
              Text('When', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),

              // Start date/time
              Row(
                children: [
                  const Text('From: '),
                  TextButton(
                    onPressed: _selectDateRange,
                    child: Text(
                      _startDate != null
                          ? DateFormat.yMd().format(_startDate!)
                          : 'Select date',
                    ),
                  ),
                  if (_startDate != null)
                    TextButton(
                      onPressed: _selectStartTime,
                      child: Text(DateFormat.Hm().format(_startDate!)),
                    ),
                ],
              ),

              // End date/time
              Row(
                children: [
                  const Text('Until: '),
                  TextButton(
                    onPressed: _selectDateRange,
                    child: Text(
                      _endDate != null
                          ? DateFormat.yMd().format(_endDate!)
                          : 'Select date',
                    ),
                  ),
                  if (_endDate != null)
                    TextButton(
                      onPressed: _selectEndTime,
                      child: Text(DateFormat.Hm().format(_endDate!)),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Circles section
              Text(
                'Share with circles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_circles.isEmpty)
                const Text('No circles available')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _circles
                      .asMap()
                      .map(
                        (i, c) => MapEntry(
                          i,
                          FilterChip(
                            selected: c.$3,
                            label: Text('${c.$2} (${c.$4})'),
                            onSelected: (v) => _updateCircleSelection(i, v),
                          ),
                        ),
                      )
                      .values
                      .toList(),
                ),
              const SizedBox(height: 24),

              // Share button
              Center(
                child: _inProgress
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton(
                        onPressed: _isValid ? _onShare : null,
                        child: const Text('Share Location'),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
