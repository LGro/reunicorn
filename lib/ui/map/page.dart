// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart' hide Circle;
import 'package:reunicorn/tools/tools.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/circle.dart';
import '../../data/models/coag_contact.dart';
import '../../data/models/contact_location.dart';
import '../../data/models/profile_info.dart';
import '../../data/repositories/contact_dht.dart';
import '../../data/repositories/settings.dart';
import '../../data/services/storage/base.dart';
import '../../data/providers/geocoding/maptiler.dart';
import '../contact_details/page.dart';
import '../locations/schedule/widget.dart';
import '../utils.dart';
import 'cubit.dart';
import 'widgets/widgets.dart';

// For offline map support, see:
// https://github.com/maplibre/flutter-maplibre-gl/blob/3e09a3eecf194df94ff5b31c77d415cc73be6310/maplibre_gl_example/lib/offline_regions.dart

LatLng? initialLocation(
  Iterable<ContactAddressLocation> profileAddressLocations,
  Iterable<ContactTemporaryLocation> profileTemporaryLocations,
  Iterable<ContactAddressLocation> contactAddressLocations,
  Iterable<ContactTemporaryLocation> contactTemporaryLocations,
) {
  if (profileAddressLocations.isNotEmpty) {
    return LatLng(
      profileAddressLocations.map((l) => l.latitude).average,
      profileAddressLocations.map((l) => l.longitude).average,
    );
  }

  if (profileTemporaryLocations.isNotEmpty) {
    return LatLng(
      profileTemporaryLocations.map((l) => l.latitude).average,
      profileTemporaryLocations.map((l) => l.longitude).average,
    );
  }

  if (contactAddressLocations.isNotEmpty ||
      contactTemporaryLocations.isNotEmpty) {
    return LatLng(
      (contactAddressLocations.map((l) => l.latitude).toList()
            ..addAll(contactTemporaryLocations.map((l) => l.latitude)))
          .average,
      (contactAddressLocations.map((l) => l.longitude).toList()
            ..addAll(contactTemporaryLocations.map((l) => l.longitude)))
          .average,
    );
  }

  return null;
}

String dateFormat(DateTime d, String languageCode) => [
  DateFormat.yMMMd(languageCode).format(d),
  DateFormat.Hm(languageCode).format(d),
].join(' ');

