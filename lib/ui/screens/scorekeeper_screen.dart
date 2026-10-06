import 'package:flutter/material.dart';
import '../../engine/callbridge_engine.dart';

class ScorekeeperScreen extends StatefulWidget {
  const ScorekeeperScreen({super.key});

  @override
  State<ScorekeeperScreen> createState() => _ScorekeeperScreenState();
}

class ManualRoundRow {
  final int roundNum;
  final List<int> calls; // 4 players
  final List<int> won;   // 4 players
  final List<double> scores; // calculated

  ManualRoundRow({
    required this.roundNum,
    required this.calls,
    required this.won,
    required this.scores,
  });
}

class _ScorekeeperScreenState extends State<ScorekeeperScreen> {
  final List<String> _playerNames = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];
  int _totalRounds = 5;
  double _extraTrickBonus = 0.1;

  final List<ManualRoundRow> _rounds = [];

  @override
  void initState() {
    super.initState();
  }

  List<double> get _cumulativeScores {
    final totals = [0.0, 0.0, 0.0, 0.0];
    for (final r in _rounds) {
      for (int i = 0; i < 4; i++) {
        totals[i] += r.scores[i];
      }
    }
    return totals.map((t) => double.parse(t.toStringAsFixed(1))).toList();
  }

  void _addOrEditRound({int? roundIndex}) {
    final isEditing = roundIndex != null;
    final targetRoundNum = isEditing ? _rounds[roundIndex].roundNum : _rounds.length + 1;

    final calls = isEditing ? List<int>.from(_rounds[roundIndex].calls) : [2, 2, 2, 2];
    final won = isEditing ? List<int>.from(_rounds[roundIndex].won) : [2, 2, 2, 2];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final totalWon = won.fold(0, (sum, val) => sum + val);
            final isValidTricks = totalWon == 13;

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Round $targetRoundNum Scores',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isValidTricks
                                ? const Color(0xFF10B981).withAlpha(40)
                                : const Color(0xFFEF4444).withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isValidTricks ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                          child: Text(
                            'Total Tricks: $totalWon / 13',
                            style: TextStyle(
                              color: isValidTricks ? const Color(0xFF34D399) : const Color(0xFFF87171),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Input calls and tricks won for each player. Total tricks in Call Bridge must sum to 13.',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const Divider(color: Colors.white12, height: 24),

                    // 4 Player Input Rows
                    ...List.generate(4, (pIdx) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _playerNames[pIdx],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                // Call Picker
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Call (Bid)', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          IconButton.filledTonal(
                                            icon: const Icon(Icons.remove, size: 16),
                                            onPressed: calls[pIdx] > 1
                                                ? () => setSheetState(() => calls[pIdx]--)
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              '${calls[pIdx]}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton.filledTonal(
                                            icon: const Icon(Icons.add, size: 16),
                                            onPressed: calls[pIdx] < 8
                                                ? () => setSheetState(() => calls[pIdx]++)
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Won Picker
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Tricks Won', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          IconButton.filledTonal(
                                            icon: const Icon(Icons.remove, size: 16),
                                            onPressed: won[pIdx] > 0
                                                ? () => setSheetState(() => won[pIdx]--)
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              '${won[pIdx]}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton.filledTonal(
                                            icon: const Icon(Icons.add, size: 16),
                                            onPressed: won[pIdx] < 13
                                                ? () => setSheetState(() => won[pIdx]++)
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 18),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBBF24),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          final roundScores = List.generate(4, (i) {
                            return CallBridgeEngine.calculateRoundScore(
                              call: calls[i],
                              tricksWon: won[i],
                              extraTrickBonus: _extraTrickBonus,
                            );
                          });

                          setState(() {
                            final row = ManualRoundRow(
                              roundNum: targetRoundNum,
                              calls: calls,
                              won: won,
                              scores: roundScores,
                            );
                            if (isEditing) {
                              _rounds[roundIndex] = row;
                            } else {
                              _rounds.add(row);
                            }
                          });

                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          isEditing ? 'Update Round $targetRoundNum' : 'Save Round $targetRoundNum',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editPlayerNames() {
    final controllers = List.generate(4, (i) => TextEditingController(text: _playerNames[i]));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Player Names', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: controllers[i],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Player ${i + 1}',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBBF24), foregroundColor: Colors.black),
            onPressed: () {
              setState(() {
                for (int i = 0; i < 4; i++) {
                  if (controllers[i].text.trim().isNotEmpty) {
                    _playerNames[i] = controllers[i].text.trim();
                  }
                }
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Names'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _cumulativeScores;

    // Rank players
    final rankedIndices = List.generate(4, (i) => i)
      ..sort((a, b) => totals[b].compareTo(totals[a]));

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('Card Table Scorekeeper', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Edit Names',
            onPressed: _editPlayerNames,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Scorecard',
            onPressed: () {
              setState(() {
                _rounds.clear();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Leaderboard summary top strip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: rankedIndices.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final playerIdx = entry.value;
                  final isLeader = rank == 1;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isLeader ? const Color(0xFFD97706).withAlpha(40) : Colors.white.withAlpha(8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLeader ? const Color(0xFFFBBF24) : Colors.white10,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '4th'),
                          const SizedBox(height: 2),
                          Text(
                            _playerNames[playerIdx],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            totals[playerIdx].toStringAsFixed(1),
                            style: TextStyle(
                              color: isLeader ? const Color(0xFFFBBF24) : (totals[playerIdx] >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171)),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Scorecard Table
            Expanded(
              child: _rounds.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.scoreboard_outlined, color: Colors.white24, size: 64),
                          const SizedBox(height: 12),
                          const Text(
                            'No rounds recorded yet',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap "Add Round" below to start scoring your physical card game!',
                            style: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFBBF24),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () => _addOrEditRound(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Round 1'),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.2),
                                1: FlexColumnWidth(2.0),
                                2: FlexColumnWidth(2.0),
                                3: FlexColumnWidth(2.0),
                                4: FlexColumnWidth(2.0),
                              },
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFF0F172A)),
                                  children: [
                                    _cell('Rnd', isHeader: true),
                                    ...List.generate(4, (i) => _cell(_playerNames[i], isHeader: true)),
                                  ],
                                ),
                                ..._rounds.asMap().entries.map((entry) {
                                  final rIdx = entry.key;
                                  final r = entry.value;

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: rIdx.isEven ? Colors.white.withAlpha(4) : Colors.transparent,
                                    ),
                                    children: [
                                      InkWell(
                                        onTap: () => _addOrEditRound(roundIndex: rIdx),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Center(
                                            child: Text(
                                              'R${r.roundNum} ✎',
                                              style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 11),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ...List.generate(4, (pIdx) {
                                        final score = r.scores[pIdx];
                                        final isPositive = score >= 0;
                                        return InkWell(
                                          onTap: () => _addOrEditRound(roundIndex: rIdx),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${r.won[pIdx]} / ${r.calls[pIdx]}',
                                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
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
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFF0F172A)),
                                  children: [
                                    _cell('Total', isHeader: true),
                                    ...List.generate(4, (i) {
                                      final val = totals[i];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Center(
                                          child: Text(
                                            val.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: val >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
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
                      ],
                    ),
            ),

            // Bottom Add Round Action Bar
            if (_rounds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _addOrEditRound(),
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Record Round ${_rounds.length + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
