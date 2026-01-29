// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class DetailsCard extends StatelessWidget {
  const DetailsCard({this.title, this.children = const [], super.key});

  final Text? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (title != null)
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
              child: title,
            ),
          ],
        ),
      Card(
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    ],
  );
}

class DetailsList extends StatelessWidget {
  const DetailsList(
    this.details, {
    this.title,
    this.circles,
    this.circleMemberships,
    this.getDetailSharingSettings,
    this.editCallback,
    this.addCallback,
    this.deleteCallback,
    this.hideLabel = false,
    this.hideEditButton = false,
    super.key,
  });

  final Map<String, String> details;
  final Text? title;
  final Map<String, String>? circles;
  final Map<String, List<String>>? circleMemberships;
  final List<String>? Function(String label)? getDetailSharingSettings;
  final void Function(String label)? editCallback;
  final VoidCallback? addCallback;
  final void Function(String label)? deleteCallback;
  final bool hideLabel;
  final bool hideEditButton;

  @override
  Widget build(BuildContext context) => DetailsCard(
    title: title,
    children:
        <Widget>[
          ...(details.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
              .map((entry) {
                final (label, value) = (entry.key, entry.value);
                final circleNames =
                    (circles == null || getDetailSharingSettings == null)
                    ? null
                    : circles!.entries
                          .where(
                            (c) =>
                                getDetailSharingSettings!(
                                  label,
                                )?.contains(c.key) ??
                                false,
                          )
                          .map((c) => c.value)
                          .toList();

                final numSharedContacts =
                    (circles == null ||
                        getDetailSharingSettings == null ||
                        circleMemberships == null)
                    ? null
                    : circleMemberships!.values
                          .where(
                            (contactCircleIds) =>
                                contactCircleIds.toSet().intersectsWith(
                                  getDetailSharingSettings!(label)?.toSet() ??
                                      {},
                                ),
                          )
                          .length;

                return Dismissible(
                  key: Key('$title|$label'),
                  direction: (deleteCallback != null)
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  onDismissed: (deleteCallback != null)
                      ? (_) => deleteCallback!(label)
                      : null,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (editCallback == null)
                        ? null
                        : () => editCallback!(label),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!hideLabel)
                                  Text(
                                    label,
                                    textScaler: const TextScaler.linear(1.1),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                Text(
                                  value,
                                  textScaler: const TextScaler.linear(1.1),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: value.contains('\n') ? null : 1,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        height: value.contains('\n')
                                            ? 1.2
                                            : null,
                                      ),
                                ),
                                if (circleNames != null &&
                                    numSharedContacts != null)
                                  Text(
                                    textScaler: const TextScaler.linear(1.1),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    [
                                      context.loc.sharedWith.capitalize(),
                                      numSharedContacts.toString(),
                                      if (numSharedContacts != 1)
                                        context.loc.contacts
                                      else
                                        context.loc.contact,
                                    ].join(' '),
                                  ),
                                if (circleNames?.isNotEmpty ?? false)
                                  Text(
                                    textScaler: const TextScaler.linear(1.1),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    'Circles: ${circleNames!.join(', ')}',
                                  ),
                              ],
                            ),
                          ),
                          if (editCallback != null && !hideEditButton)
                            IconButton.filledTonal(
                              onPressed: () => editCallback!(label),
                              icon: const Icon(Icons.edit),
                              iconSize: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ].addBetween(const SizedBox(height: 8)) +
        [
          if (addCallback != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton.filled(
                // TODO(LGro): Using the title like this seems to brittle;
                //             Can we use the widget key hierarchically here?
                key: Key('addProfileDetail${title?.data}'),
                onPressed: addCallback,
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ],
  );
}
