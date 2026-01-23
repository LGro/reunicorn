// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class SearchableList<T> extends StatefulWidget {
  const SearchableList({
    required this.items,
    required this.matchesItem,
    required this.buildItemWidget,
    this.infoWidget,
    super.key,
  });

  /// All items to display and from which to search
  final List<T> items;

  /// String matching function for search selection of generic T
  final bool Function(String, T) matchesItem;

  /// Function to build list item from T instance
  final Widget Function(T) buildItemWidget;

  /// Optional widget to display between search bar and list entries
  final Widget? infoWidget;
  @override
  State<SearchableList<T>> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<SearchableList<T>> {
  List<T> _filteredItems = [];
  var _query = '';
  final _controller = TextEditingController();

  void search(String query) {
    setState(() {
      _query = query;
      _filteredItems = widget.items
          .where((item) => widget.matchesItem(query, item))
          .toList();
    });
  }

  void reset() {
    setState(() {
      _query = '';
      _controller.text = '';
      _filteredItems = widget.items;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: TextField(
          controller: _controller,
          onChanged: search,
          autocorrect: false,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: reset,
              icon: const Icon(Icons.cancel),
            ),
          ),
        ),
      ),
      if (widget.infoWidget != null) widget.infoWidget!,
      if (_filteredItems.isNotEmpty || _query.isNotEmpty)
        if (_filteredItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'No matching results found',
                textScaler: TextScaler.linear(1.2),
              ),
            ),
          ),
      if (_filteredItems.isNotEmpty)
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) =>
                widget.buildItemWidget(_filteredItems[index]),
          ),
        ),
      if (!(_filteredItems.isNotEmpty || _query.isNotEmpty))
        Expanded(
          child: ListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (context, index) =>
                widget.buildItemWidget(widget.items[index]),
          ),
        ),
    ],
  );
}
