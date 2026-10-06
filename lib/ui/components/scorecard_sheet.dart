import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/game_state.dart';

class ScorecardSheet extends StatelessWidget {
  final List<Player> players;
  final List<RoundRecord> roundRecords;
  final int currentRoundNumber;
  final int totalRounds;

  const ScorecardSheet({
    super.key,
    required this.players,
    required this.roundRecords,
    required this.currentRoundNumber,
    required this.totalRounds,
  });

  static void show(
    BuildContext context, {
    required List<Player> players,
    required List<RoundRecord> roundRecords,
    required int currentRoundNumber,
    required int totalRounds,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScorecardSheet(
        players: players,
        roundRecords: roundRecords,
        currentRoundNumber: currentRoundNumber,
        totalRounds: totalRounds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort players by total score descending to determine ranks
    final rankedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A), // Dark slate
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.leaderboard_rounded, color: Color(0xFFFBBF24), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Match Scorecard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Round $currentRoundNumber of $totalRounds in progress',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // Standings Summary Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: rankedPlayers.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final player = entry.value;
                    final isLeader = rank == 1;

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: isLeader
                              ? const Color(0xFFD97706).withAlpha(50)
                              : Colors.white.withAlpha(12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLeader
                                ? const Color(0xFFFBBF24)
                                : Colors.white12,
                            width: isLeader ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '4th',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              player.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              player.totalScore.toStringAsFixed(1),
                              style: TextStyle(
                                color: isLeader
                                    ? const Color(0xFFFBBF24)
                                    : (player.totalScore >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171)),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Round History Table
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.2), // Round #
                            1: FlexColumnWidth(2.0), // South
                            2: FlexColumnWidth(2.0), // West
                            3: FlexColumnWidth(2.0), // North
                            4: FlexColumnWidth(2.0), // East
                          },
                          children: [
                            // Header Row
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E293B),
                              ),
                              children: [
                                _tableCell('Rnd', isHeader: true),
                                ...players.map((p) => _tableCell(p.name, isHeader: true)),
                              ],
                            ),

                            // Recorded rounds
                            ...roundRecords.map((record) {
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: record.roundNumber.isEven
                                      ? Colors.white.withAlpha(5)
                                      : Colors.transparent,
                                ),
                                children: [
                                  _tableCell('R${record.roundNumber}'),
                                  ...players.map((p) {
                                    final call = record.calls[p.position] ?? 0;
                                    final won = record.tricksWon[p.position] ?? 0;
                                    final score = record.roundScores[p.position] ?? 0.0;
                                    final isPositive = score >= 0;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$won / $call',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            (isPositive ? '+' : '') + score.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: isPositive ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }),

                            // Current live round if in progress
                            if (currentRoundNumber <= totalRounds &&
                                !roundRecords.any((r) => r.roundNumber == currentRoundNumber))
                              TableRow(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withAlpha(30),
                                ),
                                children: [
                                  _tableCell('R$currentRoundNumber (now)'),
                                  ...players.map((p) {
                                    final call = p.call;
                                    final won = p.tricksWon;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            call != null ? '$won / $call' : 'bidding',
                                            style: const TextStyle(
                                              color: Color(0xFF60A5FA),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'in play',
                                            style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),

                            // Total Cumulative Score Row
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F172A),
                              ),
                              children: [
                                _tableCell('Total', isHeader: true),
                                ...players.map((p) {
                                  final total = p.totalScore;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                    child: Center(
                                      child: Text(
                                        total.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: total >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Rules: Making bid scores Call + 0.1 per extra trick.\nFailing bid deducts full Call points.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isHeader ? Colors.white : Colors.white70,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: isHeader ? 12 : 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
