// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../data/models/coag_contact.dart';
import '../../../data/repositories/contacts.dart';

part 'state.dart';
part 'cubit.g.dart';

class IntroductionsCubit extends Cubit<IntroductionsState> {
  IntroductionsCubit(this.contactsRepository)
      : super(const IntroductionsState(IntroductionsStatus.initial)) {
    _contactsSubscription =
        contactsRepository.getContactStream().listen((_) => emit(
              IntroductionsState(
                IntroductionsStatus.success,
                contacts: contactsRepository.getContacts().values.toList(),
              ),
            ));

    emit(IntroductionsState(
      IntroductionsStatus.success,
      contacts: contactsRepository.getContacts().values.toList(),
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
