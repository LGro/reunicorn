// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';

part 'state.dart';
part 'cubit.g.dart';

class SkelCubit extends Cubit<SkelState> {
  SkelCubit(this.contactsRepository)
      : super(const SkelState(SkelStatus.initial)) {
    _contactsSubscription =
        contactsRepository.getContactStream().listen((_) => emit(
              SkelState(
                SkelStatus.success,
                contacts: contactsRepository.getContacts(),
              ),
            ));

    emit(SkelState(
      SkelStatus.success,
      contacts: contactsRepository.getContacts(),
    ));
  }

  final ContactsRepository contactsRepository;
  late final StreamSubscription<String> _contactsSubscription;

  @override
  Future<void> close() {
    _contactsSubscription.cancel();
    return super.close();
  }
}
