import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../services/stats_storage.dart';
import 'game_screen.dart';
import 'scorekeeper_screen.dart';
import 'rules_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameSettings _settings = const GameSettings();

  @override
  Widget build(BuildContext context) {
    final stats = StatsService().stats;

    return Scaffold(
      backgroundColor: const Color(0xFF091220),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Top Bar with Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFBBF24), width: 1),
                      ),
                      child: const Text('♠', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CALL BRIDGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                          currentSettings: _settings,
                          onSettingsChanged: (s) => setState(() => _settings = s),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Hero Table Banner
            _buildHeroBanner(stats),

            const SizedBox(height: 24),

            // Primary Action: Play vs Bots
            _buildPrimaryGameButton(
              title: 'Play vs Bots',
              subtitle: '4-Player match against smart AI (${_settings.aiDifficulty.displayName})',
              icon: Icons.smart_toy_outlined,
              gradientColors: [const Color(0xFF0F5132), const Color(0xFF198754)],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      mode: GameMode.vsBots,
                      settings: _settings,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // Secondary Game: Pass & Play
            _buildMenuCard(
              title: 'Pass & Play (4 Players)',
              subtitle: 'Play locally on one device with friends',
              icon: Icons.phone_android_rounded,
              iconColor: const Color(0xFF38BDF8),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      mode: GameMode.passAndPlay,
                      settings: _settings,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Tool: Standalone Table Scorekeeper
            _buildMenuCard(
              title: 'Physical Card Scorekeeper',
              subtitle: 'Digital calculator & scorecard for real card sessions',
              icon: Icons.scoreboard_outlined,
              iconColor: const Color(0xFFFBBF24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScorekeeperScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            // Grid: Rules & Guide + Career Stats
            Row(
              children: [
                Expanded(
                  child: _buildGridCard(
                    title: 'Rules & Guide',
                    subtitle: 'Spades trump & calls',
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFFA78BFA),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RulesScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridCard(
                    title: 'Career Stats',
                    subtitle: '${stats.gamesWon} wins recorded',
                    icon: Icons.leaderboard_rounded,
                    iconColor: const Color(0xFF34D399),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StatsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick rules refresher pill
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Spades (♠) is ALWAYS permanent Trump. Make your call to earn points; breaking drops your score!',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(UserGameStats stats) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _settings.feltTheme.baseColor,
            _settings.feltTheme.darkColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CLASSIC 52 DECK',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Row(
                children: [
                  const Text('♠', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(width: 4),
                  Text('♥', style: TextStyle(color: Colors.red[300], fontSize: 18)),
                  const SizedBox(width: 4),
                  const Text('♣', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(width: 4),
                  Text('♦', style: TextStyle(color: Colors.amber[300], fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Call Bridge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '4 Players • 13 Cards Each • Permanent Spades Trump',
            style: TextStyle(
              color: Color(0xFFFBBF24),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Mini Stat Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(90),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('Win Rate', '${stats.winRate.toStringAsFixed(0)}%'),
                Container(height: 24, width: 1, color: Colors.white24),
                _miniStat('Total Tricks', '${stats.totalTricksWon}'),
                Container(height: 24, width: 1, color: Colors.white24),
                _miniStat('Top Match', '${stats.highestMatchScore.toStringAsFixed(1)} pts'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildPrimaryGameButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withAlpha(90),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBBF24),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 26),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
