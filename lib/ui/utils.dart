// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:veilid/veilid.dart';

import '../data/models/coag_contact.dart';
import '../data/models/contact_introduction.dart';
import '../l10n/app_localizations.dart';
import 'batch_invite_management/cubit.dart';

extension LocalizationExt on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

String extractAllValuesToString(dynamic value) {
  if (value is Map) {
    return value.values.map(extractAllValuesToString).join('|');
  } else if (value is List) {
    return value.map(extractAllValuesToString).join('|');
  } else {
    return value.toString();
  }
}

// TODO: Also search temporary locations?
bool searchMatchesContact(String search, CoagContact contact) =>
    contact.name.toLowerCase().contains(search.toLowerCase()) ||
    (contact.details != null &&
        extractAllValuesToString(
          contact.details!.toJson(),
        ).toLowerCase().contains(search.toLowerCase()));

Widget roundPictureOrPlaceholder(
  List<int>? picture, {
  double? radius,
  bool clipOval = true,
}) {
  final image = Image.memory(
    Uint8List.fromList(picture ?? []),
    gaplessPlayback: true,
    width: (radius == null) ? null : radius * 2,
    height: (radius == null) ? null : radius * 2,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
        CircleAvatar(radius: radius, child: const Icon(Icons.person)),
  );
  if (clipOval) {
    return ClipOval(child: image);
  }
  return image;
}

String commasToNewlines(String s) =>
    s.split(',').map((p) => p.trim()).join('\n');

/// Detect added or updated values in new map
/// If the key didn't exist before, or its value has changed, we've got an
/// update. Removals count as no change, because when an abuse victim stops
/// sharing details with their abuser, we do not want to alert them.
bool addedOrUpdatedValue(
  Map<String, dynamic> oldMap,
  Map<String, dynamic> newMap,
) =>
    newMap.entries.firstWhereOrNull(
      (e) => !oldMap.containsKey(e.key) || oldMap[e.key] != e.value,
    ) !=
    null;

String contactUpdateSummary(CoagContact oldContact, CoagContact newContact) {
  final results = <String>[];

  final oldDetails = oldContact.details ?? const ContactDetails();
  final newDetails = newContact.details ?? const ContactDetails();

  if ((newDetails.picture?.isNotEmpty ?? false) &&
      !(oldDetails.picture ?? []).equals(newDetails.picture ?? [])) {
    results.add('picture');
  }

  if (addedOrUpdatedValue(oldDetails.names, newDetails.names)) {
    results.add('names');
  }

  if (addedOrUpdatedValue(oldDetails.emails, newDetails.emails)) {
    results.add('emails');
  }

  if (addedOrUpdatedValue(oldDetails.phones, newDetails.phones)) {
    results.add('phones');
  }

  if (addedOrUpdatedValue(oldDetails.websites, newDetails.websites)) {
    results.add('websites');
  }

  if (addedOrUpdatedValue(oldDetails.socialMedias, newDetails.socialMedias)) {
    results.add('socials');
  }

  if (addedOrUpdatedValue(
    oldContact.addressLocations,
    newContact.addressLocations,
  )) {
    results.add('addresses');
  }

  if (addedOrUpdatedValue(oldDetails.events, newDetails.events)) {
    results.add('dates');
  }

  if (addedOrUpdatedValue(oldDetails.organizations, newDetails.organizations)) {
    results.add('organizations');
  }

  // TODO: Make this consistent with the yesterday filtering we do elsewhere?
  final filteredOld = Map.fromEntries(
    oldContact.temporaryLocations.entries.where(
      (e) => e.value.end.isAfter(DateTime.now()),
    ),
  );
  final filteredNew = Map.fromEntries(
    newContact.temporaryLocations.entries.where(
      (e) => e.value.end.isAfter(DateTime.now()),
    ),
  );
  if (addedOrUpdatedValue(filteredOld, filteredNew)) {
    results.add('locations');
  }

  return results.join(', ');
}

Iterable<String> generateBatchInviteLinks(Batch batch) =>
    batch.subkeyWriters.toList().asMap().entries.map(
          (w) => batchInviteUrl(
            batch.label,
            batch.dhtRecordKey,
            batch.psk,
            // Index of the writer in the list + 1 is the corresponding subkey
            w.key + 1,
            w.value,
          ).toString(),
        );

// TODO: Pass dhtSettings to all the Url generators to make it easier to test that the correct keys are used?
Uri directSharingUrl(
  String name,
  Typed<FixedEncodedString43> dhtRecordKey,
  FixedEncodedString43 psk,
) =>
    Uri(
      scheme: 'https',
      host: 'reunicorn.app',
      path: '/c',
      fragment: [name, dhtRecordKey.toString(), psk.toString()].join('~'),
    );

Uri profileUrl(String name, PublicKey publicKey) => Uri(
      scheme: 'https',
      host: 'reunicorn.app',
      path: '/p',
      fragment: [name, publicKey.toString()].join('~'),
    );

Uri batchInviteUrl(
  String label,
  Typed<FixedEncodedString43> dhtRecordKey,
  FixedEncodedString43 psk,
  int subKeyIndex,
  KeyPair writer,
) =>
    Uri(
      scheme: 'https',
      host: 'reunicorn.app',
      path: '/b',
      fragment: [
        label,
        dhtRecordKey.toString(),
        psk.toString(),
        // Index of the writer in the list + 1 is the corresponding subkey
        subKeyIndex.toString(),
        writer.toString(),
      ].join('~'),
    );

