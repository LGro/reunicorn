import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:loggy/loggy.dart';
import 'package:veilid_support/veilid_support.dart';
import 'package:xterm/xterm.dart';

import '../../tools/tools.dart';
import 'history_text_editing_controller.dart';

final globalDebugTerminal = Terminal(maxLines: 10000);

const kDefaultTerminalStyle = TerminalStyle(
  fontSize: 11,
  // height: 1.2,
  fontFamily: 'Source Code Pro',
);

class LogLevelDropdownItem {
  final String label;

  final Widget icon;

  final LogLevel value;

  const LogLevelDropdownItem({
    required this.label,
    required this.icon,
    required this.value,
  });
}

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  @override
  void initState() {
    super.initState();

    _historyController = HistoryTextEditingController(setState: setState);

    _terminalController.addListener(() {
      setState(() {});
    });
  }

  void _debugOut(String out) {
    final sanitizedOut = out.replaceAll('\uFFFD', '');
    final pen = AnsiPen()..cyan(bold: true);
    final colorOut = pen(sanitizedOut);
    debugPrint(colorOut);
    globalDebugTerminal.write(colorOut.replaceAll('\n', '\r\n'));
  }

  Future<bool> _sendDebugCommand(String debugCommand) async {
    try {
      setState(() {
        _busy = true;
      });

      if (debugCommand == 'pool allocations') {
        try {
          DHTRecordPool.instance.debugPrintAllocations();
        } on Exception catch (e, st) {
          _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
          return false;
        }
        return true;
      }

      if (debugCommand == 'pool opened') {
        try {
          DHTRecordPool.instance.debugPrintOpened();
        } on Exception catch (e, st) {
          _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
          return false;
        }
        return true;
      }

      if (debugCommand == 'pool stats') {
        try {
          DHTRecordPool.instance.debugPrintStats();
        } on Exception catch (e, st) {
          _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
          return false;
        }
        return true;
      }

      if (debugCommand.startsWith('change_log_ignore ')) {
        final args = debugCommand.split(' ');
        if (args.length < 3) {
          _debugOut('Incorrect number of arguments');
          return false;
        }
        final layer = args[1];
        final changes = args[2].split(',');
        try {
          Veilid.instance.changeLogIgnore(layer, changes);
        } on Exception catch (e, st) {
          _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
          return false;
        }

        return true;
      }

      if (debugCommand == 'ellet') {
        setState(() {
          _showEllet = !_showEllet;
        });
        return true;
      }

      _debugOut('DEBUG >>>\n$debugCommand\n');
      try {
        var out = await Veilid.instance.debug(debugCommand);

        if (debugCommand == 'help') {
          out =
              'VeilidChat Commands:\n'
              '    pool <allocations|opened|stats>\n'
              '        allocations - List DHTRecordPool allocations\n'
              '        opened - List opened DHTRecord instances\n'
              '        stats - Dump DHTRecordPool statistics\n'
              '    change_log_ignore <layer> <changes> change the log'
              ' target ignore list for a tracing layer\n'
              '        targets to add to the ignore list can be separated by'
              ' a comma.\n'
              '        to remove a target from the ignore list, prepend it'
              ' with a minus.\n\n$out';
        }

        _debugOut('<<< DEBUG\n$out\n');
      } on Exception catch (e, st) {
        _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
        return false;
      }

      return true;
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> clear(BuildContext context) async {
    globalDebugTerminal.buffer.clear();
    // if (context.mounted) {
    //   context.read<NotificationsCubit>().info(
    //     text: context.tr('developer.cleared'),
    //   );
    // }
  }

  Future<void> copySelection(BuildContext context) async {
    final selection = _terminalController.selection;
    if (selection != null) {
      final text = globalDebugTerminal.buffer.getText(selection);
      _terminalController.clearSelection();
      await Clipboard.setData(ClipboardData(text: text));
      // if (context.mounted) {
      //   context.read<NotificationsCubit>().info(
      //     text: context.tr('developer.copied'),
      //   );
      // }
    }
  }

  Future<void> copyAll(BuildContext context) async {
    final text = globalDebugTerminal.buffer.getText();
    await Clipboard.setData(ClipboardData(text: text));
    // if (context.mounted) {
    //   context.read<NotificationsCubit>().info(
    //     text: context.tr('developer.copied_all'),
    //   );
    // }
  }

  Future<void> _onSubmitCommand(String debugCommand) async {
    final ok = await _sendDebugCommand(debugCommand);
    if (ok) {
      setState(() {
        _historyController.submit(debugCommand);
      });
    }
  }

  List<LogLevelDropdownItem> _getLogLevelDropdownItems(BuildContext context) {
    final logLevelDropdownItems = <LogLevelDropdownItem>[];

    for (var i = 0; i < logLevels.length; i++) {
      logLevelDropdownItems.add(
        LogLevelDropdownItem(
          label: logLevelName(logLevels[i]),
          icon: Text(logLevelEmoji(logLevels[i])),
          value: logLevels[i],
        ),
      );
    }

    return logLevelDropdownItems;
  }

  @override
  Widget build(BuildContext context) {
    final logLevelDropdownItems = _getLogLevelDropdownItems(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('developer.title'),
        leading: IconButton(
          iconSize: 24,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouterHelper(context).pop(),
        ),
        actions: [
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.copy),
            onPressed: _terminalController.selection == null
                ? null
                : () async {
                    await copySelection(context);
                  },
          ),
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.copy_all),
            onPressed: () async {
              await copyAll(context);
            },
          ),
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              // final confirm = await showConfirmModal(
              //   context: context,
              //   title: 'confirmation.confirm',
              //   text: 'developer.are_you_sure_clear',
              // );
              // if (confirm && context.mounted) {
              await clear(context);
              // }
            },
          ),
          SizedBox.fromSize(
            size: Size(140, 48),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: Theme.of(context).inputDecorationTheme
                    .copyWith(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
              ),
              child: CustomDropdown<LogLevelDropdownItem>(
                items: logLevelDropdownItems,
                initialItem: logLevelDropdownItems.singleWhere(
                  (x) => x.value == _logLevelDropDown,
                ),
                onChanged: (item) {
                  if (item != null) {
                    setState(() {
                      _logLevelDropDown = item.value;
                      Loggy('').level = getLogOptions(item.value);
                      setVeilidLogLevel(
                        '#common=${item.value.name.toLowerCase()}',
                      );
                    });
                  }
                },
                headerBuilder: (context, item, enabled) => Row(
                  children: [item.icon, const Spacer(), Text(item.label)],
                ),
                listItemBuilder: (context, item, enabled, onItemSelect) => Row(
                  children: [item.icon, const Spacer(), Text(item.label)],
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TerminalView(
                      globalDebugTerminal,
                      textStyle: kDefaultTerminalStyle,
                      textScaler: TextScaler.noScaling,
                      controller: _terminalController,
                      keyboardType: TextInputType.none,
                      backgroundOpacity: _showEllet ? 0.75 : 1.0,
                      onSecondaryTapDown: (details, offset) async {
                        await copySelection(context);
                      },
                    ),
                  ),
                  TextFormField(
                    enabled: !_busy,
                    autofocus: true,
                    controller: _historyController.controller,
                    focusNode: _historyController.focusNode,
                    textInputAction: TextInputAction.send,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'dev command',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed:
                            (_historyController.controller.text.isEmpty ||
                                _busy)
                            ? null
                            : () async {
                                final debugCommand =
                                    _historyController.controller.text;
                                _historyController.controller.clear();
                                await _onSubmitCommand(debugCommand);
                              },
                      ),
                    ),
                    onChanged: (_) {
                      setState(() => {});
                    },
                    onEditingComplete: () {
                      // part of the default action if onEditingComplete is null
                      _historyController.controller.clearComposing();
                      // don't give up focus though
                    },
                    onFieldSubmitted: (debugCommand) async {
                      if (debugCommand.isEmpty) {
                        return;
                      }
                      await _onSubmitCommand(debugCommand);
                      _historyController.focusNode.requestFocus();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////

  final _terminalController = TerminalController();
  late final HistoryTextEditingController _historyController;

  var _logLevelDropDown = log.level.logLevel;

  var _showEllet = false;
  var _busy = false;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<TerminalController>(
          'terminalController',
          _terminalController,
        ),
      )
      ..add(
        DiagnosticsProperty<LogLevel>('logLevelDropDown', _logLevelDropDown),
      );
  }
}
