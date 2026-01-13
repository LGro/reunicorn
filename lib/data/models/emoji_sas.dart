// Copyright 2024 - 2026 The Reunicorn Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:veilid/veilid.dart';

// Their next or their current public key?
Future<HashDigest> sharedSecretVerificationHash(
  KeyPair myKeyPair,
  PublicKey theirPublicKey,
) => Veilid.instance.getCryptoSystem(myKeyPair.kind).then((cs) async {
  final secret = await cs.generateSharedSecret(
    theirPublicKey,
    myKeyPair.secret,
    utf8.encode('verify'),
  );
  final hash = await cs.generateHash(utf8.encode(secret.toString()));
  return hash;
});

// Inspired by https://spec.matrix.org/latest/client-server-api/#sas-method-emoji
/// Return the seven 6-bit indices (0..63) from the first 42 bits of [hash].
List<int> sasEmojiIndicesFromHash(HashDigest hash) {
  final hashBytes = hash.value.toBytes();
  if (hashBytes.length < 6) {
    throw ArgumentError('Need at least 6 bytes to extract 42 bits.');
  }

  // Combine the first 6 bytes into a 48-bit big-endian integer.
  var acc = 0;
  for (var i = 0; i < 6; i++) {
    acc = (acc << 8) | hashBytes[i];
  }

  // Keep only the top 42 bits (discard the lowest 6).
  final top42 = acc >> 6;

  // Split into 7 groups of 6 bits, most-significant group first.
  return List<int>.generate(
    7,
    (i) => (top42 >> ((6 - i) * 6)) & 0x3F,
    growable: false,
  );
}

/// Pick the 7 SAS emojis (from your 64-entry table) for the given [hash].
List<SasEmoji> sasEmojisFromHash(HashDigest hash) =>
    List<SasEmoji>.unmodifiable(
      sasEmojiIndicesFromHash(hash).map((i) => sasEmojiAlphabet[i]),
    );

class SasEmoji {
  const SasEmoji({
    required this.number,
    required this.emoji,
    required this.description,
    required this.unicode,
  });

  factory SasEmoji.fromJson(Map<String, dynamic> json) => SasEmoji(
    number: json['number'] as int,
    emoji: json['emoji'] as String,
    description: json['description'] as String,
    unicode: json['unicode'] as String,
  );

  /// 0..63
  final int number;

  /// the rendered emoji (e.g. "🐶")
  final String emoji;

  /// English name (e.g. "Dog")
  final String description;

  /// Codepoint string (e.g. "U+1F436" or "U+2601U+FE0F")
  final String unicode;

  Map<String, dynamic> toJson() => {
    'number': number,
    'emoji': emoji,
    'description': description,
    'unicode': unicode,
  };
}

