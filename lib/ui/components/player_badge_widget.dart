import 'package:flutter/material.dart';
import '../../models/player.dart';

class PlayerBadgeWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentTurn;
  final bool isDealer;
  final bool compact;
  final VoidCallback? onTap;

  const PlayerBadgeWidget({
    super.key,
    required this.player,
    this.isCurrentTurn = false,
    this.isDealer = false,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final call = player.call;
    final won = player.tricksWon;
    final hasMadeBid = call != null && won >= call;

    Color statusBadgeColor;
    if (call == null) {
      statusBadgeColor = Colors.white24;
    } else if (hasMadeBid) {
      statusBadgeColor = const Color(0xFF10B981); // Emerald green for success
    } else {
      statusBadgeColor = const Color(0xFFF59E0B); // Amber for in progress
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: isCurrentTurn
              ? const Color(0xFF1E293B).withAlpha(240)
              : const Color(0xFF0F172A).withAlpha(200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentTurn
                ? const Color(0xFFFBBF24) // Gold pulsing border
                : Colors.white24,
            width: isCurrentTurn ? 2.2 : 1.0,
          ),
          boxShadow: [
            if (isCurrentTurn)
              BoxShadow(
                color: const Color(0xFFFBBF24).withAlpha(140),
                blurRadius: 12,
                spreadRadius: 1,
              )
            else
              const BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with optional Dealer chip
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: compact ? 34 : 40,
                  height: compact ? 34 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        player.isHuman
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF64748B),
                        player.isHuman
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF334155),
                      ],
                    ),
                    border: Border.all(
                      color: isCurrentTurn
                          ? const Color(0xFFFBBF24)
                          : Colors.white38,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      player.avatarEmoji,
                      style: TextStyle(fontSize: compact ? 18 : 22),
                    ),
                  ),
                ),
                if (isDealer)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), // Red dealer chip
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black54, blurRadius: 3),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),

            // Player Name & Call/Won stats
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: compact ? 12 : 14,
                      ),
                    ),
                    if (isCurrentTurn) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TURN',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),

                // Call / Won badges
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBadgeColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusBadgeColor, width: 0.8),
                      ),
                      child: Text(
                        call == null
                            ? 'Bidding...'
                            : 'Call: $call  |  Won: $won',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 10 : 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (player.hand.isNotEmpty && !player.isHuman) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${player.hand.length})',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
