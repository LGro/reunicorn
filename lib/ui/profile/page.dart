// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../data/models/circle.dart';
import '../../data/models/profile_info.dart';
import '../../data/services/storage/base.dart';
import '../utils.dart';
import 'cubit.dart';
import 'widgets/addresses.dart';
import 'widgets/emails.dart';
import 'widgets/events.dart';
import 'widgets/miscellaneous.dart';
import 'widgets/names.dart';
import 'widgets/organizations.dart';
import 'widgets/phones.dart';
import 'widgets/pictures.dart';
import 'widgets/profile_invite_link.dart';
import 'widgets/socials.dart';
import 'widgets/tags.dart';
import 'widgets/websites.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileCubit>(
    create: (context) => ProfileCubit(
      context.read<Storage<ProfileInfo>>(),
      context.read<Storage<Circle>>(),
    ),
    child: const ProfileView(),
  );
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // TODO: This is part of the example in the docs, but is it necessary?
    // Listen to media sharing coming from outside the app while the app is in the memory.
    // _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((files) {
    //   if (files.isNotEmpty) {
    //     final ics = File(files.first.path).readAsStringSync();
    //     if (context.mounted) {
    //       context.goNamed('importIcs', extra: ics);
    //     }
    //   }
    // }, onError: (err) {
    //   logDebug('getIntentDataStream error: $err');
    // });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) {
        final ics = File(files.first.path).readAsStringSync();
        if (context.mounted) {
          context.goNamed('importIcs', extra: ics);
        }
      }
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ProfileCubit, ProfileState>(
    listener: (context, state) {},
    builder: (context, state) => Scaffold(
      appBar: AppBar(title: Text(context.loc.profileHeadline)),
      body: (state.profileInfo == null)
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      // NAMES
                      ProfileNamesWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // PHONES
                      ProfilePhonesWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // E-MAILS
                      ProfileEmailsWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // ADDRESSES
                      ProfileAddressesWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.addressLocations,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // SOCIAL MEDIAS
                      ProfileSocialsWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // WEBSITES
                      ProfileWebsitesWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // ORGANIZATIONS
                      ProfileOrganizationsWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // EVENTS
                      ProfileEventsWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // MISC / CUSTOM FIELDS
                      ProfileMiscWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // TAGS
                      ProfileTagsWidget(
                        state.profileInfo!.details,
                        state.profileInfo!.sharingSettings,
                        state.circles,
                        state.circleMemberships,
                      ),
                      // PICTURES / AVATARS
                      CirclesWithAvatarWidget(
                        pictures: state.profileInfo!.pictures.map(
                          (k, v) => MapEntry(k, Uint8List.fromList(v)),
                        ),
                        title: Text(
                          context.loc.pictures.capitalize(),
                          textScaler: const TextScaler.linear(1.4),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        // TODO: We dont need avatar sharing settings anymore at all, do we?
                        //  profileSharingSettings.avatars,
                        circles: state.circles,
                        circleMemberCount: Map.fromEntries(
                          state.circles.keys.map(
                            (circleId) => MapEntry(
                              circleId,
                              state.circleMemberships.values
                                  .where((ids) => ids.contains(circleId))
                                  .length,
                            ),
                          ),
                        ),
                        editCallback: (circleId, picture) => context
                            .read<ProfileCubit>()
                            .updateAvatar(circleId, picture),
                        deleteCallback: context
                            .read<ProfileCubit>()
                            .removeAvatar,
                      ),

                      // TODO: Do one of these per name and include the name? or allow customizing the name?
                      // TODO: Also feature this as an option on the create invite page?
                      if (state.profileInfo?.mainKeyPair?.key != null)
                        ProfileInviteLinkWidget(
                          name:
                              state
                                  .profileInfo!
                                  .details
                                  .names
                                  .values
                                  .firstOrNull ??
                              '???',
                          profilePubKey: state.profileInfo!.mainKeyPair!.key,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    ),
  );
}
