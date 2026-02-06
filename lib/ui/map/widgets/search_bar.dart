// Copyright 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../../data/providers/geocoding/maptiler.dart';
import '../../../data/repositories/settings.dart';

/// Bottom search bar widget for location search and GPS
class MapLocationSearchBar extends StatefulWidget {
  const MapLocationSearchBar({
    required this.onLocationSelected,
    required this.onGpsLocationRequested,
    required this.onAddLocation,
    required this.onClearSelection,
    this.selectedLocation,
    this.isGpsLoading = false,
    super.key,
  });

  final void Function(SearchResult) onLocationSelected;
  final VoidCallback onGpsLocationRequested;
  final VoidCallback onAddLocation;
  final VoidCallback onClearSelection;
  final SearchResult? selectedLocation;
  final bool isGpsLoading;

  @override
  State<MapLocationSearchBar> createState() => _MapLocationSearchBarState();
}

class _MapLocationSearchBarState extends State<MapLocationSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<SearchResult> _suggestions = [];
  bool _showSuggestions = false;
  String? _searchingQuery;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Delay hiding to allow tap on suggestion
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() => _showSuggestions = false);
        }
      });
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _searchingQuery = query;
    final results = await searchLocation(
      query: query,
      apiKey: maptilerToken(),
      limit: 5,
    );

    if (_searchingQuery != query || !mounted) return;

    setState(() {
      _suggestions = results;
      _showSuggestions = results.isNotEmpty;
    });
  }

  void _onSuggestionSelected(SearchResult result) {
    _controller.text = result.placeName;
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
    widget.onLocationSelected(result);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MapLocationSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text field when selected location changes
    if (widget.selectedLocation != oldWidget.selectedLocation) {
      if (widget.selectedLocation != null) {
        _controller.text = widget.selectedLocation!.placeName;
      }
    }
  }

  void _clearField() {
    _controller.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    widget.onClearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = widget.selectedLocation != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Suggestions list (appears above search bar)
        // Always in tree to prevent focus loss when suggestions appear
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.bottomCenter,
          child: (_showSuggestions && _suggestions.isNotEmpty)
              ? Container(
                  key: const ValueKey('suggestions'),
                  constraints: const BoxConstraints(maxHeight: 200),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                        ),
                        title: Text(
                          suggestion.placeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _onSuggestionSelected(suggestion),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-suggestions')),
        ),
        // Main row: GPS button | Search field | Add button (when selected)
        Row(
          children: [
            // GPS button
            IconButton.filledTonal(
              onPressed: widget.isGpsLoading
                  ? null
                  : widget.onGpsLocationRequested,
              icon: widget.isGpsLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              tooltip: 'Use current location',
            ),
            const SizedBox(width: 4),
            // Search field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Search for a location...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    // Clear button
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        onPressed: _clearField,
                        icon: const Icon(Icons.clear, size: 20),
                      )
                    else
                      const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Add button - appears when location is selected
            if (hasSelection)
              IconButton.filled(
                onPressed: widget.onAddLocation,
                icon: const Icon(Icons.add),
                tooltip: 'Share this location',
              ),
          ],
        ),
      ],
    );
  }
}
