// Copyright 2025 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'utils.dart';

class _TextWithLink extends StatelessWidget {
  const _TextWithLink(this._text, this._url, [this._trailingFullStop = false]);
  final String _text;
  final String _url;
  final bool _trailingFullStop;

  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      text: _text,
      style: DefaultTextStyle.of(context).style,
      children: [
        TextSpan(
          text: _url,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer(
            preAcceptSlopTolerance: 4,
            postAcceptSlopTolerance: 4,
          )..onTap = () => launchUrl(_url),
        ),
        if (_trailingFullStop) const TextSpan(text: '.'),
      ],
    ),
  );
}

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy Policy')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          const Text(
            'The protection and security of your personal data is important to '
            'us. This privacy policy explains how we process your data when '
            'you use our Reunicorn app, what rights you have in this regard, '
            'and how you can exercise these rights.',
          ),
          headline('1.', 'Controller and contact details'),
          const Text(
            'The entity responsible for data processing on our app is:\n'
            'WTF Kooperative eG\nForsmannstr. 14 b\n22303 Hamburg',
          ),
          headline('2.', 'Processing in Connection With Our app'),
          const Text(
            'Reunicorn is a decentralized and end-to-end encrypted '
            'application. This means that your personal data is not stored on '
            'central servers, but exclusively locally on your device and '
            'encrypted for contacts and, if applicable, other persons within '
            'the network.\n'
            'We only process data when it is technically necessary.',
          ),
          headline('2.1', 'Provision of the App'),
          firstBoldThenNormal(
            'Purposes: ',
            "In order for you to use the app's features, the data is "
                'transmitted in encrypted form via the Veilid peer-to-peer '
                'network. This ensures particularly data protection-friendly '
                'operation without a central server.',
          ),
          const Text(
            'To ensure that information shared with your contacts is available '
            'even when the sender and recipient are not online at the same '
            'time, this encrypted data may be temporarily stored on the '
            'devices of other people participating in the Veilid network. We '
            'do not have access to this data at any time.',
          ),
          firstBoldThenNormal(
            'Categories of Data: ',
            'Profile and location data, if you actively share it, is stored in '
                'encrypted form on the network. In addition, technically '
                'necessary metadata is processed.',
          ),
          firstBoldThenNormal(
            'Recipients:\n',
            '• People participating in the Veilid network\n'
                '• Operators of DNS servers that support initial peering',
          ),
          firstBoldThenNormal(
            'Legal Basis: ',
            'Art. 6 (1) (b) GDPR (contract or pre-contractual measures).',
          ),
          firstBoldThenNormal(
            'Storage Period: ',
            'The data is stored locally on your device until you delete it and '
                'decentralized in the Veilid network.',
          ),
          headline('2.2', 'Using the App'),
          firstBoldThenNormal(
            'Purposes: ',
            'Certain information is automatically processed as soon as the app '
                'is used. When you download the app, certain necessary '
                'information is transmitted to the app store you have '
                'selected.',
          ),
          firstBoldThenNormal(
            'Categories of Data: ',
            'In particular, your username, email address, customer number, '
                'time of download, payment information, and individual device '
                'identification number may be processed. This data is '
                'processed exclusively by the respective app store and is '
                'beyond our control.',
          ),
          firstBoldThenNormal('Recipients', ''),
          const _TextWithLink(
            '• Apple Distribution International Ltd., Hollyhill Industrial '
                'Estate, Hollyhill, Cork, Ireland. Privacy policy: ',
            'https://www.apple.com/de/legal/privacy/de-ww/',
          ),
          const _TextWithLink(
            '• Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, '
                'Ireland. Privacy policy: ',
            'https://policies.google.com/privacy?hl=de&gl=de',
          ),
          const _TextWithLink(
            '• The Commons Conservancy, Science Park 400, 1098 XH, Amsterdam, '
                'The Netherlands. Privacy policy: ',
            'https://f-droid.org/de/2024/03/08/privacy-design-of-fdroid.org-webservers.html',
          ),
          firstBoldThenNormal(
            'Legal Basis: ',
            'Art. 6(1)(b) GDPR (contract or pre-contractual measures).',
          ),
          firstBoldThenNormal(
            'Storage Period: ',
            'We do not store any personal data.',
          ),
          headline('2.3', 'Location Sharing, Map Functions, and Geocoding'),
          firstBoldThenNormal(
            'Purposes: ',
            'We use the services of MapTiler AG for the map and address '
                'function. Location data is only shared with your contacts if '
                'you activate this feature.',
          ),
          firstBoldThenNormal(
            'Categories of Data: ',
            'Current or planned locations, technical usage data when accessing '
                'maps and searching for addresses.',
          ),
          firstBoldThenNormal('Recipients', ''),
          const _TextWithLink(
            '• MapTiler AG, Switzerland. Zugerstrasse 22, 6314 Unterägeri, '
                'Switzerland. Privacy policy: ',
            'https://www.maptiler.com/privacy-policy/',
            true,
          ),
          firstBoldThenNormal(
            'Legal Basis: ',
            'Art. 6 para. 1 lit. b GDPR (contract or pre-contractual '
                'measures).',
          ),
          firstBoldThenNormal(
            'Storage Period: ',
            'We do not store any personal data.',
          ),
          headline('2.4', 'Push Notifications'),
          firstBoldThenNormal(
            'Purposes: ',
            'You can optionally receive push notifications. In order to use '
                'push notifications, a consistent token is generated after '
                'consent is given, which is transmitted to the WTF server '
                'without disclosing your IP address or other user details and '
                'is used to send push notifications to your device.',
          ),
          firstBoldThenNormal(
            'Categories of Data: ',
            'The token identifying the device.',
          ),
          firstBoldThenNormal('Recipients', ''),
          const _TextWithLink(
            '• Apple Distribution International Ltd., Hollyhill Industrial '
                'Estate, Hollyhill, Cork Ireland. Privacy policy: ',
            'https://www.apple.com/de/legal/privacy/de-ww/',
          ),
          const _TextWithLink(
            '• Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, '
                'Ireland. Privacy policy: ',
            'https://policies.google.com/privacy?hl=de&gl=de',
          ),
          firstBoldThenNormal('Legal Basis: ', 'Consent (Art. 6 (1) (a) GDPR)'),
          firstBoldThenNormal(
            'Storage Period: ',
            'We do not store any personal data.',
          ),
          headline('2.5', 'In-App Purchases'),
          firstBoldThenNormal(
            'Purposes: ',
            'Payment processing may be carried out via app store operators in '
                'order to activate additional functions.',
          ),
          firstBoldThenNormal(
            'Categories of Data: ',
            'Transaction and payment data, without us having access to payment '
                'details.',
          ),
          firstBoldThenNormal('Recipients:', ''),
          const _TextWithLink(
            '• Apple Distribution International Ltd., Hollyhill Industrial '
                'Estate, Hollyhill, Cork Ireland. Privacy policy: ',
            'https://www.apple.com/de/legal/privacy/de-ww/',
          ),
          const _TextWithLink(
            '• Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, '
                'Ireland. Privacy policy: ',
            'https://policies.google.com/privacy?hl=de&gl=de',
            true,
          ),
          firstBoldThenNormal('Legal Basis: ', 'Art. 6 para. 1 lit. b GDPR.'),
          firstBoldThenNormal(
            'Storage Period: ',
            'We do not store any personal data.',
          ),
          headline('2.6', 'App Permissions'),
          firstBoldThenNormal(
            'Purposes: ',
            'In order to provide its functions, the app requires access to '
                'certain data. Some of this data is necessary for the use of '
                'the app, while other data is optional. Access is required for '
                'the following purposes:',
          ),
          firstBoldThenNormal(
            '• Internet access: ',
            'This is required to enable you to connect with other '
                'participants.',
          ),
          firstBoldThenNormal(
            '• Camera access (optional): ',
            'This enables QR codes to be scanned.',
          ),
          firstBoldThenNormal(
            '• Location access (optional): ',
            'This is required if the current location is to be shared with a '
                'contact.',
          ),
          firstBoldThenNormal(
            '• Background location access (optional): ',
            'This is required if the current location is to be shared over a '
                'period of time.',
          ),
          firstBoldThenNormal(
            '• Contact access (optional): ',
            'This is required to update contacts from the phone book in the '
                'app. The contact data is stored locally in the app.',
          ),
          firstBoldThenNormal(
            '• Storage (optional): ',
            'Images can be uploaded from your device as profile pictures in '
                'the app and shared with contacts there.',
          ),
          firstBoldThenNormal(
            '• Calendar access (optional): ',
            'Calendar entries can be loaded into the app to share them as '
                'temporary locations with contacts. Temporary locations can be '
                'entered from the app into the calendar on your device as '
                'appointments.',
          ),
          firstBoldThenNormal(
            'Categories of data: ',
            'The permissions set are stored locally on your device. You can '
                'change them at any time in your device settings.',
          ),
          firstBoldThenNormal(
            'Legal Basis: ',
            'The legal basis here is Section 25 (2) No. 2 TDDDG. Device access '
                'is access that is necessary for the provision of the '
                'respective function.',
          ),
          firstBoldThenNormal(
            'Storage Period: ',
            'We do not store any personal data.',
          ),
          headline('2.7', 'Contact'),
          firstBoldThenNormal(
            'Purposes: ',
            'When you contact us by email, the information you provide us with '
                'is processed to the extent necessary to respond to the '
                'inquiry and any requested measures.',
          ),
          firstBoldThenNormal(
            'Categories of Data: ',
            'Identifying data (e.g., names), contact data (e.g., email), '
                'content data (e.g., entries in online forms).',
          ),
          firstBoldThenNormal(
            'Recipients: ',
            'Hetzner Online GmbH, Industriestr. 25, 91710 Gunzenhausen',
          ),
          firstBoldThenNormal(
            'Legal Basis: ',
            'Contract fulfillment and pre-contractual inquiries (Art. 6 (1) '
                '(b) GDPR) or legitimate interest in effectively responding to '
                'inquiries (Art. 6 (1) (f) GDPR).',
          ),
          firstBoldThenNormal(
            'Storage Period: ',
            'Contract fulfillment and pre-contractual inquiries (Art. 6 (1) '
                '(b) GDPR) or legitimate interest in effectively responding to '
                'inquiries (Art. 6 (1) (f) GDPR).',
          ),
          headline(
            '3.',
            'We have profiles on social networks. Our social media profiles '
                'complement our website and offer you the opportunity to '
                'interact with us. As soon as you access our social media '
                'profiles on social networks, the terms and conditions and '
                'data processing guidelines of the respective operators apply. '
                'The data collected about you when using the services is '
                'processed by the networks and, if necessary, also transferred '
                'to countries outside the European Union where there is no '
                'adequate level of protection for the processing of personal '
                'data. We have no influence on data processing in social '
                'networks, as we are users of the network just like you. '
                'Information on this and on which data is processed by the '
                'social networks and for what purposes the data is used can be '
                'found in the privacy policy of the respective network listed '
                'below. We use the following social networks:',
          ),
          headline('3.1', 'Mastodon'),
          const _TextWithLink(
            'Our page is available at: ',
            'https://floss.social/@reunicorn',
          ),
          const Text('Our instance is operated by floss.social.'),
          const _TextWithLink(
            'The privacy policy of the instance is available at: ',
            'https://floss.social/privacy-policy',
          ),
          firstBoldThenNormal(
            'Purposes: ',
            'We process personal data as a controller when you send us '
                'inquiries via social media profiles. We process this data in '
                'order to respond to your inquiries.',
          ),
          firstBoldThenNormal(
            'Legal Basis: ',
            'The processing is based on our legitimate interest (Art. 6 (1) '
                '(f) GDPR). The interest lies in the respective purpose.',
          ),
          firstBoldThenNormal(
            'Storage Period: ',
            'We do not store any personal data outside the network.',
          ),
          headline('4.', 'General Information about Recipients'),
          const _TextWithLink(
            'When we process your data, it may be necessary to transfer or '
                'disclose your data to other recipients. In the sections on '
                'processing above, we name the specific recipients as far as '
                'we can. If recipients are located in a country outside the '
                'EU, we indicate this separately under the individual points '
                'listed above. Unless we expressly refer to an adequacy '
                'decision, no adequacy decision exists for the respective '
                'recipient country. In these cases, we will agree on '
                'appropriate safeguards in the form of standard contractual '
                'clauses to ensure an adequate level of data protection '
                '(unless other appropriate safeguards, such as binding '
                'corporate rules, are in place). You can access the current '
                'versions of the standard contractual clauses at ',
            'https://eur-lex.europa.eu/eli/dec_impl/2021/914/oj',
            true,
          ),
          const Text(
            'In addition to these specific recipients, data may also be '
            'transferred to other categories of recipients. These may be '
            'internal recipients, i.e., persons within our company, but also '
            'external recipients. Possible recipients may include, in '
            'particular:\n'
            '• Our employees who are responsible for processing and storing '
            'the data and whose employment relationship with us is governed by '
            'a confidentiality obligation.\n'
            '• Service providers who act as processors bound by our '
            'instructions. These are primarily technical service providers '
            'whose services we use when we cannot provide certain services '
            'ourselves or when it is not reasonable for us to do so.',
          ),
          headline('5.', 'General Information on the Storage Period'),
          const Text(
            'You can delete your locally stored data at any time via the app '
            'or the settings in your operating system. Due to the '
            'decentralized design, we cannot guarantee the deletion of your '
            "data on your contacts' devices.",
          ),
          headline(
            '6.',
            'Automated Decision-Making and Obligation to Provide Data',
          ),
          const Text(
            'We do not use automated decision-making that has a legal effect '
            'on you or similarly significantly affects you.',
          ),
          headline('7.', 'Data Subjects Rights'),
          firstBoldThenNormal(
            '• Art. 15 GDPR - Right of Access: ',
            'You have the right to obtain from us confirmation as to whether '
                'personal data concerning you is being processed, and, where '
                'that is the case, access the personal data and the '
                'circumstances surrounding the processing.',
          ),
          firstBoldThenNormal(
            '• Art. 16 GDPR - Right to Rectification: ',
            'You have the right to request that we correct inaccurate personal '
                'data concerning you without delay. Taking into account the '
                'purposes of the processing, you also have the right to '
                'request that incomplete personal data be completed, including '
                'by means of a supplementary statement.',
          ),
          firstBoldThenNormal(
            '• Art. 17 GDPR - Right to Erasure: ',
            'You have the right to request that we erase personal data '
                'concerning you without undue delay.',
          ),
          firstBoldThenNormal(
            '• Art. 18 GDPR - Right to Restriction of Processing: ',
            'You have the right to request that we restrict processing.',
          ),
          firstBoldThenNormal(
            '• Art. 20 GDPR - Right to Data Portability: ',
            'In the event of processing based on consent or for the '
                'performance of a contract, you have the right to receive the '
                'personal data concerning you that you have provided to us in '
                'a structured, commonly used, and machine-readable format and '
                'to transmit those data to another controller without '
                'hindrance from us or to have the data transmitted directly to '
                'the other controller, where technically feasible.',
          ),
          firstBoldThenNormal(
            '• Art. 77 GDPR in conjunction with § 19 BDSG - Right to Lodge a '
                'Complaint with a Supervisory Authority: ',
            'You have the right to lodge a complaint with a supervisory '
                'authority, in particular in the Member State of your habitual '
                'residence, place of work, or place of the alleged '
                'infringement, if you consider that the processing of personal '
                'data concerning you infringes applicable law.',
          ),
          headline(
            '8.',
            'In particular, Right to Object and Withdrawal of Consent',
          ),
          firstBoldThenNormal(
            '• Art. 21 GDPR - Right to Object: ',
            'You have the right to object at any time, on grounds relating to '
                'your particular situation, to the processing of personal data '
                'concerning you which is necessary for the purposes of our '
                'legitimate interests or for the performance of a task carried '
                'out in the public interest or in the exercise of official '
                'authority.\n'
                'If you object, we will no longer process your personal data '
                'unless we can demonstrate compelling legitimate grounds for '
                'the processing that override your interests, rights, and '
                'freedoms, or the processing serves to assert, exercise, or '
                'defend legal claims.\n'
                'If we process your personal data for direct marketing '
                'purposes, you have the right to object to the processing at '
                'any time. If you object to processing for direct marketing '
                'purposes, we will no longer process your personal data for '
                'these purposes.\n'
                'You can raise your objection at any time with future effect '
                'via one of the contact addresses known to you.',
          ),
          firstBoldThenNormal(
            '• Withdrawal of Consent: ',
            'You can revoke your consent at any time with future effect via '
                'one of the contact addresses known to you.',
          ),

          headline('9.', 'Obligation to Provide Data'),
          const Text(
            'You have no contractual or legal obligation to provide us with '
            'personal data. However, without the data you provide, we are '
            'unable to offer you our services.',
          ),
          headline('10.', 'No Cookies'),
          const Text(
            'The app does not use cookies or similar tracking mechanisms.',
          ),
          headline('11.', 'Comments or Questions'),
          const Text(
            'We take every conceivable precaution to protect and secure your '
            'data. We welcome your questions and comments about data '
            'protection. If you have any questions about the collection, '
            'processing, or use of your personal data, or if you wish to '
            'request information, correction, blocking, or deletion of data, '
            'or withdraw consent you have given, please contact us using the '
            'contact details provided above.',
          ),
          headline('', 'December 2025'),
        ],
      ),
    ),
  );
}
