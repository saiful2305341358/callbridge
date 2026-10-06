import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Call Bridge Rules & Guide', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 20),
          _buildRuleSection(
            icon: Icons.style,
            title: '1. Players, Deck & Deal',
            content:
                '• Call Bridge is played by exactly 4 players.\n'
                '• A standard 52-card deck is used (without Jokers).\n'
                '• Rank of cards in each suit from highest to lowest: A, K, Q, J, 10, 9, 8, 7, 6, 5, 4, 3, 2.\n'
                '• Each player receives exactly 13 cards at the start of each round.\n'
                '• The dealer rotates clockwise each round.',
          ),
          const SizedBox(height: 16),
          _buildRuleSection(
            icon: Icons.shield,
            title: '2. Permanent Trump (Spades ♠)',
            content:
                '• In Call Bridge, Spades (♠) is ALWAYS the permanent Trump suit.\n'
                '• Any Spade card defeats any card of the other three suits (Hearts, Clubs, Diamonds).\n'
                '• Between two or more Spades, the higher ranked Spade card wins.',
            highlight: true,
          ),
          const SizedBox(height: 16),
          _buildRuleSection(
            icon: Icons.record_voice_over,
            title: '3. The Bidding (Call) Phase',
            content:
                '• Starting from the player to the left of the dealer, each player announces their "Call".\n'
                '• The Call represents the minimum number of tricks (hands) you expect to win in the round (typically 1 to 8).\n'
                '• Sum of all 4 players\' bids usually totals 10 to 12 tricks.\n'
                '• Choose your bid carefully based on high cards (Aces/Kings) and Spades count!',
          ),
          const SizedBox(height: 16),
          _buildRuleSection(
            icon: Icons.play_circle_outline,
            title: '4. Rules of Trick Play',
            content:
                '• The player to the dealer\'s left leads the first card. Winner of each trick leads the next.\n'
                '• MANDATORY FOLLOW SUIT: If you hold cards of the suit led, you MUST play that suit.\n'
                '• TRUMPING: If you are out of the suit led, you MUST play a Trump card (♠ Spade) if you have one.\n'
                '• Higher Trump rule: If another player has already played a Spade, you should try to play a higher Spade if you can.\n'
                '• DISCARDING: If you have neither the suit led nor any Spades, you may play any card (sluff). Sluffed cards cannot win.',
          ),
          const SizedBox(height: 16),
          _buildRuleSection(
            icon: Icons.calculate_outlined,
            title: '5. Scoring & Calculation',
            content:
                '• Each round consists of 13 tricks.\n'
                '• MAKING YOUR BID: If you win at least as many tricks as your Call, you score points equal to your Call PLUS 0.1 for each extra trick won.\n'
                '   Example: Called 3, won 4 tricks → Score = 3.1\n'
                '   Example: Called 4, won 4 tricks → Score = 4.0\n'
                '• BREAKING / FAILING: If you win fewer tricks than your Call, you lose points equal to your full Call.\n'
                '   Example: Called 4, won 3 tricks → Score = -4.0 penalty!\n'
                '• The match continues for 5 rounds (or 3/7). The player with the highest total score wins.',
          ),
          const SizedBox(height: 16),
          _buildRuleSection(
            icon: Icons.lightbulb_outline,
            title: '6. Pro Strategy & Tips',
            content:
                '• Cash side Aces early: Lead off-suit Aces early before opponents run out of cards and trump them.\n'
                '• Conserve High Trumps: Don\'t waste the Ace or King of Spades on weak tricks unless necessary.\n'
                '• Duck safely: If you already reached your Call, play small cards to avoid winning unwanted overtricks (which only give 0.1 points).\n'
                '• Count Cards: Pay attention to who ran out of which suits to know when it is safe to lead high cards.',
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B25), Color(0xFF1D5A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('♠', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 32)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Call Bridge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'The Queen of Trick-Taking Games',
                      style: TextStyle(color: Color(0xFFFBBF24), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Call Bridge (also known as CallBreak) is a strategic trick-taking card game played across Bangladesh, India, and Nepal. Master the art of bidding, smart trumping, and score accumulation over 5 thrilling rounds!',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleSection({
    required IconData icon,
    required String title,
    required String content,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? const Color(0xFFFBBF24) : Colors.white12,
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: highlight ? const Color(0xFFFBBF24) : const Color(0xFF60A5FA), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
