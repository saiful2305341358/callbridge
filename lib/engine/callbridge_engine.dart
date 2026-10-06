import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';

class CallBridgeEngine {
  /// Determines which cards in [hand] are legally allowed to be played,
  /// given the [currentTrick].
  static List<PlayingCard> getLegalCards({
    required List<PlayingCard> hand,
    required CurrentTrick currentTrick,
    bool strictTrumpRule = true,
  }) {
    if (hand.isEmpty) return [];

    // If player is leading the trick, any card in hand is legal
    if (currentTrick.plays.isEmpty) {
      return List.from(hand);
    }

    final leadSuit = currentTrick.leadSuit!;
    final cardsOfLeadSuit = hand.where((c) => c.suit == leadSuit).toList();

    // 1. Mandatory follow suit rule:
    // If player has cards in the lead suit, they MUST play one of them.
    if (cardsOfLeadSuit.isNotEmpty) {
      return cardsOfLeadSuit;
    }

    // 2. Player does NOT have the lead suit:
    // In Call Bridge, player MUST play a Trump (Spades) if they hold any.
    final trumpsInHand = hand.where((c) => c.isTrump).toList();
    if (trumpsInHand.isNotEmpty) {
      if (strictTrumpRule) {
        // Find highest trump currently played in the trick
        int highestTrumpRankOnTable = 0;
        for (final play in currentTrick.plays) {
          if (play.card.isTrump && play.card.rank.value > highestTrumpRankOnTable) {
            highestTrumpRankOnTable = play.card.rank.value;
          }
        }

        // If a trump was already played, player should try to beat it if they can
        if (highestTrumpRankOnTable > 0) {
          final higherTrumps = trumpsInHand
              .where((c) => c.rank.value > highestTrumpRankOnTable)
              .toList();
          if (higherTrumps.isNotEmpty) {
            return higherTrumps;
          }
        }
      }
      return trumpsInHand;
    }

    // 3. Player has neither lead suit nor Trump:
    // Can discard/sluff any card in hand.
    return List.from(hand);
  }

  /// Checks if a specific card is legal to play, and returns a user-friendly
  /// reason if it is not legal.
  static ({bool isLegal, String? reason}) validatePlay({
    required PlayingCard card,
    required List<PlayingCard> hand,
    required CurrentTrick currentTrick,
    bool strictTrumpRule = true,
  }) {
    final legalCards = getLegalCards(
      hand: hand,
      currentTrick: currentTrick,
      strictTrumpRule: strictTrumpRule,
    );

    if (legalCards.contains(card)) {
      return (isLegal: true, reason: null);
    }

    // Generate clear explanation
    if (currentTrick.plays.isNotEmpty) {
      final leadSuit = currentTrick.leadSuit!;
      final hasLeadSuit = hand.any((c) => c.suit == leadSuit);
      if (hasLeadSuit) {
        return (
          isLegal: false,
          reason: 'Must follow suit: You have ${leadSuit.displayName} in hand.'
        );
      }
      final hasTrump = hand.any((c) => c.isTrump);
      if (hasTrump) {
        return (
          isLegal: false,
          reason: 'Must play Trump (♠ Spades) when out of ${leadSuit.displayName}.'
        );
      }
    }

    return (isLegal: false, reason: 'This card cannot be played on this trick.');
  }

  /// Determines the winner of a completed 4-card trick.
  static PlayedCard evaluateTrickWinner(CurrentTrick trick) {
    assert(trick.plays.isNotEmpty, 'Cannot evaluate empty trick');

    final leadSuit = trick.leadSuit!;
    PlayedCard currentWinningPlay = trick.plays.first;

    for (int i = 1; i < trick.plays.length; i++) {
      final candidatePlay = trick.plays[i];
      final currentCard = currentWinningPlay.card;
      final candidateCard = candidatePlay.card;

      if (candidateCard.isTrump) {
        if (!currentCard.isTrump) {
          // Trump beats non-trump
          currentWinningPlay = candidatePlay;
        } else if (candidateCard.rank.value > currentCard.rank.value) {
          // Higher trump beats lower trump
          currentWinningPlay = candidatePlay;
        }
      } else if (!currentCard.isTrump && candidateCard.suit == leadSuit) {
        // Both non-trump, candidate follows lead suit and has higher rank
        if (candidateCard.rank.value > currentCard.rank.value) {
          currentWinningPlay = candidatePlay;
        }
      }
      // Otherwise, candidate card does not beat current winning play
    }

    return currentWinningPlay;
  }

