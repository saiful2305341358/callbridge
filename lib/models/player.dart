import 'card.dart';

enum PlayerPosition {
  south, // Bottom (Human / Main player)
  west,  // Left
  north, // Top
  east;  // Right

  String get defaultName {
    switch (this) {
      case PlayerPosition.south:
        return 'You';
      case PlayerPosition.west:
        return 'Rahul';
      case PlayerPosition.north:
        return 'Dev';
      case PlayerPosition.east:
        return 'Priya';
    }
  }

  String get avatarEmoji {
    switch (this) {
      case PlayerPosition.south:
        return '😎';
      case PlayerPosition.west:
        return '🤖';
      case PlayerPosition.north:
        return '🦁';
      case PlayerPosition.east:
        return '🦊';
    }
  }

  PlayerPosition get next {
    final nextIdx = (index + 1) % 4;
    return PlayerPosition.values[nextIdx];
  }
}

class Player {
  final PlayerPosition position;
  String name;
  String avatarEmoji;
  bool isHuman;
  List<PlayingCard> hand;
  int? call;          // The bid announced during bidding phase (e.g. 1 to 8)
  int tricksWon;      // Tricks won in current round
  double roundScore;  // Score gained in the current round
  double totalScore;  // Cumulative match score across all rounds

  Player({
    required this.position,
    required this.name,
    required this.avatarEmoji,
    this.isHuman = false,
    List<PlayingCard>? hand,
    this.call,
    this.tricksWon = 0,
    this.roundScore = 0.0,
    this.totalScore = 0.0,
  }) : hand = hand ?? [];

  void resetForNewRound(List<PlayingCard> newHand) {
    hand = List.from(newHand);
    call = null;
    tricksWon = 0;
    roundScore = 0.0;
  }

  void sortHand({bool bySuit = true}) {
    Deck.sortHand(hand, bySuit: bySuit);
  }

  bool removeCard(PlayingCard card) {
    return hand.remove(card);
  }

  bool hasSuit(Suit suit) {
    return hand.any((c) => c.suit == suit);
  }

  List<PlayingCard> cardsOfSuit(Suit suit) {
    return hand.where((c) => c.suit == suit).toList();
  }

  bool hasTrump() {
    return hand.any((c) => c.isTrump);
  }

  List<PlayingCard> get trumps => hand.where((c) => c.isTrump).toList();
}
