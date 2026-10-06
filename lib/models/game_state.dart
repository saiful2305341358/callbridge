import 'package:flutter/material.dart';
import 'card.dart';
import 'player.dart';

enum GamePhase {
  dealing,
  bidding,
  playing,
  trickResolved,
  roundSummary,
  matchFinished,
}

enum GameMode {
  vsBots,
  passAndPlay,
  practice,
}

enum TableFeltTheme {
  casinoGreen(
    'Casino Emerald',
    Color(0xFF0F3B25),
    Color(0xFF0A291A),
    Color(0xFF1D5A3A),
    Color(0xFFE2B755),
  ),
  midnightNavy(
    'Midnight Blue',
    Color(0xFF0F1E36),
    Color(0xFF0A1324),
    Color(0xFF1A335C),
    Color(0xFF60A5FA),
  ),
  royalBurgundy(
    'Royal Burgundy',
    Color(0xFF38101E),
    Color(0xFF240A13),
    Color(0xFF5A1A30),
    Color(0xFFFBBF24),
  ),
  slateCarbon(
    'Carbon Onyx',
    Color(0xFF1E242B),
    Color(0xFF14181D),
    Color(0xFF333D48),
    Color(0xFF38BDF8),
  );

  final String displayName;
  final Color baseColor;
  final Color darkColor;
  final Color lightColor;
  final Color accentGold;

  const TableFeltTheme(
    this.displayName,
    this.baseColor,
    this.darkColor,
    this.lightColor,
    this.accentGold,
  );
}

enum CardBackTheme {
  classicNavy('Classic Navy', Color(0xFF1E3A8A), Color(0xFF3B82F6)),
  royalRuby('Royal Ruby', Color(0xFF881337), Color(0xFFE11D48)),
  forestEmerald('Forest Emerald', Color(0xFF064E3B), Color(0xFF10B981)),
  imperialGold('Imperial Gold', Color(0xFF78350F), Color(0xFFF59E0B));

  final String displayName;
  final Color primary;
  final Color accent;

  const CardBackTheme(this.displayName, this.primary, this.accent);
}

enum AIDifficulty {
  beginner('Beginner', 'Relaxed calls, gentle strategy'),
  standard('Standard', 'Balanced bidding & tactical trump play'),
  master('Master', 'Aggressive counter-trumping & card counting');

  final String displayName;
  final String description;

  const AIDifficulty(this.displayName, this.description);
}

class GameSettings {
  final int totalRounds;
  final double extraTrickBonus; // 0.1 standard or 1.0
  final AIDifficulty aiDifficulty;
  final TableFeltTheme feltTheme;
  final CardBackTheme cardBackTheme;
  final int aiTurnDelayMs; // speed (fast = 350, normal = 750)
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool strictTrumpRule; // must beat higher trump if possible

  const GameSettings({
    this.totalRounds = 5,
    this.extraTrickBonus = 0.1,
    this.aiDifficulty = AIDifficulty.standard,
    this.feltTheme = TableFeltTheme.casinoGreen,
    this.cardBackTheme = CardBackTheme.classicNavy,
    this.aiTurnDelayMs = 700,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.strictTrumpRule = true,
  });

  GameSettings copyWith({
    int? totalRounds,
    double? extraTrickBonus,
    AIDifficulty? aiDifficulty,
    TableFeltTheme? feltTheme,
    CardBackTheme? cardBackTheme,
    int? aiTurnDelayMs,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? strictTrumpRule,
  }) {
    return GameSettings(
      totalRounds: totalRounds ?? this.totalRounds,
      extraTrickBonus: extraTrickBonus ?? this.extraTrickBonus,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      feltTheme: feltTheme ?? this.feltTheme,
      cardBackTheme: cardBackTheme ?? this.cardBackTheme,
      aiTurnDelayMs: aiTurnDelayMs ?? this.aiTurnDelayMs,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      strictTrumpRule: strictTrumpRule ?? this.strictTrumpRule,
    );
  }
}

class PlayedCard {
  final PlayerPosition player;
  final PlayingCard card;

  const PlayedCard({required this.player, required this.card});
}

class CurrentTrick {
  final PlayerPosition leadPlayer;
  final List<PlayedCard> plays = [];
  PlayerPosition? winnerPlayer;
  PlayingCard? winningCard;

  CurrentTrick({required this.leadPlayer});

  bool get isComplete => plays.length == 4;

  PlayingCard? get leadCard => plays.isNotEmpty ? plays.first.card : null;
  Suit? get leadSuit => leadCard?.suit;

  void addPlay(PlayerPosition player, PlayingCard card) {
    plays.add(PlayedCard(player: player, card: card));
  }

  PlayedCard? playForPlayer(PlayerPosition position) {
    for (final p in plays) {
      if (p.player == position) return p;
    }
    return null;
  }
}

class RoundRecord {
  final int roundNumber;
  final Map<PlayerPosition, int> calls;
  final Map<PlayerPosition, int> tricksWon;
  final Map<PlayerPosition, double> roundScores;
  final Map<PlayerPosition, double> cumulativeScores;

  const RoundRecord({
    required this.roundNumber,
    required this.calls,
    required this.tricksWon,
    required this.roundScores,
    required this.cumulativeScores,
  });
}
