// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'cubit.dart';

enum ReceiveRequestStatus {
  handleCommunityInvite,
  handleDirectSharing,
  handleProfileLink,
  handleSharingOffer,
  qrcode,
  processing,
  success,
  communityInviteSuccess,
  malformedUrl,
}

extension ReceiveRequestStatusX on ReceiveRequestStatus {
  bool get isQrcode => this == ReceiveRequestStatus.qrcode;
  bool get isProcessing => this == ReceiveRequestStatus.processing;
  bool get isSuccess => this == ReceiveRequestStatus.success;
  bool get isCommunityInviteSuccess =>
      this == ReceiveRequestStatus.communityInviteSuccess;
  bool get isHandleDirectSharing =>
      this == ReceiveRequestStatus.handleDirectSharing;
  bool get isHandleProfileLink =>
      this == ReceiveRequestStatus.handleProfileLink;
  bool get isHandleSharingOffer =>
      this == ReceiveRequestStatus.handleSharingOffer;
  bool get isHandleCommunityInvite =>
      this == ReceiveRequestStatus.handleCommunityInvite;
  bool get isMalformedUrl => this == ReceiveRequestStatus.malformedUrl;
}

@JsonSerializable()
final class ReceiveRequestState extends Equatable {
  const ReceiveRequestState(this.status, {this.profile, this.fragment});

  factory ReceiveRequestState.fromJson(Map<String, dynamic> json) =>
      _$ReceiveRequestStateFromJson(json);

  final ReceiveRequestStatus status;
  final CoagContact? profile;
  final String? fragment;

  Map<String, dynamic> toJson() => _$ReceiveRequestStateToJson(this);

  ReceiveRequestState copyWith({
    ReceiveRequestStatus? status,
    CoagContact? profile,
    String? fragment,
  }) => ReceiveRequestState(
    status ?? this.status,
    profile: profile ?? this.profile,
    fragment: fragment ?? this.fragment,
  );

  @override
  List<Object?> get props => [status, profile, fragment];
}
