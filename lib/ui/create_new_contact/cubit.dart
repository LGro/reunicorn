// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/services/storage/base.dart';

part 'cubit.g.dart';
part 'state.dart';

class CreateNewContactCubit extends Cubit<CreateNewContactState> {
  CreateNewContactCubit(this._contactStorage)
    : super(const CreateNewContactState());

  final Storage<CoagContact> _contactStorage;

  void updateName(String name) => emit(state.copyWith(name: name));

  Future<CoagContact> createContactForInvite(String name) async {
    final contact = await createContactForInvite(name);
    await _contactStorage.set(contact.coagContactId, contact);
    return contact;
  }
}