  /// Calculates round score for a player based on bid and tricks won.
  static double calculateRoundScore({
    required int call,
    required int tricksWon,
    double extraTrickBonus = 0.1,
  }) {
    if (tricksWon >= call) {
      final overTricks = tricksWon - call;
      final bonus = overTricks * extraTrickBonus;
      // Round to 2 decimal places to avoid floating point artifacts
      return double.parse((call + bonus).toStringAsFixed(2));
    } else {
      // Failed call (broken): negative points equal to the call
      return -call.toDouble();
    }
  }

  /// AI Hand Evaluation & Bidding
  static int computeAiBid(List<PlayingCard> hand, AIDifficulty difficulty) {
    double estimatedTricks = 0.0;

    final Map<Suit, List<PlayingCard>> suitGroups = {
      Suit.spades: [],
      Suit.hearts: [],
      Suit.clubs: [],
      Suit.diamonds: [],
    };

    for (final card in hand) {
      suitGroups[card.suit]!.add(card);
    }

    // 1. Spades (Trump) evaluation:
    final spades = suitGroups[Suit.spades]!;
    final spadeCount = spades.length;
    final hasAceOfSpades = spades.any((c) => c.rank == CardRank.ace);
    final hasKingOfSpades = spades.any((c) => c.rank == CardRank.king);
    final hasQueenOfSpades = spades.any((c) => c.rank == CardRank.queen);

    if (hasAceOfSpades) estimatedTricks += 1.0;
    if (hasKingOfSpades && spadeCount >= 2) estimatedTricks += 0.9;
    if (hasQueenOfSpades && spadeCount >= 3) estimatedTricks += 0.7;

    // Extra length in Spades gives ruffing tricks
    if (spadeCount >= 4) {
      estimatedTricks += (spadeCount - 3) * 0.7;
    }

    // 2. Off-suit evaluations:
    for (final suit in [Suit.hearts, Suit.clubs, Suit.diamonds]) {
      final cards = suitGroups[suit]!;
      final count = cards.length;
      final hasAce = cards.any((c) => c.rank == CardRank.ace);
      final hasKing = cards.any((c) => c.rank == CardRank.king);
      final hasQueen = cards.any((c) => c.rank == CardRank.queen);

      if (hasAce) {
        estimatedTricks += (count <= 5) ? 0.95 : 0.75;
      }
      if (hasKing && count >= 2 && count <= 4) {
        estimatedTricks += hasAce ? 0.8 : 0.6;
      }
      if (hasQueen && count >= 3 && count <= 4 && hasKing) {
        estimatedTricks += 0.5;
      }

      // Short suit ruffing potential if player has spare trumps
      if (count == 0 && spadeCount >= 3) {
        estimatedTricks += 0.5;
      } else if (count == 1 && spadeCount >= 4) {
        estimatedTricks += 0.3;
      }
    }

    // Add slight difficulty-based variance
    int call = estimatedTricks.round();
    if (difficulty == AIDifficulty.beginner) {
      // Beginners sometimes underbid safely or overbid randomly
      if (Random().nextBool()) call += Random().nextInt(2) - 1;
    } else if (difficulty == AIDifficulty.master) {
      // Masters are disciplined and account for safety
      if (call < 1) call = 1;
    }

    // In Call Bridge, call is usually clamped between 1 and 8 (or 13)
    if (call < 1) call = 1;
    if (call > 8) call = 8;
    return call;
  }

