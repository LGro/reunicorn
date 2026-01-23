// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:loggy/loggy.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide Circle;
import 'package:uuid/uuid.dart';

import '../../../data/models/circle.dart';
import '../../../data/models/contact_location.dart';
import '../../../data/models/profile_info.dart';
import '../../../data/providers/geocoding/maptiler.dart';
import '../../../data/repositories/settings.dart';
import '../../../data/services/storage/base.dart';
import '../../../data/utils.dart';
import '../../utils.dart';
import '../../widgets/import_calendar_event.dart';
import '../../widgets/location_search/widget.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.initialLocation, this.onSelected});

  @override
  State<StatefulWidget> createState() => MapWidgetState();

  final SearchResult? initialLocation;
  final void Function(SearchResult)? onSelected;
}

class MapWidgetState extends State<MapWidget> {
  MapLibreMapController? _mapController;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      // TODO: Refactor redundancy with map page
      MapLibreMap(
        styleString: context.read<SettingsRepository>().mapStyleString,
        // TODO: Pick reasonable center without requiring all markers first;
        // e.g. based on profile contact locations or current GPS
        initialCameraPosition: (widget.initialLocation == null)
            ? const CameraPosition(target: LatLng(20, 0), zoom: 1.5)
            : CameraPosition(
                target: LatLng(
                  widget.initialLocation!.latitude,
                  widget.initialLocation!.longitude,
                ),
                zoom: 13,
              ),
        onMapCreated: (controller) => _mapController = controller,
        onStyleLoadedCallback: () async {
          await _mapController?.addImage(
            'custom-marker',
            await iconToUint8List(
              Icons.location_on,
              size: 64,
              color: Colors.deepPurpleAccent,
            ),
          );

          if (widget.initialLocation != null) {
            await _mapController?.removeSymbols(_mapController?.symbols ?? {});
            await _mapController?.addSymbol(
              SymbolOptions(
                geometry: LatLng(
                  widget.initialLocation!.latitude,
                  widget.initialLocation!.longitude,
                ),
                iconImage: 'custom-marker',
                iconSize: 2,
              ),
            );
          }
        },
        attributionButtonMargins: const Point<num>(12, 12),
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        dragEnabled: false,
      ),
      // Search bar
      Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: LocationSearchWidget(
            initialValue: widget.initialLocation?.placeName,
            onSelected: (l) async {
              widget.onSelected?.call(l);

              await _mapController?.moveCamera(
                CameraUpdate.newLatLngZoom(LatLng(l.latitude, l.longitude), 13),
              );

              await _mapController?.removeSymbols(
                _mapController?.symbols ?? {},
              );
              await _mapController?.addSymbol(
                SymbolOptions(
                  geometry: LatLng(l.latitude, l.longitude),
                  iconImage: 'custom-marker',
                  iconSize: 2,
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({this.locationId, this.location, super.key});

  final String? locationId;
  final ContactTemporaryLocation? location;

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  final _key = GlobalKey<FormState>();
  final _titleFieldKey = GlobalKey<FormFieldState<String>>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  var _inProgress = false;
  DateTime? _start;
  DateTime? _end;
  SearchResult? _location;
  List<(String, String, bool, int)> _circles = const [];
  var _toggleMapLocationKey = false;
  var _readyToSubmit = false;

  void updateReadyToSubmit() => setState(() {
    _readyToSubmit =
        _circles.firstWhereOrNull((c) => c.$3) != null &&
        _start != null &&
        _location != null &&
        _titleController.text.isNotEmpty;
  });

  @override
  void initState() {
    super.initState();

    // This schedules the code to run after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_asyncInit());
    });
  }

  Future<void> _asyncInit() async {
    final circleStorage = context.read<Storage<Circle>>();
    final circles = await circleStorage.getAll();

    if (widget.location == null) {
      setState(() {
        _circles = circles.values
            .map(
              (circle) =>
                  (circle.id, circle.name, false, circle.memberIds.length),
            )
            .toList();
      });
    } else {
      setState(() {
        _titleController.text = widget.location!.name;
        _detailsController.text = widget.location!.details;
        _location = SearchResult(
          longitude: widget.location!.longitude,
          latitude: widget.location!.latitude,
          placeName: widget.location!.address ?? '',
          id: '',
        );
        _start = widget.location!.start;
        _end = widget.location!.end;
        _circles = circles.values
            .map(
              (circle) => (
                circle.id,
                circle.name,
                widget.location!.circles.contains(circle.id),
                circle.memberIds.length,
              ),
            )
            .toList();
      });
    }

    updateReadyToSubmit();
  }

  Future<void> _importCalendarEvent(Event e) async {
    // Attempt to geocode the event address location
    SearchResult? location;
    if (e.location != null && e.location!.isNotEmpty) {
      final options = await searchLocation(
        query: e.location!,
        apiKey: maptilerToken(),
        limit: 1,
      );
      if (options.isNotEmpty) {
        location = options.first;
      }
    }
    // TODO: Notify user if location could not be geocoded?
    // TODO: Do we want to avoid overriding existing text input?
    if (e.title != null) {
      _titleController.text = e.title!;
    }
    if (e.description != null) {
      _detailsController.text = e.description!;
    }
    if (!mounted) {
      return;
    }
    if (e.title != null) {
      _titleController.text = e.title!;
    }
    if (e.description != null) {
      _detailsController.text = e.description!;
    }
    setState(() {
      _start = e.start;
      _end = e.end;
      _location = location;
      _toggleMapLocationKey = !_toggleMapLocationKey;
    });
    updateReadyToSubmit();
  }

  void _onStartTimeChanged(TimeOfDay value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _start = DateTime(
        _start!.year,
        _start!.month,
        _start!.day,
        value.hour,
        value.minute,
      );
    });
    updateReadyToSubmit();
  }

