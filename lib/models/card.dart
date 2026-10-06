import 'package:flutter/material.dart';

/// The four card suits in standard 52-card deck.
/// In Call Bridge, Spades is ALWAYS the permanent Trump suit.
enum Suit {
  spades,
  hearts,
  clubs,
  diamonds;

  String get symbol {
    switch (this) {
      case Suit.spades:
        return '♠';
      case Suit.hearts:
        return '♥';
      case Suit.clubs:
        return '♣';
      case Suit.diamonds:
        return '♦';
    }
  }

  String get displayName {
    switch (this) {
      case Suit.spades:
        return 'Spades';
      case Suit.hearts:
        return 'Hearts';
      case Suit.clubs:
        return 'Clubs';
      case Suit.diamonds:
        return 'Diamonds';
    }
  }

  Color get color {
    switch (this) {
      case Suit.spades:
        return const Color(0xFF1E293B); // Deep navy/slate black
      case Suit.hearts:
        return const Color(0xFFDC2626); // Crimson red
      case Suit.clubs:
        return const Color(0xFF0F766E); // Deep emerald/teal black
      case Suit.diamonds:
        return const Color(0xFFD97706); // Rich amber red
    }
  }

  bool get isTrump => this == Suit.spades;

  /// Custom sort order for hand organizing: Spades, Hearts, Clubs, Diamonds
  int get sortPriority {
    switch (this) {
      case Suit.spades:
        return 0; // Trump first
      case Suit.hearts:
        return 1;
      case Suit.clubs:
        return 2;
      case Suit.diamonds:
        return 3;
    }
  }
}

/// Standard ranks from 2 (lowest) to Ace (highest = 14).
enum CardRank {
  two(2, '2'),
  three(3, '3'),
  four(4, '4'),
  five(5, '5'),
  six(6, '6'),
  seven(7, '7'),
  eight(8, '8'),
  nine(9, '9'),
  ten(10, '10'),
  jack(11, 'J'),
  queen(12, 'Q'),
  king(13, 'K'),
  ace(14, 'A');

  final int value;
  final String label;
  const CardRank(this.value, this.label);
}

/// Immutable playing card
class PlayingCard {
  final Suit suit;
  final CardRank rank;

  const PlayingCard({
    required this.suit,
    required this.rank,
  });

  String get id => '${suit.name}_${rank.value}';

  bool get isTrump => suit.isTrump;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  @override
  String toString() => '${rank.label}${suit.symbol}';
}

/// Standard 52 card deck utilities
class Deck {
  static List<PlayingCard> create52Deck() {
    final List<PlayingCard> cards = [];
    for (final suit in Suit.values) {
      for (final rank in CardRank.values) {
        cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    return cards;
  }

  /// Shuffles deck and deals into 4 hands of 13 cards each
  static List<List<PlayingCard>> dealFourHands([List<PlayingCard>? customDeck]) {
    final deck = List<PlayingCard>.from(customDeck ?? create52Deck());
    deck.shuffle();

    final List<List<PlayingCard>> hands = [[], [], [], []];
    for (int i = 0; i < deck.length; i++) {
      hands[i % 4].add(deck[i]);
    }

    // Sort each hand by default
    for (int i = 0; i < 4; i++) {
      sortHand(hands[i], bySuit: true);
    }

    return hands;
  }

  /// Sorts a hand either by Suit (Spades -> Hearts -> Clubs -> Diamonds) then Rank (high to low),
  /// or purely by Rank (high to low).
  static void sortHand(List<PlayingCard> hand, {bool bySuit = true}) {
    hand.sort((a, b) {
      if (bySuit) {
        if (a.suit != b.suit) {
          return a.suit.sortPriority.compareTo(b.suit.sortPriority);
        }
        return b.rank.value.compareTo(a.rank.value); // Higher rank first
      } else {
        if (a.rank != b.rank) {
          return b.rank.value.compareTo(a.rank.value);
        }
        return a.suit.sortPriority.compareTo(b.suit.sortPriority);
      }
    });
  }
}