  /// AI Card Play Selection
  static PlayingCard chooseAiPlay({
    required Player bot,
    required CurrentTrick trick,
    required AIDifficulty difficulty,
    bool strictTrumpRule = true,
  }) {
    final legalCards = getLegalCards(
      hand: bot.hand,
      currentTrick: trick,
      strictTrumpRule: strictTrumpRule,
    );

    assert(legalCards.isNotEmpty, 'No legal cards found for bot');
    if (legalCards.length == 1) return legalCards.first;

    final targetBid = bot.call ?? 1;
    final tricksNeeded = targetBid - bot.tricksWon;
    final needsTricks = tricksNeeded > 0;

    // Case 1: Bot is leading the trick
    if (trick.plays.isEmpty) {
      return _chooseAiLead(bot.hand, legalCards, needsTricks, difficulty);
    }

    // Case 2: Bot is following the trick
    return _chooseAiFollow(legalCards, trick, needsTricks, difficulty);
  }

  static PlayingCard _chooseAiLead(
    List<PlayingCard> fullHand,
    List<PlayingCard> legalCards,
    bool needsTricks,
    AIDifficulty difficulty,
  ) {
    // If bot needs tricks:
    if (needsTricks) {
      // Lead off-suit Aces (non-trump) first to cash sure tricks
      final nonTrumpAces = legalCards.where((c) => !c.isTrump && c.rank == CardRank.ace).toList();
      if (nonTrumpAces.isNotEmpty) {
        return nonTrumpAces.first;
      }

      // If holding Ace and King of Spades, can draw trumps
      final hasSpadeAce = legalCards.any((c) => c.isTrump && c.rank == CardRank.ace);
      final hasSpadeKing = legalCards.any((c) => c.isTrump && c.rank == CardRank.king);
      if (hasSpadeAce && hasSpadeKing) {
        return legalCards.firstWhere((c) => c.isTrump && c.rank == CardRank.ace);
      }

      // Otherwise lead highest card of strongest suit
      legalCards.sort((a, b) => b.rank.value.compareTo(a.rank.value));
      return legalCards.first;
    } else {
      // Already made bid: play safe, lead lowest off-suit card to avoid unwanted tricks
      final nonTrumps = legalCards.where((c) => !c.isTrump).toList();
      if (nonTrumps.isNotEmpty) {
        nonTrumps.sort((a, b) => a.rank.value.compareTo(b.rank.value));
        return nonTrumps.first;
      }
      // If only trumps left, lead lowest trump
      legalCards.sort((a, b) => a.rank.value.compareTo(b.rank.value));
      return legalCards.first;
    }
  }

  static PlayingCard _chooseAiFollow(
    List<PlayingCard> legalCards,
    CurrentTrick trick,
    bool needsTricks,
    AIDifficulty difficulty,
  ) {
    final currentWinner = evaluateTrickWinner(trick);
    final winningCard = currentWinner.card;

    // Filter legal cards that can beat the current winning card
    final winningOptions = <PlayingCard>[];
    for (final card in legalCards) {
      if (card.isTrump) {
        if (!winningCard.isTrump || card.rank.value > winningCard.rank.value) {
          winningOptions.add(card);
        }
      } else if (!winningCard.isTrump && card.suit == trick.leadSuit && card.rank.value > winningCard.rank.value) {
        winningOptions.add(card);
      }
    }

    if (needsTricks && winningOptions.isNotEmpty) {
      // Pick the lowest winning card to conserve higher cards
      winningOptions.sort((a, b) => a.rank.value.compareTo(b.rank.value));
      return winningOptions.first;
    } else {
      // Cannot win, or does not want to win: sluff lowest legal card
      legalCards.sort((a, b) => a.rank.value.compareTo(b.rank.value));
      return legalCards.first;
    }
  }
}
