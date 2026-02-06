// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/community.dart';
import '../../data/models/profile_info.dart';
import '../../data/repositories/contact_dht.dart';
import '../../data/services/storage/base.dart';
import '../widgets/scan_qr_code.dart';
import 'cubit.dart';

// TODO: Move cubit initialization outside to parent scope (potentially leaving
// the BlocConsumer inside) instead of passing initial state here?
class ReceiveRequestPage extends StatelessWidget {
  const ReceiveRequestPage({super.key, this.initialState});

  final ReceiveRequestState? initialState;

  @override
  Widget build(BuildContext _) => BlocProvider(
    create: (context) => ReceiveRequestCubit(
      context.read<Storage<CoagContact>>(),
      context.read<Storage<ProfileInfo>>(),
      context.read<Storage<Community>>(),
      context.read<ContactDhtRepository>(),
      initialState: initialState,
    ),
    child: BlocConsumer<ReceiveRequestCubit, ReceiveRequestState>(
      listener: (context, state) async {
        if (state.status.isMalformedUrl) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invalid URL')));
          context.read<ReceiveRequestCubit>().scanQrCode();
        } else if (state.status.isSuccess && state.profile != null) {
          context.goNamed('contactDetails', extra: state.profile);
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case ReceiveRequestStatus.processing:
            return Scaffold(
              appBar: AppBar(
                title: const Text('Processing...'),
                actions: [
                  IconButton(
                    onPressed: context.read<ReceiveRequestCubit>().scanQrCode,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ],
              ),
              body: const Center(child: CircularProgressIndicator()),
            );

          case ReceiveRequestStatus.qrcode:
            return Scaffold(
              appBar: AppBar(title: const Text('Accept personal invite')),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    left: MediaQuery.sizeOf(context).width * 0.1,
                    right: MediaQuery.sizeOf(context).width * 0.1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO: Instructions / re-request access if denied previously
                      const Text('Scan QR code:'),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox.square(
                          dimension: MediaQuery.sizeOf(context).width * 0.8,
                          child: BarcodeScannerPageView(
                            onDetectCallback: context
                                .read<ReceiveRequestCubit>()
                                .qrCodeCaptured,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scan only QR codes that were specifically generated for you.',
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Or if you have copied an invite to your clipboard:',
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: context
                            .read<ReceiveRequestCubit>()
                            .pasteInvite,
                        child: const Text('Paste invite'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Only paste invites that were specifically generated for you.',
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );

          case ReceiveRequestStatus.communityInviteSuccess:
            return Center(
              child: Padding(
                padding: EdgeInsetsGeometry.all(16),
                child: Text(
                  'Welcome to this community. '
                  'You are going to receive introductions to other existing '
                  'and new community members soon. '
                  'Check the dashboard for pending introductions.',
                ),
              ),
            );

          case ReceiveRequestStatus.success:
          case ReceiveRequestStatus.handleCommunityInvite:
          case ReceiveRequestStatus.handleDirectSharing:
          case ReceiveRequestStatus.handleProfileLink:
          case ReceiveRequestStatus.malformedUrl:
          case ReceiveRequestStatus.handleSharingOffer:
            return const Center(child: CircularProgressIndicator());
        }
      },
    ),
  );
}
