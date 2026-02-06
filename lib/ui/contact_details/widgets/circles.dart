// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/circle.dart';
import '../../../data/services/storage/base.dart';
import '../../widgets/circles/cubit.dart';
import '../../widgets/circles/widget.dart';

class CirclesCard extends StatelessWidget {
  const CirclesCard(this.coagContactId, this.circleNames, {super.key});

  final String coagContactId;
  final List<String> circleNames;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 4),
        child: Row(
          children: [
            Icon(Icons.bubble_chart_outlined),
            SizedBox(width: 4),
            Text('Circle memberships', textScaler: TextScaler.linear(1.2)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: Card(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: 12,
                  ),
                  child: (circleNames.isEmpty)
                      ? const Text(
                          'Add them to circles to start sharing.',
                          textScaler: TextScaler.linear(1.2),
                        )
                      : Text(
                          (circleNames..sort()).join(', '),
                          textScaler: const TextScaler.linear(1.2),
                        ),
                ),
              ),
              BlocProvider(
                create: (context) => CirclesCubit(
                  context.read<Storage<Circle>>(),
                  coagContactId,
                ),
                child: BlocConsumer<CirclesCubit, CirclesState>(
                  listener: (context, state) {},
                  builder: (context, state) => IconButton(
                    key: const Key('editCircleMembership'),
                    icon: const Icon(Icons.edit),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (modalContext) => DraggableScrollableSheet(
                        expand: false,
                        maxChildSize: 0.90,
                        builder: (_, scrollController) => SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(
                                modalContext,
                              ).viewInsets.bottom,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CirclesForm(
                                  circles: state.circles,
                                  callback: context.read<CirclesCubit>().update,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: 8),
        child: Text(
          'The selected circles determine which of your contact details '
          'and locations they can see.',
        ),
      ),
    ],
  );
}
