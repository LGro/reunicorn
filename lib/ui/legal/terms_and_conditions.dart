// Copyright 2025 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import 'utils.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Terms and Conditions for the Use of the Reunicorn App',
        overflow: TextOverflow.visible,
        softWrap: true,
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          headline('', 'Preamble'),
          const Text(
            'These General Terms and Conditions ("Terms") govern the use of '
            'the mobile application "Reunicorn" (hereinafter referred to as '
            '"App") by natural persons (hereinafter referred to as "Users"). '
            'The operator of the App is WTF Kooperative eG, Forsmannstr. 14 b, '
            '22303 Hamburg (hereinafter referred to as "We" or "Provider"). ',
          ),
          const Text(
            'The subject matter of these Terms is the provision and use of the '
            'App, which enables contact and location data to be shared with '
            'existing contacts. The App operates decentralized via the Veilid '
            'network.',
          ),
          headline('1', 'Conclusion of Contract'),
          firstBoldThenNormal(
            '1.1',
            'The contract is concluded when the App is opened for the first '
                'time. By providing the App, we submit an offer to all Users '
                'to conclude a user agreement via the App, including these '
                // TODO(Gro): Reuse text placeholder of the actual button
                "Terms. By starting the App and clicking on Let's connect, "
                'Users accept this offer and the contract is concluded.',
          ),
          firstBoldThenNormal(
            '1.2',
            // TODO(Gro): Do we need to link to the German version here?
            'Users can view the current version of these Terms in the App at '
                'any time. The contract is concluded in German and the Terms '
                'are available in German and for convenience as a translation '
                'in English. In case of conflicts between the German Terms and '
                'the English translation, the German version prevails.',
          ),
          headline('2', 'Use of the App'),
          firstBoldThenNormal(
            '2.1',
            'The App is licensed under the Mozilla Public License Version 2.0. '
                'All Users may use the App within the scope of the rights of '
                'use granted therein. This contract does not establish any '
                'further or other rights and obligations with regard to the '
                'copyright or patent rights of use of the App.',
          ),
          firstBoldThenNormal(
            '2.2',
            'Users may use the App without registering a user account.',
          ),
          firstBoldThenNormal(
            '2.3',
            'The core function of the basic version is to share contact and '
                'location data and to retrieve the location data of contacts. '
                'The number of contacts in the basic version may be limited.',
          ),
          firstBoldThenNormal(
            '2.4',
            'We provide all Users with a free basic version that allows them '
                'to use the core functions of the App. However, the number of '
                'possible linked contacts is limited in the free basic '
                'version.',
          ),
          firstBoldThenNormal(
            '2.5',
            'In addition, we offer a premium version. In the premium version, '
                'the restriction on linked contacts is lifted.',
          ),
          firstBoldThenNormal(
            '2.6',
            'The premium version can be purchased via in-app purchase on the '
                'respective platform. In this case the contract is concluded '
                'and payment is made via the respective app store operator, '
                'and additional terms and conditions may apply to the '
                'purchase. In particular these can be in the case of a '
                'purchase from the Apple App Store the Apple Media Services '
                'Terms and Conditions and in the case of the Google Play Store '
                'the Google Play Terms of Service. ',
          ),
          firstBoldThenNormal(
            '2.7',
            'The Premium Version may also be made available to you through an '
                'organization (e.g., if you participate in an event). In '
                'addition, we may offer you the Premium Version through other '
                'channels (e.g. via our own website). In this case, you will '
                'be informed about the conclusion of the contract separately.',
          ),
          firstBoldThenNormal(
            '2.8',
            'We reserve the right to add, remove, or change features in the '
                'future. Users will be informed of any changes in a timely '
                'manner.',
          ),
          headline('3', 'Obligations of the User'),
          const Text(
            'When using the App, Users are obliged to refrain from any actions '
            'that go beyond the intended use of the App. In particular, Users '
            'are obliged not to use the App in any way that could jeopardize '
            'the secure operation of our systems or third-party systems.',
          ),
          headline('4', 'Availability'),
          firstBoldThenNormal(
            '4.1',
            'We take reasonable and appropriate measures to ensure the '
                'availability and error-free functionality of the App. '
                'However, Users acknowledge that we cannot guarantee this for '
                'technical reasons and due to dependence on external '
                'influences.',
          ),
          firstBoldThenNormal(
            '4.2',
            'In particular, the transmission and updating of data depends on '
                'the availability of the Veilid network and the accessibility '
                'of the respective contacts and therefore cannot be '
                'guaranteed.',
          ),
          firstBoldThenNormal(
            '4.3',
            'Map content, address search, and geocoding are partly provided by '
                'external services. Their availability may therefore depend on '
                'the accessibility of these services. We do not guarantee the '
                'availability or accuracy of such content.',
          ),
          headline('5', 'Data Protection'),
          const Text(
            'Information about how we process personal data can be found in'
            ' our privacy policy.',
          ),
          headline('6', 'Liability and  Warranty'),
          firstBoldThenNormal(
            '6.1',
            'For the free basic version of the App, the statutory provisions '
                'governing Donations apply (including liability for material '
                'defects and defects of title).',
          ),
          firstBoldThenNormal(
            '6.2',
            'If you purchased the premium version via an app store, you may '
                'find information on whether and to what extent you are '
                'entitled to warranty rights in the terms and conditions or '
                'consumer information provided by the app store operator. ',
          ),
          headline('7', 'Final Provisions'),
          firstBoldThenNormal(
            '7.1',
            'This agreement is governed by the laws of the Federal Republic of '
                'Germany and shall be interpreted accordingly, excluding the '
                'provisions of the United Nations Convention on Contracts for '
                'the International Sale of Goods.',
          ),
          firstBoldThenNormal(
            '7.2',
            'If the Users are not consumers, the exclusive place of '
                'jurisdiction for all disputes or claims arising from or in '
                'connection with this agreement is Hamburg, Germany.',
          ),
          firstBoldThenNormal(
            '7.3',
            'Should any provision of this agreement be wholly or partially '
                'invalid or unenforceable, this shall not affect the validity '
                'and enforceability of the remaining provisions of this '
                'agreement. The invalid or unenforceable provision shall be '
                'deemed replaced by a valid and enforceable provision that '
                'comes as close as possible to the economic purpose pursued by '
                'both parties with the invalid or unenforceable provision.',
          ),
          headline('', 'December 2025'),
        ],
      ),
    ),
  );
}