Uri profileBasedOfferUrl(
  String name,
  Typed<FixedEncodedString43> dhtRecordKey,
  FixedEncodedString43 publicKey,
) =>
    Uri(
      scheme: 'https',
      host: 'reunicorn.app',
      path: '/o',
      fragment: [name, dhtRecordKey.toString(), publicKey.toString()].join('~'),
    );

bool showSharingInitializing(CoagContact contact) =>
    contact.dhtSettings.recordKeyThemSharing == null ||
    contact.dhtSettings.recordKeyMeSharing == null;

bool showSharingOffer(CoagContact contact) =>
    contact.dhtSettings.recordKeyThemSharing != null &&
    contact.dhtSettings.initialSecret == null &&
    contact.dhtSettings.myKeyPair != null &&
    contact.details == null;

bool showDirectSharing(CoagContact contact) =>
    contact.dhtSettings.recordKeyThemSharing != null &&
    contact.dhtSettings.initialSecret != null &&
    contact.details == null;

/// Returns introducer and introduction for pending introductions
Iterable<(CoagContact, ContactIntroduction)> pendingIntroductions(
  Iterable<CoagContact> contacts,
) =>
    contacts
        .map(
          (c) => c.introductionsByThem
              .where(
                (i) => !contacts
                    .map((c) => c.dhtSettings.recordKeyThemSharing)
                    .whereType<Typed<FixedEncodedString43>>()
                    .contains(i.dhtRecordKeyReceiving),
              )
              .map((i) => (c, i)),
        )
        .expand((i) => i);

Widget buildEditOrAddWidgetSkeleton(
  BuildContext context, {
  required String title,
  required List<Widget> children,
  required Widget onSaveWidget,
}) =>
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Icons.cancel_outlined),
              ),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              onSaveWidget,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );

List<(String, String)> labelValueMapToTupleList(Map<String, String> map) =>
    map.map((key, value) => MapEntry(key, (key, value))).values.toList();

Future<Uint8List> iconToUint8List(IconData iconData,
    {double size = 48, Color color = Colors.black}) async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);

  final textPainter = TextPainter(textDirection: ui.TextDirection.ltr)
    ..text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: color,
      ),
    )
    ..layout()
    ..paint(canvas, Offset.zero);

  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(
    textPainter.width.ceil(),
    textPainter.height.ceil(),
  );

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    // Fallback: create a simple red circle as default marker
    final fallbackRecorder = ui.PictureRecorder();
    final fallbackCanvas = Canvas(fallbackRecorder);
    final paint = Paint()..color = Colors.red;
    fallbackCanvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    final fallbackPicture = fallbackRecorder.endRecording();
    final fallbackImage =
        await fallbackPicture.toImage(size.toInt(), size.toInt());
    final fallbackByteData =
        await fallbackImage.toByteData(format: ui.ImageByteFormat.png);
    return fallbackByteData?.buffer.asUint8List() ?? Uint8List(0);
  }
  return byteData.buffer.asUint8List();
}

Future<Uint8List> createCircularImageWithBorder(
    Uint8List imageBytes, double size,
    {Color borderColor = Colors.white, double borderWidth = 2.0}) async {
  final codec = await ui.instantiateImageCodec(imageBytes);
  final frameInfo = await codec.getNextFrame();
  final originalImage = frameInfo.image;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final radius = size / 2;
  final imageRect = Rect.fromLTWH(borderWidth, borderWidth,
      size - (borderWidth * 2), size - (borderWidth * 2));

  // Draw border circle
  final Paint borderPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

  // Clip to inner circle for image
  canvas.clipRRect(RRect.fromRectAndRadius(
      imageRect, Radius.circular((size - borderWidth * 2) / 2)));

  // Calculate center crop dimensions for rectangular images
  final originalWidth = originalImage.width.toDouble();
  final originalHeight = originalImage.height.toDouble();

  // Find the smaller dimension to create a square crop from center
  final cropSize =
      originalWidth < originalHeight ? originalWidth : originalHeight;

  // Calculate offset to crop from center
  final cropLeft = (originalWidth - cropSize) / 2;
  final cropTop = (originalHeight - cropSize) / 2;

  // Source rectangle - square crop from center of original image
  final sourceRect = Rect.fromLTWH(cropLeft, cropTop, cropSize, cropSize);

  // Draw the center-cropped, scaled image
  final imagePaint = Paint()..isAntiAlias = true;
  canvas.drawImageRect(
    originalImage,
    sourceRect,
    imageRect,
    imagePaint,
  );

  final picture = recorder.endRecording();
  final circularImage = await picture.toImage(size.toInt(), size.toInt());

  final byteData =
      await circularImage.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    // Fallback: create a simple red circle as default marker
    final fallbackRecorder = ui.PictureRecorder();
    final fallbackCanvas = Canvas(fallbackRecorder);
    final paint = Paint()..color = Colors.red;
    fallbackCanvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    final fallbackPicture = fallbackRecorder.endRecording();
    final fallbackImage =
        await fallbackPicture.toImage(size.toInt(), size.toInt());
    final fallbackByteData =
        await fallbackImage.toByteData(format: ui.ImageByteFormat.png);
    return fallbackByteData?.buffer.asUint8List() ?? Uint8List(0);
  }
  return byteData.buffer.asUint8List();
}

String colorToHex(Color color, {bool leadingHashSign = true}) =>
    '${leadingHashSign ? '#' : ''}'
    '${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}'
    '${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}';