  void _onEndTimeChanged(TimeOfDay value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _end = DateTime(
        _end!.year,
        _end!.month,
        _end!.day,
        value.hour,
        value.minute,
      );
    });
    updateReadyToSubmit();
  }

  void _onLocationChanged(SearchResult value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _location = value;
    });
    updateReadyToSubmit();
  }

  void _onDateRangeChanged(DateTimeRange value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _start = DateTime(
        value.start.year,
        value.start.month,
        value.start.day,
        _start?.hour ?? 0,
        _start?.minute ?? 0,
      );
      _end = DateTime(
        value.end.year,
        value.end.month,
        value.end.day,
        _end?.hour ?? 0,
        _end?.minute ?? 0,
      );
    });
    updateReadyToSubmit();
  }

  void _updateCircleSelection(int i, bool selected) {
    if (!mounted) {
      return;
    }
    final circles = List<(String, String, bool, int)>.from(_circles);
    circles[i] = (circles[i].$1, circles[i].$2, selected, circles[i].$4);
    setState(() {
      _circles = circles;
    });
    updateReadyToSubmit();
  }

  Future<void> _onSubmit() async {
    if (!_key.currentState!.validate() || !mounted) {
      return;
    }

    setState(() {
      _inProgress = true;
    });

    try {
      final profileStorage = context.read<Storage<ProfileInfo>>();
      final profileInfo = await getProfileInfo(profileStorage);
      if (profileInfo == null) {
        return;
      }

      await profileStorage.set(
        profileInfo.id,
        profileInfo.copyWith(
          temporaryLocations: Map.fromEntries([
            ...profileInfo.temporaryLocations.entries
                .map((l) => MapEntry(l.key, l.value.copyWith(checkedIn: false)))
                .where((l) => l.key != widget.locationId),
            MapEntry(
              widget.locationId ?? Uuid().v4(),
              ContactTemporaryLocation(
                longitude: _location!.longitude,
                latitude: _location!.latitude,
                start: _start!,
                end: _end!,
                name: _titleController.text,
                details: _detailsController.text,
                address: _location!.placeName,
                circles: _circles.where((c) => c.$3).map((c) => c.$1).toList(),
              ),
            ),
          ]),
        ),
      );
    } on Exception catch (e) {
      logDebug('$e');
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Scheduling failed.')));
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Location "${_titleController.text}" successfully scheduled.',
            ),
          ),
        );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Schedule a visit'),
      actions: [
        // # TODO: Remove check once #58 is solved
        if (Platform.isAndroid)
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<CalendarEventsPage>(
                builder: (c) =>
                    CalendarEventsPage(onSelectEvent: _importCalendarEvent),
              ),
            ),
            icon: const Icon(Icons.calendar_month),
          ),
      ],
    ),
    body: Form(
      key: _key,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          key: _titleFieldKey,
                          controller: _titleController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            helperMaxLines: 2,
                            labelText: 'Title',
                            errorMaxLines: 2,
                          ),
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a value.';
                            }
                            return null;
                          },
                          // Postpone execution until the current build frame is done
                          onChanged: (_) =>
                              Future.microtask(updateReadyToSubmit),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          key: const Key('scheduleForm_detailsInput'),
                          controller: _detailsController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            helperMaxLines: 2,
                            labelText: 'Details',
                            errorMaxLines: 2,
                          ),
                          textInputAction: TextInputAction.done,
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Row(
                          children: [
                            Text(
                              'and share with circles',
                              textScaler: TextScaler.linear(1.2),
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _circles
                            .asMap()
                            .map(
                              (i, c) => MapEntry(
                                i,
                                GestureDetector(
                                  onTap: () => _updateCircleSelection(i, !c.$3),
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: c.$3,
                                        onChanged: (value) => (value == null)
                                            ? null
                                            : _updateCircleSelection(i, value),
                                      ),
                                      Text('${c.$2} (${c.$4})'),
                                      const SizedBox(width: 4),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .values
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            child: Text(
                              (_start == null)
                                  ? 'Pick Start Date'
                                  : DateFormat.yMd().format(_start!),
                            ),
                            onPressed: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 356 * 2),
                                ),
                                initialDateRange: DateTimeRange(
                                  start: _start ?? DateTime.now(),
                                  end:
                                      _end ??
                                      _start ??
                                      DateTime.now().add(
                                        const Duration(days: 1),
                                      ),
                                ),
                              );
                              if (range != null) {
                                _onDateRangeChanged(range);
                              }
                            },
                          ),
                          if (_start != null)
                            TextButton(
                              child: Text(DateFormat.Hm().format(_start!)),
                              onPressed: () async =>
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: _start!.hour,
                                      minute: _start!.minute,
                                    ),
                                    builder: (context, child) => MediaQuery(
                                      data: MediaQuery.of(
                                        context,
                                      ).copyWith(alwaysUse24HourFormat: true),
                                      child: child!,
                                    ),
                                  ).then(
                                    (t) => (t == null)
                                        ? null
                                        : _onStartTimeChanged(t),
                                  ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            child: Text(
                              (_end == null)
                                  ? 'Pick End Date'
                                  : DateFormat.yMd().format(_end!),
                            ),
                            onPressed: () async =>
                                showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 356 * 2),
                                  ),
                                  initialDateRange: DateTimeRange(
                                    start: _start ?? DateTime.now(),
                                    end:
                                        _end ??
                                        _start ??
                                        DateTime.now().add(
                                          const Duration(days: 1),
                                        ),
                                  ),
                                ).then(
                                  (range) => (range == null)
                                      ? null
                                      : _onDateRangeChanged,
                                ),
                          ),
                          if (_end != null)
                            TextButton(
                              child: Text(DateFormat.Hm().format(_end!)),
                              onPressed: () async =>
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: _end!.hour,
                                      minute: _end!.minute,
                                    ),
                                    builder: (context, child) => MediaQuery(
                                      data: MediaQuery.of(
                                        context,
                                      ).copyWith(alwaysUse24HourFormat: true),
                                      child: child!,
                                    ),
                                  ).then(
                                    (t) => (t == null)
                                        ? null
                                        : _onEndTimeChanged(t),
                                  ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 380,
                        child: MapWidget(
                          // Force re-drawing the widget if the
                          // location changes; is there a better way?
                          key: Key(
                            _toggleMapLocationKey
                                ? 'map-location-key-toggled'
                                : 'map-location-key',
                          ),
                          initialLocation: _location,
                          onSelected: _onLocationChanged,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsetsGeometry.only(bottom: 8),
              child: _inProgress
                  ? const CircularProgressIndicator()
                  : FilledButton(
                      key: const Key('scheduleForm_submit'),
                      onPressed: _readyToSubmit ? _onSubmit : null,
                      child: const Text('Share'),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}
