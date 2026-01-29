// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:veilid/veilid.dart';

import '../../data/models/community.dart';
import '../../data/repositories/community_dht.dart';
import '../../data/utils.dart';

part 'cubit.freezed.dart';
part 'cubit.g.dart';
part 'state.dart';

class CommunityManagementCubit extends Cubit<CommunityManagementState> {
  CommunityManagementCubit(this._communityDhtRepository)
    : super(const CommunityManagementState());

  final CommunityDhtRepository _communityDhtRepository;

  Future<void> createCommunity() async {
    emit(state.copyWith(isProcessing: true));
    try {
      final communitySecret = await generateRandomSharedSecretBest();
      emit(
        state.copyWith(
          community: ManagedCommunity(
            name: 'Awesome Community',
            communityUuid: Uuid().v4(),
            communitySecret: communitySecret,
          ),
          isProcessing: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isProcessing: false));
    }
  }

  void import(ManagedCommunity community) =>
      emit(state.copyWith(community: community));

  void updateCommunity(ManagedCommunity community) {
    emit(state.copyWith(community: community));
  }

  Future<void> addMembers(String commaSeparatedNames) async {
    emit(state.copyWith(isProcessing: true));
    final newMembersWithWriters = await Future.wait(
      commaSeparatedNames
          .split(',')
          .map((n) => n.trim())
          .where((n) => n.isNotEmpty)
          .map((n) async {
            final (recordKey, writer) = await _communityDhtRepository
                .createMemberRecord();
            final info = OrganizerProvidedMemberInfo(
              recordKey: recordKey,
              name: n,
            );
            return (info, writer);
          }),
    );
    // TODO(LGro): Handle failed member creation / report which missing
    // TODO(LGro): Enforce unique member names?
    final updatedCommunity = state.community?.copyWith(
      membersWithWriters:
          (state.community?.membersWithWriters
            ?..addAll(newMembersWithWriters)) ??
          [],
    );
    emit(state.copyWith(community: updatedCommunity, isProcessing: false));
  }

  Future<void> saveCommunity(ManagedCommunity community) async {
    emit(state.copyWith(isProcessing: true));
    final isSuccess = await _communityDhtRepository.updateManagedCommunityToDht(
      community,
    );
    // TODO(LGro): Report success/failed update status to user
    emit(state.copyWith(community: community, isProcessing: false));
  }

  void selectMember(int i) => emit(state.copyWith(iSelectedMember: i));
  void deselectMember() => emit(state.copyWith(iSelectedMember: null));
  Future<void> updateMember({
    required RecordKey memberRecordKey,
    required String name,
    required String comment,
  }) async {
    if (state.community == null) {
      return;
    }
    emit(state.copyWith(isProcessing: true));
    final updatedMembersWithWriters = state.community!.membersWithWriters
        .map(
          (mww) => (mww.$1.recordKey == memberRecordKey)
              ? (
                  mww.$1.copyWith(
                    name: name.trim(),
                    comment: (comment.trim().isEmpty) ? null : comment.trim(),
                  ),
                  mww.$2,
                )
              : mww,
        )
        .toList();
    final updatedCommunity = state.community!.copyWith(
      membersWithWriters: updatedMembersWithWriters,
    );
    await _communityDhtRepository.updateManagedCommunityToDht(updatedCommunity);
    emit(state.copyWith(community: updatedCommunity, isProcessing: false));
  }

  void deactivateMember() {}
  void removeMember() {}
}
