// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Non-scrollable, variable-height list that shows only as many items as fully fit `maxRowsHeight`.
class DynamicFitList<T> extends StatefulWidget {
  const DynamicFitList({
    required this.items,
    required this.maxRowsHeight,
    required this.itemBuilder,
  });

  final List<T> items;

  /// space budget for rows (no headlines)
  final double maxRowsHeight;
  final Widget Function(BuildContext, T) itemBuilder;

  @override
  State<DynamicFitList<T>> createState() => DynamicFitListState<T>();
}

class DynamicFitListState<T> extends State<DynamicFitList<T>> {
  late List<double?> _heights;

  @override
  void initState() {
    super.initState();
    _heights = List<double?>.filled(widget.items.length, null);
  }

  @override
  void didUpdateWidget(covariant DynamicFitList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _heights = List<double?>.filled(widget.items.length, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Decide how many items fully fit.
    var visibleCount = 0;
    double used = 0;
    for (var i = 0; i < widget.items.length; i++) {
      final h = _heights[i];
      if (h == null) {
        break;
      }
      if (used + h <= widget.maxRowsHeight) {
        used += h;
        visibleCount++;
      } else {
        break;
      }
    }

    final visibleItems = widget.items.take(visibleCount).toList();

    return Stack(
      children: [
        // Visible, non-scrollable content — Column so it only takes the height of shown rows.
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            visibleItems.length,
            (i) => widget.itemBuilder(context, visibleItems[i]),
          ),
        ),

        // Offstage measuring pass (same width as real layout due to parent constraints).
        Offstage(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.items.length,
              (i) => MeasureSize(
                onChange: (size) {
                  final h = size.height;
                  if (i >= 0 && i < _heights.length && _heights[i] != h) {
                    setState(() => _heights[i] = h);
                  }
                },
                child: widget.itemBuilder(context, widget.items[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reports its laid-out size via [onChange].
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({required this.onChange, required Widget super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _old;

  @override
  void performLayout() {
    super.performLayout();
    final s = child?.size ?? Size.zero;
    if (_old == null || _old != s) {
      _old = s;
      WidgetsBinding.instance.addPostFrameCallback((_) => onChange(s));
    }
  }
}
