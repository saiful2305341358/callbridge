import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/card.dart';
import '../../models/player.dart';
import '../../models/game_state.dart';
import '../../engine/callbridge_engine.dart';
import '../../services/stats_storage.dart';
import '../components/playing_card_widget.dart';
import '../components/player_badge_widget.dart';
import '../components/table_felt_widget.dart';
import '../components/scorecard_sheet.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final GameSettings settings;

  const GameScreen({
    super.key,
    this.mode = GameMode.vsBots,
    this.settings = const GameSettings(),
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameSettings _settings;
  late List<Player> _players;
  final List<RoundRecord> _roundRecords = [];

  int _currentRound = 1;
  int _dealerIndex = 0;
  PlayerPosition _currentTurn = PlayerPosition.south;
  GamePhase _phase = GamePhase.dealing;

  CurrentTrick _currentTrick = CurrentTrick(leadPlayer: PlayerPosition.south);
  PlayingCard? _selectedCard;
  bool _sortBySuit = true;
  String? _statusBannerText;
  PlayedCard? _lastTrickWinner;

  Timer? _aiActionTimer;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _initializePlayers();
    _startRound();
  }

  @override
  void dispose() {
    _aiActionTimer?.cancel();
    super.dispose();
  }

  void _initializePlayers() {
    _players = [
      Player(
        position: PlayerPosition.south,
        name: 'You',
        avatarEmoji: '😎',
        isHuman: true,
      ),
      Player(
        position: PlayerPosition.west,
        name: 'Rahul',
        avatarEmoji: '🤖',
        isHuman: widget.mode == GameMode.passAndPlay,
      ),
      Player(
        position: PlayerPosition.north,
        name: 'Dev',
        avatarEmoji: '🦁',
        isHuman: widget.mode == GameMode.passAndPlay,
      ),
      Player(
        position: PlayerPosition.east,
        name: 'Priya',
        avatarEmoji: '🦊',
        isHuman: widget.mode == GameMode.passAndPlay,
      ),
    ];
  }

  void _triggerHaptic() {
    if (_settings.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  Player _getPlayer(PlayerPosition pos) {
    return _players.firstWhere((p) => p.position == pos);
  }

  // --- ROUND LIFECYCLE ---

  void _startRound() {
    _aiActionTimer?.cancel();
    setState(() {
      _phase = GamePhase.dealing;
      _selectedCard = null;
      _statusBannerText = 'Dealing cards for Round $_currentRound...';
    });

    // Deal 4 hands of 13 cards each
    final hands = Deck.dealFourHands();
    for (int i = 0; i < 4; i++) {
      _players[i].resetForNewRound(hands[i]);
      _players[i].sortHand(bySuit: _sortBySuit);
    }

    // Dealer rotates clockwise each round
    final dealer = _players[_dealerIndex];
    // First bidder is the player immediately to the left of dealer
    final firstBidderPos = dealer.position.next;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _phase = GamePhase.bidding;
        _currentTurn = firstBidderPos;
        _statusBannerText = 'Bidding Phase: Call your estimated tricks';
      });

      _triggerTurnLogic();
    });
  }

  void _triggerTurnLogic() {
    _aiActionTimer?.cancel();
    final currentPlayer = _getPlayer(_currentTurn);

    if (_phase == GamePhase.bidding) {
      if (currentPlayer.isHuman && widget.mode != GameMode.passAndPlay) {
        // Show Human Bidding modal
        _showHumanBidDialog(currentPlayer);
      } else {
        // AI or Pass-and-Play AI bot bidding
        _aiActionTimer = Timer(
          Duration(milliseconds: _settings.aiTurnDelayMs),
          () => _processAiBid(currentPlayer),
        );
      }
    } else if (_phase == GamePhase.playing) {
      if (currentPlayer.isHuman && widget.mode != GameMode.passAndPlay) {
        // Waiting for human player to pick and play card
        setState(() {
          _statusBannerText = 'Your turn! Select a card to play.';
        });
      } else {
        // Bot's turn to play a card
        setState(() {
          _statusBannerText = '${currentPlayer.name} is thinking...';
        });
        _aiActionTimer = Timer(
          Duration(milliseconds: _settings.aiTurnDelayMs),
          () => _processAiPlay(currentPlayer),
        );
      }
    }
  }

  // --- BIDDING PHASE ---

  void _showHumanBidDialog(Player human) {
    final recommended = CallBridgeEngine.computeAiBid(
      human.hand,
      _settings.aiDifficulty,
    );

    int selectedBid = human.call ?? recommended;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black87, blurRadius: 20),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.record_voice_over, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 8),
                          Text(
                            'Your Call (Round $_currentRound)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF3B82F6)),
                        ),
                        child: Text(
                          'Suggested: $recommended',
                          style: const TextStyle(
                            color: Color(0xFF60A5FA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Estimate how many tricks (1–8) you can win this round. Making your call scores positive points, breaking deducts full bid.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Call selector chips (1 to 8)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: List.generate(8, (index) {
                      final bidValue = index + 1;
                      final isSelected = selectedBid == bidValue;
                      return ChoiceChip(
                        label: Text(
                          '$bidValue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFBBF24),
                        backgroundColor: const Color(0xFF1E293B),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFFBBF24) : Colors.white24,
                            width: 1.5,
                          ),
                        ),
                        onSelected: (val) {
                          _triggerHaptic();
                          setSheetState(() => selectedBid = bidValue);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBBF24),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        _triggerHaptic();
                        Navigator.of(ctx).pop();
                        _submitBid(human, selectedBid);
                      },
                      child: Text(
                        'Confirm Call of $selectedBid Tricks',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _processAiBid(Player bot) {
    final bid = CallBridgeEngine.computeAiBid(bot.hand, _settings.aiDifficulty);
    _submitBid(bot, bid);
  }

  void _submitBid(Player player, int bid) {
    setState(() {
      player.call = bid;
      _statusBannerText = '${player.name} called $bid tricks';
    });

    // Check if all 4 players have called
    final allBidsDone = _players.every((p) => p.call != null);
    if (allBidsDone) {
      // Bidding complete! Lead player is the player next to the dealer
      final firstPlayer = _getPlayer(_players[_dealerIndex].position.next);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _phase = GamePhase.playing;
          _currentTurn = firstPlayer.position;
          _currentTrick = CurrentTrick(leadPlayer: firstPlayer.position);
          _statusBannerText = 'Trick 1 begins! ${firstPlayer.name} leads.';
        });
        _triggerTurnLogic();
      });
    } else {
      // Next player's turn to bid
      setState(() {
        _currentTurn = _currentTurn.next;
      });
      _triggerTurnLogic();
    }
  }

  // --- PLAYING / TRICK PHASE ---

  void _onCardTapped(PlayingCard card) {
    if (_phase != GamePhase.playing) return;
    if (_currentTurn != PlayerPosition.south) return;

    final human = _getPlayer(PlayerPosition.south);
    final validation = CallBridgeEngine.validatePlay(
      card: card,
      hand: human.hand,
      currentTrick: _currentTrick,
      strictTrumpRule: _settings.strictTrumpRule,
    );

    if (!validation.isLegal) {
      _triggerHaptic();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(child: Text(validation.reason ?? 'Illegal card play')),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    _triggerHaptic();

    // If already selected, play it immediately. Otherwise select it.
    if (_selectedCard == card) {
      _executeCardPlay(human, card);
    } else {
      setState(() {
        _selectedCard = card;
      });
    }
  }

  void _processAiPlay(Player bot) {
    final cardToPlay = CallBridgeEngine.chooseAiPlay(
      bot: bot,
      trick: _currentTrick,
      difficulty: _settings.aiDifficulty,
      strictTrumpRule: _settings.strictTrumpRule,
    );
    _executeCardPlay(bot, cardToPlay);
  }

  void _executeCardPlay(Player player, PlayingCard card) {
    player.removeCard(card);
    _currentTrick.addPlay(player.position, card);

    setState(() {
      _selectedCard = null;
      _statusBannerText = '${player.name} played $card';
    });

    if (_currentTrick.isComplete) {
      // Trick is finished with 4 cards! Evaluate winner
      _resolveTrick();
    } else {
      // Next player follows the trick
      setState(() {
        _currentTurn = _currentTurn.next;
      });
      _triggerTurnLogic();
    }
  }

  void _resolveTrick() {
    final winningPlay = CallBridgeEngine.evaluateTrickWinner(_currentTrick);
    final winnerPlayer = _getPlayer(winningPlay.player);
    winnerPlayer.tricksWon++;

    setState(() {
      _phase = GamePhase.trickResolved;
      _lastTrickWinner = winningPlay;
      _statusBannerText = '${winnerPlayer.name} wins trick with ${winningPlay.card}!';
    });

    _triggerHaptic();

    // Pause briefly so user can see all 4 played cards and who won
    final pauseMs = _settings.aiTurnDelayMs + 450;
    _aiActionTimer = Timer(Duration(milliseconds: pauseMs), () {
      if (!mounted) return;

      // Check if 13 tricks (entire round) are finished
      final roundFinished = _players.every((p) => p.hand.isEmpty);
      if (roundFinished) {
        _resolveRound();
      } else {
        // Start next trick, winner leads!
        setState(() {
          _phase = GamePhase.playing;
          _currentTurn = winningPlay.player;
          _currentTrick = CurrentTrick(leadPlayer: winningPlay.player);
          _lastTrickWinner = null;
          _statusBannerText = '${winnerPlayer.name} leads the next trick.';
        });
        _triggerTurnLogic();
      }
    });
  }

  // --- ROUND RESOLUTION ---

  void _resolveRound() {
    final Map<PlayerPosition, int> roundCalls = {};
    final Map<PlayerPosition, int> roundTricks = {};
    final Map<PlayerPosition, double> roundScores = {};
    final Map<PlayerPosition, double> cumulativeScores = {};

    for (final player in _players) {
      final call = player.call ?? 1;
      final won = player.tricksWon;
      final score = CallBridgeEngine.calculateRoundScore(
        call: call,
        tricksWon: won,
        extraTrickBonus: _settings.extraTrickBonus,
      );

      player.roundScore = score;
      player.totalScore = double.parse((player.totalScore + score).toStringAsFixed(2));

      roundCalls[player.position] = call;
      roundTricks[player.position] = won;
      roundScores[player.position] = score;
      cumulativeScores[player.position] = player.totalScore;

      if (player.isHuman) {
        StatsService().recordRoundCompleted(
          roundScore: score,
          tricksWon: won,
          call: call,
        );
      }
    }

    final record = RoundRecord(
      roundNumber: _currentRound,
      calls: roundCalls,
      tricksWon: roundTricks,
      roundScores: roundScores,
      cumulativeScores: cumulativeScores,
    );
    _roundRecords.add(record);

    setState(() {
      _phase = GamePhase.roundSummary;
      _statusBannerText = 'Round $_currentRound Completed!';
    });

    _showRoundSummaryDialog();
  }

  void _showRoundSummaryDialog() {
    final isMatchEnd = _currentRound >= _settings.totalRounds;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFFBBF24), width: 1.5),
          ),
          title: Row(
            children: [
              Text(
                isMatchEnd ? '🏆 Match Finished!' : 'Round $_currentRound Summary',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._players.map((p) {
                  final made = p.tricksWon >= (p.call ?? 1);
                  final score = p.roundScore;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: made ? const Color(0xFF064E3B).withAlpha(80) : const Color(0xFF7F1D1D).withAlpha(80),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: made ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(p.avatarEmoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              p.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Call: ${p.call}  |  Won: ${p.tricksWon}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                            Text(
                              '${score >= 0 ? '+' : ''}${score.toStringAsFixed(1)} (Total: ${p.totalScore.toStringAsFixed(1)})',
                              style: TextStyle(
                                color: score >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScorecardSheet.show(
                  context,
                  players: _players,
                  roundRecords: _roundRecords,
                  currentRoundNumber: _currentRound,
                  totalRounds: _settings.totalRounds,
                );
              },
              child: const Text('View Full Scorecard', style: TextStyle(color: Color(0xFF60A5FA))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (isMatchEnd) {
                  _concludeMatch();
                } else {
                  _advanceToNextRound();
                }
              },
              child: Text(isMatchEnd ? 'Final Results' : 'Next Round'),
            ),
          ],
        );
      },
    );
  }

  void _advanceToNextRound() {
    _currentRound++;
    _dealerIndex = (_dealerIndex + 1) % 4; // Rotate dealer
    _startRound();
  }

  void _concludeMatch() {
    // Sort players by total score to find winner
    final ranked = List<Player>.from(_players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final winner = ranked.first;
    final human = _getPlayer(PlayerPosition.south);
    final userWon = winner.position == PlayerPosition.south;

    StatsService().recordMatchFinished(
      userWon: userWon,
      winnerName: winner.name,
      userScore: human.totalScore,
      totalRounds: _settings.totalRounds,
      tricksTakenInMatch: _roundRecords.fold<int>(
        0,
        (sum, r) => sum + (r.tricksWon[PlayerPosition.south] ?? 0),
      ),
    );

    setState(() {
      _phase = GamePhase.matchFinished;
      _statusBannerText = 'Match Concluded! ${winner.name} wins!';
    });

    _showMatchFinishedDialog(ranked);
  }

  void _showMatchFinishedDialog(List<Player> ranked) {
    final winner = ranked.first;
    final human = _getPlayer(PlayerPosition.south);
    final userWon = winner.position == PlayerPosition.south;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFFBBF24), width: 2),
          ),
          title: Center(
            child: Column(
              children: [
                Text(
                  userWon ? '🎉 VICTORY! 🎉' : '🏆 Match Results 🏆',
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${winner.name} won with ${winner.totalScore.toStringAsFixed(1)} points!',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...ranked.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final player = entry.value;
                final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '4th';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: rank == 1 ? const Color(0xFFD97706).withAlpha(60) : Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rank == 1 ? const Color(0xFFFBBF24) : Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(medal, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Text(
                            player.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${player.totalScore.toStringAsFixed(1)} pts',
                        style: TextStyle(
                          color: rank == 1 ? const Color(0xFFFBBF24) : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Back to main menu
              },
              child: const Text('Main Menu', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _currentRound = 1;
                  _dealerIndex = 0;
                  _roundRecords.clear();
                  for (final p in _players) {
                    p.totalScore = 0.0;
                  }
                });
                _startRound();
              },
              child: const Text('Play Rematch'),
            ),
          ],
        );
      },
    );
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    final human = _getPlayer(PlayerPosition.south);
    final west = _getPlayer(PlayerPosition.west);
    final north = _getPlayer(PlayerPosition.north);
    final east = _getPlayer(PlayerPosition.east);

    final dealerPlayer = _players[_dealerIndex];

    return Scaffold(
      backgroundColor: _settings.feltTheme.darkColor,
      body: SafeArea(
        child: TableFeltWidget(
          theme: _settings.feltTheme,
          child: Column(
            children: [
              // 1. Top Control & Status Bar
              _buildTopBar(),

              // 2. Play Area (North, West, Center Trick Table, East)
              Expanded(
                child: Stack(
                  children: [
                    // Top Player: North
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: PlayerBadgeWidget(
                          player: north,
                          isCurrentTurn: _currentTurn == PlayerPosition.north,
                          isDealer: dealerPlayer.position == PlayerPosition.north,
                        ),
                      ),
                    ),

                    // Left Player: West
                    Positioned(
                      left: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: PlayerBadgeWidget(
                          player: west,
                          isCurrentTurn: _currentTurn == PlayerPosition.west,
                          isDealer: dealerPlayer.position == PlayerPosition.west,
                          compact: true,
                        ),
                      ),
                    ),

                    // Right Player: East
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: PlayerBadgeWidget(
                          player: east,
                          isCurrentTurn: _currentTurn == PlayerPosition.east,
                          isDealer: dealerPlayer.position == PlayerPosition.east,
                          compact: true,
                        ),
                      ),
                    ),

                    // Center: Trick Cards Arena
                    Center(
                      child: _buildCenterTrickArena(),
                    ),

                    // Status Toast / Announcement Bar
                    if (_statusBannerText != null)
                      Positioned(
                        bottom: 8,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(190),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: Text(
                              _statusBannerText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 3. Bottom Player (South) Controls & Hand
              _buildBottomPlayerArea(human, dealerPlayer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(90),
        border: const Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Round & Trump indicator
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                onPressed: () => _confirmExitGame(),
                tooltip: 'Exit Game',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  'Round $_currentRound / ${_settings.totalRounds}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Trump Badge: Spades permanent trump
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFBBF24), width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('♠', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 16)),
                    SizedBox(width: 4),
                    Text(
                      'Trump',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action Buttons: Scorecard, Speed, Settings
          Row(
            children: [
              // Fast speed toggle
              IconButton(
                icon: Icon(
                  _settings.aiTurnDelayMs <= 400 ? Icons.flash_on : Icons.speed,
                  color: _settings.aiTurnDelayMs <= 400 ? const Color(0xFFFBBF24) : Colors.white70,
                ),
                tooltip: 'Toggle Speed',
                onPressed: () {
                  _triggerHaptic();
                  setState(() {
                    _settings = _settings.copyWith(
                      aiTurnDelayMs: _settings.aiTurnDelayMs <= 400 ? 750 : 350,
                    );
                  });
                },
              ),
              // Scorecard Sheet button
              IconButton(
                icon: const Icon(Icons.table_chart_outlined, color: Colors.white),
                tooltip: 'Scorecard',
                onPressed: () {
                  _triggerHaptic();
                  ScorecardSheet.show(
                    context,
                    players: _players,
                    roundRecords: _roundRecords,
                    currentRoundNumber: _currentRound,
                    totalRounds: _settings.totalRounds,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterTrickArena() {
    final playedNorth = _currentTrick.playForPlayer(PlayerPosition.north);
    final playedSouth = _currentTrick.playForPlayer(PlayerPosition.south);
    final playedWest = _currentTrick.playForPlayer(PlayerPosition.west);
    final playedEast = _currentTrick.playForPlayer(PlayerPosition.east);

    final isWinnerDeclared = _lastTrickWinner != null;

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withAlpha(40),
        border: Border.all(color: Colors.white10, width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center watermark badge
          if (_currentTrick.plays.isEmpty)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('♠', style: TextStyle(color: Colors.white12, fontSize: 48)),
                Text(
                  'Trick ${_currentTrickNumber()} / 13',
                  style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),

          // North Card (Top)
          if (playedNorth != null)
            Positioned(
              top: 14,
              child: _buildTrickPlayedCard(playedNorth, isWinner: isWinnerDeclared && _lastTrickWinner?.player == PlayerPosition.north),
            ),

          // South Card (Bottom)
          if (playedSouth != null)
            Positioned(
              bottom: 14,
              child: _buildTrickPlayedCard(playedSouth, isWinner: isWinnerDeclared && _lastTrickWinner?.player == PlayerPosition.south),
            ),

          // West Card (Left)
          if (playedWest != null)
            Positioned(
              left: 14,
              child: _buildTrickPlayedCard(playedWest, isWinner: isWinnerDeclared && _lastTrickWinner?.player == PlayerPosition.west),
            ),

          // East Card (Right)
          if (playedEast != null)
            Positioned(
              right: 14,
              child: _buildTrickPlayedCard(playedEast, isWinner: isWinnerDeclared && _lastTrickWinner?.player == PlayerPosition.east),
            ),
        ],
      ),
    );
  }

  int _currentTrickNumber() {
    final playedCount = 13 - _getPlayer(PlayerPosition.south).hand.length;
    return (playedCount + 1).clamp(1, 13);
  }

  Widget _buildTrickPlayedCard(PlayedCard played, {bool isWinner = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayingCardWidget(
          card: played.card,
          width: 58,
          height: 82,
          elevation: isWinner ? 10 : 4,
          badgeText: isWinner ? 'WIN' : null,
          cardBackTheme: _settings.cardBackTheme,
        ),
      ],
    );
  }

  Widget _buildBottomPlayerArea(Player human, Player dealerPlayer) {
    // Determine legal cards for human player
    final legalCards = _phase == GamePhase.playing && _currentTurn == PlayerPosition.south
        ? CallBridgeEngine.getLegalCards(
            hand: human.hand,
            currentTrick: _currentTrick,
            strictTrumpRule: _settings.strictTrumpRule,
          )
        : human.hand;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(235),
        border: const Border(top: BorderSide(color: Colors.white12)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hand Header: Badge, Play Card Action, and Sort Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlayerBadgeWidget(
                  player: human,
                  isCurrentTurn: _currentTurn == PlayerPosition.south && _phase == GamePhase.playing,
                  isDealer: dealerPlayer.position == PlayerPosition.south,
                ),

                // Center Action or Quick Sort
                Row(
                  children: [
                    if (_selectedCard != null && _currentTurn == PlayerPosition.south && _phase == GamePhase.playing)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBBF24),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _executeCardPlay(human, _selectedCard!),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: Text('Play ${_selectedCard!.rank.label}${_selectedCard!.suit.symbol}'),
                      ),

                    const SizedBox(width: 8),

                    // Sort Hand Button
                    IconButton(
                      icon: Icon(
                        _sortBySuit ? Icons.category : Icons.sort,
                        color: Colors.white70,
                        size: 20,
                      ),
                      tooltip: _sortBySuit ? 'Sort: By Suit' : 'Sort: By Rank',
                      onPressed: () {
                        _triggerHaptic();
                        setState(() {
                          _sortBySuit = !_sortBySuit;
                          human.sortHand(bySuit: _sortBySuit);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Overlapping card fan / carousel
          SizedBox(
            height: 110,
            child: human.hand.isEmpty
                ? const Center(
                    child: Text(
                      'No cards remaining in hand',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final cardCount = human.hand.length;
                      final availableWidth = constraints.maxWidth - 20;
                      const cardWidth = 66.0;

                      // Calculate overlap offset
                      final double overlapStep = cardCount > 1
                          ? ((availableWidth - cardWidth) / (cardCount - 1)).clamp(22.0, 56.0)
                          : 0.0;

                      final totalFanWidth = cardWidth + (cardCount - 1) * overlapStep;
                      final startLeft = ((constraints.maxWidth - totalFanWidth) / 2).clamp(10.0, constraints.maxWidth);

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: (totalFanWidth + 20).clamp(constraints.maxWidth, double.infinity),
                          height: 110,
                          child: Stack(
                            children: human.hand.asMap().entries.map((entry) {
                              final index = entry.key;
                              final card = entry.value;
                              final isLegal = legalCards.contains(card);
                              final isSelected = _selectedCard == card;

                              return Positioned(
                                left: startLeft + index * overlapStep,
                                top: 6,
                                child: PlayingCardWidget(
                                  card: card,
                                  isFaceUp: true,
                                  isLegal: isLegal,
                                  isSelected: isSelected,
                                  cardBackTheme: _settings.cardBackTheme,
                                  onTap: () => _onCardTapped(card),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmExitGame() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Current Game?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your match progress will be forfeited.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Resume', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit to Menu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
