import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TextField History Controller
class HistoryTextEditingController {
  ////////////////////////////////////////////////////////////////////////////

  late void Function(void Function()) setState;

  final TextEditingController _controller;

  late final FocusNode _historyFocusNode;

  final List<String> _history = [];

  var _historyPosition = 0;

  var _historyCurrentEdit = '';

  HistoryTextEditingController({
    required this.setState,
    TextEditingController? controller,
  }) : _controller = controller ?? TextEditingController() {
    _historyFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event.runtimeType == KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (_historyPosition > 0) {
            if (_historyPosition == _history.length) {
              _historyCurrentEdit = _controller.text;
            }
            _historyPosition -= 1;
            setState(() {
              _controller.text = _history[_historyPosition];
            });
          }
          return KeyEventResult.handled;
        } else if (event.runtimeType == KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (_historyPosition < _history.length) {
            _historyPosition += 1;
            setState(() {
              if (_historyPosition == _history.length) {
                _controller.text = _historyCurrentEdit;
              } else {
                _controller.text = _history[_historyPosition];
              }
            });
          }
          return KeyEventResult.handled;
        } else if (event.runtimeType == KeyDownEvent) {
          _historyPosition = _history.length;
          _historyCurrentEdit = _controller.text;
        }
        return KeyEventResult.ignored;
      },
    );
  }

  void submit(String v) {
    // add to history
    if (_history.isEmpty || _history.last != v) {
      _history.add(v);
      if (_history.length > 100) {
        _history.removeAt(0);
      }
    }
    _historyPosition = _history.length;
    setState(() {
      _controller.text = '';
    });
  }

  FocusNode get focusNode => _historyFocusNode;

  TextEditingController get controller => _controller;
}
