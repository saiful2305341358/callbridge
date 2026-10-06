import 'package:flutter/material.dart';
import '../../models/card.dart';
import '../../models/game_state.dart';

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard? card; // null means face down
  final bool isFaceUp;
  final bool isLegal;
  final bool isSelected;
  final CardBackTheme cardBackTheme;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double elevation;
  final String? badgeText;

  const PlayingCardWidget({
    super.key,
    this.card,
    this.isFaceUp = true,
    this.isLegal = true,
    this.isSelected = false,
    this.cardBackTheme = CardBackTheme.classicNavy,
    this.onTap,
    this.width = 68,
    this.height = 98,
    this.elevation = 3,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveElevation = isSelected ? elevation + 8 : elevation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutQuad,
      transform: Matrix4.translationValues(0, isSelected ? -12 : 0, 0),
      child: Material(
        color: Colors.transparent,
        elevation: effectiveElevation,
        shadowColor: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isLegal ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFBBF24) // Gold highlight
                    : (isLegal ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280).withAlpha(100)),
                width: isSelected ? 2.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withAlpha(150),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: isFaceUp && card != null
                        ? _buildCardFront(context, card!)
                        : _buildCardBack(context),
                  ),
                  if (badgeText != null)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Dimmed overlay if illegal to play
                  if (isFaceUp && !isLegal)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(130),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(BuildContext context, PlayingCard card) {
    final suitColor = card.suit.color;
    final isTrump = card.isTrump;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD), // Crisp premium card ivory white
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFFFFF),
            isTrump ? const Color(0xFFF1F5F9) : const Color(0xFFFAFAFA),
          ],
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          // Subtle faint watermarked background suit glyph
          Center(
            child: Opacity(
              opacity: 0.12,
              child: Text(
                card.suit.symbol,
                style: TextStyle(
                  fontSize: height * 0.45,
                  color: suitColor,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),
          // Top-left index (Rank + Suit)
          Positioned(
            top: 1,
            left: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  card.rank.label,
                  style: TextStyle(
                    fontSize: width * 0.22,
                    fontWeight: FontWeight.w900,
                    color: suitColor,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  card.suit.symbol,
                  style: TextStyle(
                    fontSize: width * 0.19,
                    color: suitColor,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Center main glyph
          Center(
            child: Text(
              card.suit.symbol,
              style: TextStyle(
                fontSize: height * 0.32,
                color: suitColor,
                height: 1.0,
              ),
            ),
          ),
          // Bottom-right inverted index
          Positioned(
            bottom: 1,
            right: 2,
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    card.rank.label,
                    style: TextStyle(
                      fontSize: width * 0.22,
                      fontWeight: FontWeight.w900,
                      color: suitColor,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    card.suit.symbol,
                    style: TextStyle(
                      fontSize: width * 0.19,
                      color: suitColor,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackTheme.primary,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardBackTheme.accent,
            cardBackTheme.primary,
          ],
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white70, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '♠',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 1,
                width: 24,
                color: Colors.white38,
                margin: const EdgeInsets.symmetric(vertical: 2),
              ),
              const Text(
                'CB',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
