import 'dart:convert';

class UserGameStats {
  int gamesPlayed;
  int gamesWon;
  int totalTricksWon;
  double highestMatchScore;
  double highestRoundScore;
  int cleanBidsCount; // Times made bid exactly

  UserGameStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalTricksWon = 0,
    this.highestMatchScore = 0.0,
    this.highestRoundScore = 0.0,
    this.cleanBidsCount = 0,
  });

  double get winRate =>
      gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100.0 : 0.0;

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'totalTricksWon': totalTricksWon,
        'highestMatchScore': highestMatchScore,
        'highestRoundScore': highestRoundScore,
        'cleanBidsCount': cleanBidsCount,
      };

  factory UserGameStats.fromJson(Map<String, dynamic> json) => UserGameStats(
        gamesPlayed: json['gamesPlayed'] ?? 0,
        gamesWon: json['gamesWon'] ?? 0,
        totalTricksWon: json['totalTricksWon'] ?? 0,
        highestMatchScore: (json['highestMatchScore'] as num?)?.toDouble() ?? 0.0,
        highestRoundScore: (json['highestRoundScore'] as num?)?.toDouble() ?? 0.0,
        cleanBidsCount: json['cleanBidsCount'] ?? 0,
      );
}

class MatchHistoryEntry {
  final DateTime timestamp;
  final String winnerName;
  final double userScore;
  final bool userWon;
  final int totalRounds;

  MatchHistoryEntry({
    required this.timestamp,
    required this.winnerName,
    required this.userScore,
    required this.userWon,
    required this.totalRounds,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'winnerName': winnerName,
        'userScore': userScore,
        'userWon': userWon,
        'totalRounds': totalRounds,
      };

  factory MatchHistoryEntry.fromJson(Map<String, dynamic> json) =>
      MatchHistoryEntry(
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        winnerName: json['winnerName'] ?? 'Unknown',
        userScore: (json['userScore'] as num?)?.toDouble() ?? 0.0,
        userWon: json['userWon'] ?? false,
        totalRounds: json['totalRounds'] ?? 5,
      );
}

/// In-memory singleton with fallback and structured reporting
class StatsService {
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  UserGameStats stats = UserGameStats(
    gamesPlayed: 3,
    gamesWon: 2,
    totalTricksWon: 28,
    highestMatchScore: 18.3,
    highestRoundScore: 5.2,
    cleanBidsCount: 11,
  );

  final List<MatchHistoryEntry> matchHistory = [
    MatchHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      winnerName: 'You',
      userScore: 18.3,
      userWon: true,
      totalRounds: 5,
    ),
    MatchHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      winnerName: 'Dev',
      userScore: 12.1,
      userWon: false,
      totalRounds: 5,
    ),
    MatchHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      winnerName: 'You',
      userScore: 16.5,
      userWon: true,
      totalRounds: 5,
    ),
  ];

  void recordMatchFinished({
    required bool userWon,
    required String winnerName,
    required double userScore,
    required int totalRounds,
    required int tricksTakenInMatch,
  }) {
    stats.gamesPlayed++;
    if (userWon) stats.gamesWon++;
    stats.totalTricksWon += tricksTakenInMatch;
    if (userScore > stats.highestMatchScore) {
      stats.highestMatchScore = userScore;
    }

    matchHistory.insert(
      0,
      MatchHistoryEntry(
        timestamp: DateTime.now(),
        winnerName: winnerName,
        userScore: userScore,
        userWon: userWon,
        totalRounds: totalRounds,
      ),
    );
  }

  void recordRoundCompleted({
    required double roundScore,
    required int tricksWon,
    required int call,
  }) {
    if (roundScore > stats.highestRoundScore) {
      stats.highestRoundScore = roundScore;
    }
    if (tricksWon == call) {
      stats.cleanBidsCount++;
    }
  }

  void resetStats() {
    stats = UserGameStats();
    matchHistory.clear();
  }
}
