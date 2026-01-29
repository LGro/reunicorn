// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart';

import '../../utils.dart';
import '../../widgets/details_list.dart';
import '../cubit.dart';

Future<void> pickCirclePicture(
  BuildContext context,
  Future<void> Function(Uint8List picture) handlePicture,
) async {
  try {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );
    if (context.mounted && pickedFile != null) {
      final p = await pickedFile.readAsBytes();
      await handlePicture(p);
    }
  } catch (e) {
    // TODO: Handle
    logDebug(e);
  }
}

class CirclesWithAvatarWidget extends StatefulWidget {
  const CirclesWithAvatarWidget({
    super.key,
    required this.circles,
    required this.title,
    required this.pictures,
    required this.circleMemberCount,
    this.editCallback,
    this.deleteCallback,
  });

  final Text title;
  final Map<String, Uint8List> pictures;
  final Map<String, String> circles;
  final Map<String, int> circleMemberCount;
  final void Function(String circleId, Uint8List picture)? editCallback;
  final void Function(String circleId)? deleteCallback;

  @override
  State<CirclesWithAvatarWidget> createState() =>
      _CirclesWithAvatarWidgetState();
}

class _CirclesWithAvatarWidgetState extends State<CirclesWithAvatarWidget> {
  // TODO: Is local state management even necessary?
  Map<String, Uint8List> _pictures = {};

  @override
  void initState() {
    super.initState();
    _pictures = widget.pictures;
  }

  @override
  Widget build(BuildContext context) => DetailsCard(
    title: widget.title,
    children:
        <Widget>[const SizedBox(height: 6)] +
        widget.circles
            .map(
              (circleId, circleLabel) => MapEntry<String, Widget>(
                circleId,
                Dismissible(
                  key: Key('picture|$circleId'),
                  direction: (widget.deleteCallback != null)
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  confirmDismiss: (widget.deleteCallback != null)
                      ? (_) async {
                          widget.deleteCallback!(circleId);
                          setState(() {
                            _pictures = _pictures..remove(circleId);
                          });
                          // Ensure the UI element is not actually removed
                          return false;
                        }
                      : null,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => pickCirclePicture(context, (p) async {
                      final _updatedPictures = {..._pictures};
                      _updatedPictures[circleId] = p;
                      if (context.mounted) {
                        await context.read<ProfileCubit>().updateAvatar(
                          circleId,
                          p,
                        );
                      }
                      setState(() {
                        _pictures = _updatedPictures;
                      });
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          if (!_pictures.containsKey(circleId))
                            const CircleAvatar(
                              radius: 48,
                              child: Icon(Icons.person),
                            ),
                          if (_pictures.containsKey(circleId))
                            CircleAvatar(
                              backgroundImage: MemoryImage(
                                _pictures[circleId]!,
                              ),
                              radius: 48,
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                'Circle: $circleLabel\nShared with '
                                '${widget.circleMemberCount[circleId] ?? 0} '
                                'contact${(widget.circleMemberCount[circleId] == 1) ? '' : 's'}',
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .values
            .asList() +
        [
          const SizedBox(height: 8),
          Text(context.loc.profilePictureExplainer),
          const SizedBox(height: 4),
        ],
  );
}
