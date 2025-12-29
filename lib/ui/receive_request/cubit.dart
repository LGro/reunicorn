// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:loggy/loggy.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:veilid_support/veilid_support.dart';

import '../../data/models/coag_contact.dart';
import '../../data/models/community.dart';
import '../../data/models/profile_info.dart';
import '../../data/services/storage/base.dart';
import '../../data/utils.dart';
import 'utils/direct_sharing.dart';
import 'utils/profile_based.dart';

part 'cubit.g.dart';
part 'state.dart';

// TODO: Split out community requests and potentially other request types
class ReceiveRequestCubit extends Cubit<ReceiveRequestState> {
  ReceiveRequestCubit(
    this._contactStorage,
    this._profileStorage,
    this._communityStorage, {
    ReceiveRequestState? initialState,
  }) : super(
         initialState ?? const ReceiveRequestState(ReceiveRequestStatus.qrcode),
       ) {
    if (initialState == null) {
      return;
    }
    if (initialState.status.isHandleDirectSharing) {
      unawaited(handleDirectSharing(initialState.fragment ?? ''));
    }
    if (initialState.status.isHandleProfileLink) {
      unawaited(handleProfileLink(initialState.fragment ?? ''));
    }
    if (initialState.status.isHandleSharingOffer) {
      unawaited(handleSharingOffer(initialState.fragment ?? ''));
    }
  }

  final Storage<CoagContact> _contactStorage;
  final Storage<ProfileInfo> _profileStorage;
  final Storage<Community> _communityStorage;

  Future<void> pasteInvite() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
      try {
        final url = Uri.parse(clipboardData!.text!.trim());
        // Deal with /c/ and /c variants of paths
        final path = url.path.split('/').where((p) => p.isNotEmpty).toList();
        if (path.length != 1) {
          // TODO: Signal faulty URL
          emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          return;
        }
        if (path.first == 'c') {
          return handleDirectSharing(url.fragment);
        }
        if (path.first == 'p') {
          return handleProfileLink(url.fragment);
        }
        if (path.first == 'o') {
          return handleSharingOffer(url.fragment);
        }
        if (path.first == 'b') {
          return emit(
            state.copyWith(
              status: ReceiveRequestStatus.handleBatchInvite,
              fragment: url.fragment,
            ),
          );
        }
      } on FormatException {
        // TODO: signal back faulty URL
      }
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
    }
  }

  void scanQrCode() =>
      emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));

  Future<void> qrCodeCaptured(BarcodeCapture capture) async {
    // Avoid duplicate calls, which apparently happen from the qr detect
    // callback and cause creation of multiple (e.g. 2) contacts
    if (state.status.isProcessing) {
      return;
    }
    emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue?.startsWith('https://reunicorn.app') ?? false) {
        final uri = barcode.rawValue!;

        // TODO: Handle malformed Uri, parser error
        final url = Uri.parse(uri);
        if (url.fragment.isEmpty) {
          // TODO: Log / feedback?
          logDebug('Payload is empty');
          if (!isClosed) {
            emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
          }
          continue;
        }
        final path = url.path.split('/').where((p) => p.isNotEmpty).toList();
        if (path.length != 1) {
          // TODO: Signal faulty URL or just skip?
          continue;
        }
        if (path.first == 'c') {
          return handleDirectSharing(url.fragment);
        }
        if (path.first == 'p') {
          return handleProfileLink(url.fragment);
        }
        if (path.first == 'o') {
          return handleSharingOffer(url.fragment);
        }
        if (path.first == 'b') {
          return emit(
            state.copyWith(
              status: ReceiveRequestStatus.handleBatchInvite,
              fragment: url.fragment,
            ),
          );
        }
      }
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
    }
  }

  Future<void> handleDirectSharing(String fragment) async {
    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
    }

    final contact = await createContactFromDirectSharing(
      fragment,
      _contactStorage,
    );

    if (!isClosed) {
      return emit(
        state.copyWith(
          status: (contact == null)
              ? ReceiveRequestStatus.qrcode
              : ReceiveRequestStatus.success,
          profile: contact,
        ),
      );
    }
  }

  // TODO: Does it make sense to check first if we already know this pubkey?
  // TODO: Allow option to match with existing contact?
  // name~publicKey
  Future<void> handleProfileLink(String fragment) async {
    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
    }

    final parts = fragment.split('~');
    if (parts.length < 2) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }
    // TODO: Handle fromString parsing errors
    final publicKey = PublicKey.fromString(parts.removeLast());
    // Allow use of ~ in name
    final name = Uri.decodeComponent(parts.join('~'));

    final profileInfo = await getProfileInfo(_profileStorage);
    if (profileInfo?.mainKeyPair?.key.toString() == publicKey.toString()) {
      // TODO: Display "this is you, share it with others, it'll be great" msg
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    // TODO: Check if contact already exists - key generation can take a moment and this can cause duplicate entries if people resubmit
    final contact = await createContactForInvite(name, pubKey: publicKey);
    await _contactStorage.set(contact.coagContactId, contact);

    if (!isClosed) {
      return emit(
        state.copyWith(status: ReceiveRequestStatus.success, profile: contact),
      );
    }
  }

  Future<void> handleSharingOffer(String fragment) async {
    if (!isClosed) {
      emit(const ReceiveRequestState(ReceiveRequestStatus.processing));
    }

    final profileInfo = await getProfileInfo(_profileStorage);
    if (profileInfo?.mainKeyPair == null) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    final contact = await createContactFromProfileInvite(
      fragment,
      profileInfo!.mainKeyPair!,
      _contactStorage,
    );

    if (!isClosed) {
      return emit(
        state.copyWith(
          status: (contact == null)
              ? ReceiveRequestStatus.qrcode
              : ReceiveRequestStatus.success,
          profile: contact,
        ),
      );
    }
  }

  // recordKey~writer
  Future<void> handleBatchInvite() async {
    if (state.fragment == null) {
      // TODO: Emit error
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    final parts = state.fragment!.split('~');
    if (parts.length != 2) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }
    if (!isClosed) {
      emit(state.copyWith(status: ReceiveRequestStatus.processing));
    }

    // TODO: Handle parsing errors
    late RecordKey recordKey;
    late KeyPair writer;
    try {
      writer = KeyPair.fromString(parts.removeLast());
      recordKey = RecordKey.fromString(parts.removeLast());
    } catch (e) {
      // TODO: Emit error notice
      if (!isClosed) {
        emit(const ReceiveRequestState(ReceiveRequestStatus.qrcode));
      }
      return;
    }

    final community = Community(
      recordKey: recordKey,
      recordWriter: writer,
      members: [],
      mostRecentUpdate: DateTime.now(),
    );
    await _communityStorage.set(community.recordKey.toString(), community);

    if (!isClosed) {
      emit(state.copyWith(status: ReceiveRequestStatus.batchInviteSuccess));
    }
  }
}