Future<void> showModalAddressLocationDetails(
  BuildContext context, {
  required String contactName,
  required String label,
  required ContactAddressLocation location,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (modalContext) => DraggableScrollableSheet(
    expand: false,
    maxChildSize: 0.90,
    builder: (_, scrollController) => SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          top: 16,
          right: 24,
          bottom: 12 + MediaQuery.of(modalContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$contactName @ $label',
              softWrap: true,
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (location.address != null)
              Row(
                children: [
                  const Icon(Icons.pin_drop),
                  const SizedBox(width: 12),
                  Expanded(child: Text(location.address!, softWrap: true)),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () async => SharePlus.instance.share(
                      ShareParams(text: location.address),
                    ),
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            // TODO: Add information about who this is shared with
            const SizedBox(height: 16),
            if (location.coagContactId != null) ...[
              Center(
                child: FilledButton.tonal(
                  child: const Text('Contact details'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<ContactPage>(
                      builder: (_) =>
                          ContactPage(coagContactId: location.coagContactId!),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  ),
);

Future<void> showModalTemporaryLocationDetails(
  BuildContext context, {
  required String contactName,
  required ContactTemporaryLocation location,
  required String locationId,
  bool showEditAndDelete = false,
  Map<String, String> circles = const {},
  Map<String, List<String>> circleMemberships = const {},
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (modalContext) => DraggableScrollableSheet(
    expand: false,
    maxChildSize: 0.90,
    builder: (_, scrollController) => SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          top: 16,
          right: 24,
          bottom: 12 + MediaQuery.of(modalContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$contactName @ ${location.name}',
              softWrap: true,
              textScaler: const TextScaler.linear(1.4),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (location.address != null)
              Row(
                children: [
                  const Icon(Icons.pin_drop),
                  const SizedBox(width: 12),
                  Expanded(child: Text(location.address!, softWrap: true)),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () async => SharePlus.instance.share(
                      ShareParams(text: location.address),
                    ),
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'From: ${dateFormat(location.start, Localizations.localeOf(context).languageCode)}\n'
                    'Until: ${dateFormat(location.end, Localizations.localeOf(context).languageCode)}',
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (location.details.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 12),
                  Expanded(child: Text(location.details, softWrap: true)),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (location.circles.isNotEmpty && circles.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.bubble_chart_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Shared with {N} contacts via circles: {C}'
                          .replaceFirst(
                            '{N}',
                            circleMemberships.values
                                .where(
                                  (cIds) => cIds.asSet().intersectsWith(
                                    location.circles.asSet(),
                                  ),
                                )
                                .length
                                .toString(),
                          )
                          .replaceFirst(
                            '{C}',
                            location.circles
                                .map((cId) => circles[cId])
                                .whereType<String>()
                                .join(', '),
                          ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            // TODO: only display if not already scheduled this (or conflicting)
            if (location.coagContactId != null) ...[
              Center(
                child: FilledButton.tonal(
                  child: const Text('Contact details'),
                  onPressed: () async => Navigator.push(
                    context,
                    MaterialPageRoute<ContactPage>(
                      builder: (_) =>
                          ContactPage(coagContactId: location.coagContactId!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: FilledButton.tonal(
                  onPressed: () async => Navigator.push(
                    context,
                    MaterialPageRoute<ScheduleWidget>(
                      builder: (_) => ScheduleWidget(
                        locationId: locationId,
                        location: location,
                      ),
                    ),
                  ),
                  child: const Text('Add to my locations'),
                ),
              ),
            ],
            if (showEditAndDelete)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton(
                    onPressed: () async => context
                        .read<MapCubit>()
                        .removeLocation(locationId)
                        .then(
                          (_) => (modalContext.mounted)
                              ? Navigator.of(modalContext).pop()
                              : null,
                        ),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<ScheduleWidget>(
                        builder: (context) => ScheduleWidget(
                          locationId: locationId,
                          location: location,
                        ),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  ),
);

class TimeSelectionSlider extends StatelessWidget {
  const TimeSelectionSlider({
    required this.selection,
    required this.labels,
    required this.callback,
    super.key,
  });

  final DateTime? selection;
  final List<DateTime> labels;
  final void Function(DateTime) callback;

  @override
  Widget build(BuildContext context) => (labels.length < 2)
      ? const SizedBox()
      : Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(4),
            child: Slider(
              value: (selection == null)
                  ? 0
                  : (labels
                                .asMap()
                                .entries
                                .where(
                                  (e) =>
                                      e.value.month == selection!.month &&
                                      e.value.year == selection!.year,
                                )
                                .map((e) => e.key)
                                .firstOrNull ??
                            0)
                        .toDouble(),
              max: (labels.length - 1).toDouble(),
              divisions: labels.length - 1,
              label: DateFormat(
                (labels.first.year == labels.last.year) ? 'MMM' : 'MMM yy',
              ).format(selection ?? labels.first),
              onChanged: (value) => callback(labels[value.round()]),
            ),
          ),
        );
}

Map<String, Object> toGeoJson(List<LatLng> locations) => {
  'type': 'FeatureCollection',
  'features': locations
      .asMap()
      .map(
        (i, l) => MapEntry(i, {
          'type': 'Feature',
          'id': 'marker-$i',
          'geometry': {
            'type': 'Point',
            'coordinates': [l.longitude, l.latitude],
          },
          'properties': {'id': i, 'icon': 'icon-$i'},
        }),
      )
      .values
      .toList(),
};

double calculateClusterThresholdMeters({
  required double zoom,
  required double latitude,
  double clusterPixelRadius = 50,
  double tileSize = 512,
  double earthRadius = 6378137,
}) {
  final metersPerPixel = (2 * pi * earthRadius) / (tileSize * pow(2, zoom));
  return clusterPixelRadius * metersPerPixel;
}

class MarkerData {
  MarkerData({
    required this.coordinates,
    required this.onTap,
    required this.picture,
    required this.title,
    required this.subTitle,
    required this.type,
  });

  final LatLng coordinates;
  final VoidCallback onTap;
  final List<int>? picture;
  final String title;
  final String subTitle;
  final MarkerType type;
}

class MapPage extends StatefulWidget {
  const MapPage({this.latitude, this.longitude, super.key});

  final double? latitude;
  final double? longitude;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _controller;
  Map<String, MarkerData> _markers = {};
  DateTime? _timeSelection;
  bool _isGpsLoading = false;
  Symbol? _selectedLocationSymbol;
  SearchResult? _pendingLocation;
  bool _pendingIsGpsLocation = false;

  Future<void> _useCurrentGpsLocation() async {
    setState(() => _isGpsLoading = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Location services are disabled.')),
            );
        }
        setState(() => _isGpsLoading = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Location permission denied.')),
              );
          }
          setState(() => _isGpsLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Location permission permanently denied.'),
              ),
            );
        }
        setState(() => _isGpsLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 30),
        ),
      );

      final result = SearchResult(
        longitude: position.longitude,
        latitude: position.latitude,
        placeName:
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        id: '',
      );

      if (!mounted) return;
      setState(() => _isGpsLoading = false);

      await _onLocationSelected(result, isGpsLocation: true);
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Could not determine GPS location (timeout).'),
            ),
          );
      }
      setState(() => _isGpsLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Could not determine GPS location.')),
          );
      }
      setState(() => _isGpsLoading = false);
    }
  }

  Future<void> _onLocationSelected(
    SearchResult location, {
    bool isGpsLocation = false,
    bool animateCamera = true,
  }) async {
    final latLng = LatLng(location.latitude, location.longitude);

    // Only animate camera for search/GPS selections, not long-press
    if (animateCamera) {
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
    }

    // Remove previous selected marker if exists
    if (_selectedLocationSymbol != null) {
      await _controller?.removeSymbol(_selectedLocationSymbol!);
    }

    // Add marker image if not exists
    await _controller?.addImage(
      'selected-marker',
      await iconToUint8List(
        Icons.location_on,
        size: 64,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    _selectedLocationSymbol = await _controller?.addSymbol(
      SymbolOptions(
        geometry: latLng,
        iconImage: 'selected-marker',
        iconSize: 2,
        iconAnchor: 'bottom',
      ),
    );

    if (!mounted) return;

    // Store pending location
    setState(() {
      _pendingLocation = location;
      _pendingIsGpsLocation = isGpsLocation;
    });
  }

  void _clearPendingLocation() {
    if (_selectedLocationSymbol != null) {
      _controller?.removeSymbol(_selectedLocationSymbol!);
      _selectedLocationSymbol = null;
    }
    setState(() {
      _pendingLocation = null;
      _pendingIsGpsLocation = false;
    });
  }

  Future<void> _confirmPendingLocation() async {
    if (_pendingLocation == null) return;

    final location = _pendingLocation!;
    final isGpsLocation = _pendingIsGpsLocation;

    await _showShareLocationDialog(location, isGpsLocation: isGpsLocation);
  }

  Future<void> _onMapLongPress(Point<double> point, LatLng latLng) async {
    // Check if there's a marker nearby - if so, don't trigger
    final currentZoom = _controller?.cameraPosition?.zoom ?? 10;
    final thresholdMeters = calculateClusterThresholdMeters(
      zoom: currentZoom,
      latitude: latLng.latitude,
      clusterPixelRadius: 30,
    );

    final hasNearbyMarker = _markers.values.any(
      (marker) =>
          Geolocator.distanceBetween(
            marker.coordinates.latitude,
            marker.coordinates.longitude,
            latLng.latitude,
            latLng.longitude,
          ) <
          thresholdMeters,
    );

    if (hasNearbyMarker) return;

    // Show marker immediately with coordinates
    final coordsResult = SearchResult(
      longitude: latLng.longitude,
      latitude: latLng.latitude,
      placeName:
          '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
      id: '',
    );
    await _onLocationSelected(coordsResult, animateCamera: false);

    // Fetch address asynchronously and update when available
    unawaited(
      reverseGeocode(
        longitude: latLng.longitude,
        latitude: latLng.latitude,
        apiKey: maptilerToken(),
      ).then((reverseResult) {
        if (reverseResult != null &&
            mounted &&
            _pendingLocation?.latitude == latLng.latitude &&
            _pendingLocation?.longitude == latLng.longitude) {
          setState(() => _pendingLocation = reverseResult);
        }
      }),
    );
  }

  Future<void> _showShareLocationDialog(
    SearchResult location, {
    bool isGpsLocation = false,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => ShareLocationBottomSheet(
        location: location,
        isGpsLocation: isGpsLocation,
        onClose: _clearPendingLocation,
      ),
    );

    // Also clear pending location if bottom sheet dismissed without action
    _clearPendingLocation();
  }

  Future<void> _showClusterMarkerList(List<String> markerIds) async {
    final defaultImageData = await DefaultAssetBundle.of(
      context,
    ).load('assets/images/icon.png');
    if (!context.mounted) {
      return;
    }
    return showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsetsGeometry.all(8),
        child: ListView(
          children: markerIds
              .map(
                (id) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: MemoryImage(
                      (_markers[id]?.picture?.isEmpty ?? true)
                          ? defaultImageData.buffer.asUint8List()
                          : Uint8List.fromList(_markers[id]!.picture!),
                    ),
                    radius: 16,
                  ),
                  title: Text(
                    '${_markers[id]?.title} @ ${_markers[id]?.subTitle}',
                  ),
                  dense: false,
                  onTap: () {
                    Navigator.pop(context);
                    _markers[id]?.onTap.call();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _onFeatureTapped(
    Point<double> point,
    LatLng coordinates,
    String id,
    String layerId,
    Annotation? annotation,
  ) async {
    // On individual location tap, call stored callback
    if (layerId == 'unclustered-points') {
      _markers[id]?.onTap.call();
    }

    // On cluster tap
    // NOTE: This causes the same action twice for some taps that trigger both layers
    if (layerId == 'clusters' || layerId == 'cluster-count') {
      final currentZoom = _controller?.cameraPosition?.zoom;
      if (currentZoom != null) {
        final thresholdMeters = calculateClusterThresholdMeters(
          zoom: currentZoom,
          latitude: coordinates.latitude,
        );
        final nearbyMarkers = _markers.entries
            .where(
              (entry) =>
                  // NOTE: This could also be latlong2.distance
                  Geolocator.distanceBetween(
                    entry.value.coordinates.latitude,
                    entry.value.coordinates.longitude,
                    coordinates.latitude,
                    coordinates.longitude,
                  ) <
                  thresholdMeters,
            )
            .toList();
        // If we have more than one close by marker but they are all located at the same spot, show a list of them
        if (nearbyMarkers.length > 1 &&
            nearbyMarkers.map((e) => e.value.coordinates).toSet().length == 1) {
          await _showClusterMarkerList(
            nearbyMarkers.map((e) => e.key).toList(),
          );
        } else {
          // otherwise, zoom in
          await _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(coordinates, currentZoom + 2),
          );
        }
      }
    }
  }

  void _onSymbolTapped(Symbol symbol) {
    // If tapped symbol is the pending location marker, open share dialog
    if (_selectedLocationSymbol != null &&
        symbol.id == _selectedLocationSymbol!.id) {
      _confirmPendingLocation();
    }
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _controller = controller;
    controller.onFeatureTapped.add(_onFeatureTapped);
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  @override
  void dispose() {
    _controller?.onFeatureTapped.remove(_onFeatureTapped);
    _controller?.onSymbolTapped.remove(_onSymbolTapped);
    _controller = null;
    super.dispose();
  }

  List<MarkerData> _getMarkers(
    BuildContext context,
    MapState state,
    DateTime? timeSelection,
  ) => [
    ...filterTemporaryLocations(
      state.profileInfo?.temporaryLocations ?? {},
      timeSelection: timeSelection,
    ).entries.map(
      (l) => MarkerData(
        coordinates: LatLng(l.value.latitude, l.value.longitude),
        onTap: () => showModalTemporaryLocationDetails(
          context,
          contactName: 'Me',
          location: l.value,
          locationId: l.key,
          showEditAndDelete: true,
          circles: state.circles,
          circleMemberships: state.circleMemberships,
        ),
        picture: state.profileInfo?.pictures.values.firstOrNull,
        title: 'Me',
        subTitle: l.value.name,
        type: (l.value.checkedIn) ? MarkerType.checkedIn : MarkerType.temporary,
      ),
    ),
    // Contacts temporary locations
    ...state.contacts
        .map(
          (c) =>
              filterTemporaryLocations(
                c.temporaryLocations,
                timeSelection: timeSelection,
              ).entries.map(
                (l) => MarkerData(
                  coordinates: LatLng(l.value.latitude, l.value.longitude),
                  onTap: () => showModalTemporaryLocationDetails(
                    context,
                    contactName: c.name,
                    location: l.value.copyWith(coagContactId: c.coagContactId),
                    locationId: l.key,
                  ),
                  picture: c.details?.picture,
                  title: c.name,
                  subTitle: l.value.name,
                  type: MarkerType.temporary,
                ),
              ),
        )
        .expand((l) => l),
    // Profile address locations
    ...(state.profileInfo?.addressLocations ?? {})
        .map(
          (label, location) => MapEntry(
            label,
            MarkerData(
              coordinates: LatLng(location.latitude, location.longitude),
              onTap: () => showModalAddressLocationDetails(
                context,
                contactName: 'Me',
                label: label,
                location: location,
              ),
              picture: state.profileInfo?.pictures.values.firstOrNull,
              title: 'Me',
              subTitle: label,
              type: MarkerType.address,
            ),
          ),
        )
        .values,
    // Contacts address locations
    ...state.contacts
        .map(
          (c) => c.addressLocations
              .map(
                (label, location) => MapEntry(
                  label,
                  MarkerData(
                    coordinates: LatLng(location.latitude, location.longitude),
                    onTap: () => showModalAddressLocationDetails(
                      context,
                      label: label,
                      contactName: c.name,
                      location: location,
                    ),
                    picture: c.details?.picture,
                    title: c.name,
                    subTitle: label,
                    type: MarkerType.address,
                  ),
                ),
              )
              .values,
        )
        .expand((l) => l),
  ];

  Future<void> _addMarkerImages(List<MarkerData> markers) async {
    final defaultImageData = await DefaultAssetBundle.of(
      context,
    ).load('assets/images/icon.png');
    final defaultImage = await createCircularImageWithBorder(
      defaultImageData.buffer.asUint8List(),
      isWeb ? 42 : 128,
      borderWidth: 3,
    );
    for (final e in markers.asMap().entries) {
      var image = defaultImage;
      try {
        image = await createCircularImageWithBorder(
          Uint8List.fromList(e.value.picture ?? []),
          isWeb ? 42 : 128,
          borderWidth: 3,
        );
      } catch (e) {
        // Invalid Image Data - that's what we sometimes see here, likely for empty lists
      }
      await _controller?.addImage('icon-${e.key}', image);
    }
  }

  Future<void> _onStyleLoaded(BuildContext context, MapState state) async {
    final markers = _getMarkers(context, state, _timeSelection);

    final clusterCircleColor = colorToHex(
      Theme.of(context).colorScheme.primary,
    );
    final clusterCircleTextColor = colorToHex(
      Theme.of(context).colorScheme.onPrimary,
    );

    await _addMarkerImages(markers);

    setState(() {
      _markers = markers.asMap().map(
        (i, marker) => MapEntry('marker-$i', marker),
      );
    });

    // Add GeoJSON source with clustering enabled
    await _controller?.addSource(
      'points',
      GeojsonSourceProperties(
        data: toGeoJson(markers.map((m) => m.coordinates).toList()),
        cluster: true,
        clusterMaxZoom: 22,
        clusterRadius: 50,
      ),
    );

    // Layer: individual unclustered points (add first)
    if (!(await _controller?.getLayerIds() ?? []).contains(
      'unclustered-points',
    )) {
      await _controller?.addLayer(
        'points',
        'unclustered-points',
        const SymbolLayerProperties(
          iconImage: ['get', 'icon'],
          iconSize: 1,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
        ),
        filter: [
          '!',
          ['has', 'point_count'],
        ],
      );
    }

    // Layer: cluster circles (simpler styling first)
    if (!(await _controller?.getLayerIds() ?? []).contains('clusters')) {
      await _controller?.addLayer(
        'points',
        'clusters',
        CircleLayerProperties(
          circleColor: clusterCircleColor,
          circleRadius: 25,
          circleStrokeWidth: 0,
          circleStrokeColor: '#ffffff',
        ),
        filter: ['has', 'point_count'],
      );
    }

    // Layer: cluster count text
    if (!(await _controller?.getLayerIds() ?? []).contains('cluster-count')) {
      await _controller?.addLayer(
        'points',
        'cluster-count',
        SymbolLayerProperties(
          textField: ['get', 'point_count_abbreviated'],
          textSize: 16,
          textColor: clusterCircleTextColor,
          textHaloColor: '#000000',
          textHaloWidth: 0,
        ),
        filter: ['has', 'point_count'],
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => MapCubit(
      context.read<Storage<CoagContact>>(),
      context.read<Storage<Circle>>(),
      context.read<Storage<ProfileInfo>>(),
      context.read<SettingsRepository>(),
    ),
    child: BlocConsumer<MapCubit, MapState>(
      listener: (context, state) async {
        if (_controller != null) {
          final sourceIds = await _controller!.getSourceIds();
          if (sourceIds.contains('points') && context.mounted) {
            final markers = _getMarkers(context, state, _timeSelection);
            await _controller?.setGeoJsonSource(
              'points',
              toGeoJson(markers.map((m) => m.coordinates).toList()),
            );
            setState(() {
              _markers = markers.asMap().map(
                (i, marker) => MapEntry('marker-$i', marker),
              );
            });
            await _addMarkerImages(markers);
          }
        }
      },
      builder: (context, state) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: (state.profileInfo == null)
            ? const Center(child: CircularProgressIndicator())
            // WORKAROUND: MapLibre native platform view resizes when
            // the on-screen keyboard appears/disappears, causing the map
            // to visually "jump". Flutter's resizeToAvoidBottomInset,
            // MediaQuery overrides, and LayoutBuilder constraints don't
            // prevent this because the native Android view receives
            // viewport changes directly from the platform.
            //
            // Solution: Use the device's physical screen size (which never
            // changes) with Positioned to place the map at fixed coordinates,
            // and RepaintBoundary to isolate the render tree.
            : Builder(
                builder: (context) {
                  final view = View.of(context);
                  final physicalSize =
                      view.physicalSize / view.devicePixelRatio;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        width: physicalSize.width,
                        height: physicalSize.height,
                        child: RepaintBoundary(
                          child: MapLibreMap(
                            styleString: context
                                .read<SettingsRepository>()
                                .mapStyleString,
                            initialCameraPosition: CameraPosition(
                              target:
                                  (widget.latitude != null &&
                                      widget.longitude != null)
                                  ? LatLng(widget.latitude!, widget.longitude!)
                                  : initialLocation(
                                          state
                                                  .profileInfo
                                                  ?.addressLocations
                                                  .values ??
                                              [],
                                          state
                                                  .profileInfo
                                                  ?.temporaryLocations
                                                  .values ??
                                              [],
                                          state.contacts
                                              .map(
                                                (c) =>
                                                    c.addressLocations.values,
                                              )
                                              .expand((l) => l),
                                          state.contacts
                                              .map(
                                                (c) =>
                                                    c.temporaryLocations.values,
                                              )
                                              .expand((l) => l),
                                        ) ??
                                        const LatLng(20, 0),
                              zoom:
                                  (widget.latitude != null &&
                                      widget.longitude != null)
                                  ? 12
                                  : 2.5,
                            ),
                            trackCameraPosition: true,
                            minMaxZoomPreference: const MinMaxZoomPreference(
                              null,
                              22,
                            ),
                            onMapCreated: _onMapCreated,
                            onStyleLoadedCallback: () =>
                                _onStyleLoaded(context, state),
                            onMapLongClick: _onMapLongPress,
                            attributionButtonMargins: const Point<num>(12, 12),
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            dragEnabled: true,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomStart,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          child: MapLocationSearchBar(
                            onLocationSelected: _onLocationSelected,
                            onGpsLocationRequested: _useCurrentGpsLocation,
                            onAddLocation: _confirmPendingLocation,
                            onClearSelection: _clearPendingLocation,
                            selectedLocation: _pendingLocation,
                            isGpsLoading: _isGpsLoading,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32, right: 8),
                          child: IconButton.filledTonal(
                            onPressed: () =>
                                context.pushNamed('locationListPage'),
                            icon: const Icon(Icons.list),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    ),
  );
}