// Inspired by https://github.com/matrix-org/matrix-spec/blob/main/data-definitions/sas-emoji.json
const sasEmojiAlphabet = <SasEmoji>[
  SasEmoji(number: 0, emoji: '🐶', description: 'Dog', unicode: 'U+1F436'),
  SasEmoji(number: 1, emoji: '🐱', description: 'Cat', unicode: 'U+1F431'),
  SasEmoji(number: 2, emoji: '🦁', description: 'Lion', unicode: 'U+1F981'),
  SasEmoji(number: 3, emoji: '🐎', description: 'Horse', unicode: 'U+1F40E'),
  SasEmoji(number: 4, emoji: '🦄', description: 'Unicorn', unicode: 'U+1F984'),
  SasEmoji(number: 5, emoji: '🐷', description: 'Pig', unicode: 'U+1F437'),
  SasEmoji(number: 6, emoji: '🐘', description: 'Elephant', unicode: 'U+1F418'),
  SasEmoji(number: 7, emoji: '🐰', description: 'Rabbit', unicode: 'U+1F430'),
  SasEmoji(number: 8, emoji: '🐼', description: 'Panda', unicode: 'U+1F43C'),
  SasEmoji(number: 9, emoji: '🐓', description: 'Rooster', unicode: 'U+1F413'),
  SasEmoji(number: 10, emoji: '🐧', description: 'Penguin', unicode: 'U+1F427'),
  SasEmoji(number: 11, emoji: '🐢', description: 'Turtle', unicode: 'U+1F422'),
  SasEmoji(number: 12, emoji: '🐟', description: 'Fish', unicode: 'U+1F41F'),
  SasEmoji(number: 13, emoji: '🐙', description: 'Octopus', unicode: 'U+1F419'),
  SasEmoji(
    number: 14,
    emoji: '🦋',
    description: 'Butterfly',
    unicode: 'U+1F98B',
  ),
  SasEmoji(number: 15, emoji: '🌷', description: 'Flower', unicode: 'U+1F337'),
  SasEmoji(number: 16, emoji: '🌳', description: 'Tree', unicode: 'U+1F333'),
  SasEmoji(number: 17, emoji: '🌵', description: 'Cactus', unicode: 'U+1F335'),
  SasEmoji(
    number: 18,
    emoji: '🍄',
    description: 'Mushroom',
    unicode: 'U+1F344',
  ),
  SasEmoji(number: 19, emoji: '🌏', description: 'Globe', unicode: 'U+1F30F'),
  SasEmoji(number: 20, emoji: '🌙', description: 'Moon', unicode: 'U+1F319'),
  SasEmoji(
    number: 21,
    emoji: '☁️',
    description: 'Cloud',
    unicode: 'U+2601U+FE0F',
  ),
  SasEmoji(number: 22, emoji: '🔥', description: 'Fire', unicode: 'U+1F525'),
  SasEmoji(number: 23, emoji: '🍌', description: 'Banana', unicode: 'U+1F34C'),
  SasEmoji(number: 24, emoji: '🍎', description: 'Apple', unicode: 'U+1F34E'),
  SasEmoji(
    number: 25,
    emoji: '🍓',
    description: 'Strawberry',
    unicode: 'U+1F353',
  ),
  SasEmoji(number: 26, emoji: '🌽', description: 'Corn', unicode: 'U+1F33D'),
  SasEmoji(number: 27, emoji: '🍕', description: 'Pizza', unicode: 'U+1F355'),
  SasEmoji(number: 28, emoji: '🎂', description: 'Cake', unicode: 'U+1F382'),
  SasEmoji(
    number: 29,
    emoji: '❤️',
    description: 'Heart',
    unicode: 'U+2764U+FE0F',
  ),
  SasEmoji(number: 30, emoji: '😀', description: 'Smiley', unicode: 'U+1F600'),
  SasEmoji(number: 31, emoji: '🤖', description: 'Robot', unicode: 'U+1F916'),
  SasEmoji(number: 32, emoji: '🎩', description: 'Hat', unicode: 'U+1F3A9'),
  SasEmoji(number: 33, emoji: '👓', description: 'Glasses', unicode: 'U+1F453'),
  SasEmoji(number: 34, emoji: '🔧', description: 'Spanner', unicode: 'U+1F527'),
  SasEmoji(number: 35, emoji: '🎅', description: 'Santa', unicode: 'U+1F385'),
  SasEmoji(
    number: 36,
    emoji: '👍',
    description: 'Thumbs Up',
    unicode: 'U+1F44D',
  ),
  SasEmoji(
    number: 37,
    emoji: '☂️',
    description: 'Umbrella',
    unicode: 'U+2602U+FE0F',
  ),
  SasEmoji(number: 38, emoji: '⌛', description: 'Hourglass', unicode: 'U+231B'),
  SasEmoji(number: 39, emoji: '⏰', description: 'Clock', unicode: 'U+23F0'),
  SasEmoji(number: 40, emoji: '🎁', description: 'Gift', unicode: 'U+1F381'),
  SasEmoji(
    number: 41,
    emoji: '💡',
    description: 'Light Bulb',
    unicode: 'U+1F4A1',
  ),
  SasEmoji(number: 42, emoji: '📖', description: 'Book', unicode: 'U+1F4D6'),
  SasEmoji(
    number: 43,
    emoji: '✏️',
    description: 'Pencil',
    unicode: 'U+270FU+FE0F',
  ),
  SasEmoji(
    number: 44,
    emoji: '📎',
    description: 'Paperclip',
    unicode: 'U+1F4CE',
  ),
  SasEmoji(
    number: 45,
    emoji: '✂️',
    description: 'Scissors',
    unicode: 'U+2702U+FE0F',
  ),
  SasEmoji(number: 46, emoji: '🔒', description: 'Lock', unicode: 'U+1F512'),
  SasEmoji(number: 47, emoji: '🔑', description: 'Key', unicode: 'U+1F511'),
  SasEmoji(number: 48, emoji: '🔨', description: 'Hammer', unicode: 'U+1F528'),
  SasEmoji(
    number: 49,
    emoji: '☎️',
    description: 'Telephone',
    unicode: 'U+260EU+FE0F',
  ),
  SasEmoji(number: 50, emoji: '🚩', description: 'Flag', unicode: 'U+1F6A9'),
  SasEmoji(number: 51, emoji: '🚆', description: 'Train', unicode: 'U+1F686'),
  SasEmoji(number: 52, emoji: '🚲', description: 'Bicycle', unicode: 'U+1F6B2'),
  SasEmoji(
    number: 53,
    emoji: '✈️',
    description: 'Aeroplane',
    unicode: 'U+2708U+FE0F',
  ),
  SasEmoji(number: 54, emoji: '🚀', description: 'Rocket', unicode: 'U+1F680'),
  SasEmoji(number: 55, emoji: '🏆', description: 'Trophy', unicode: 'U+1F3C6'),
  SasEmoji(number: 56, emoji: '⚽', description: 'Ball', unicode: 'U+26BD'),
  SasEmoji(number: 57, emoji: '🎸', description: 'Guitar', unicode: 'U+1F3B8'),
  SasEmoji(number: 58, emoji: '🎺', description: 'Trumpet', unicode: 'U+1F3BA'),
  SasEmoji(number: 59, emoji: '🔔', description: 'Bell', unicode: 'U+1F514'),
  SasEmoji(number: 60, emoji: '⚓', description: 'Anchor', unicode: 'U+2693'),
  SasEmoji(
    number: 61,
    emoji: '🎧',
    description: 'Headphones',
    unicode: 'U+1F3A7',
  ),
  SasEmoji(number: 62, emoji: '📁', description: 'Folder', unicode: 'U+1F4C1'),
  SasEmoji(number: 63, emoji: '📌', description: 'Pin', unicode: 'U+1F4CC'),
];
