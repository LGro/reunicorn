// Copyright 2024 - 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../data/models/coag_contact.dart';

part 'state.dart';
part 'cubit.g.dart';

class IntroductionsCubit extends Cubit<IntroductionsState> {
  IntroductionsCubit()
    : super(const IntroductionsState(IntroductionsStatus.initial));

  @override
  Future<void> close() {
    return super.close();
  }
}
