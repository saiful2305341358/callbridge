import 'package:flutter/material.dart';
import '../../models/game_state.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings currentSettings;
  final ValueChanged<GameSettings> onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.currentSettings;
  }

  void _update(GameSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Game Settings & Styles', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Table Felt Theme Selector
          _sectionHeader('Table Felt Surface'),
          const SizedBox(height: 10),
          Row(
            children: TableFeltTheme.values.map((felt) {
              final isSelected = _settings.feltTheme == felt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _update(_settings.copyWith(feltTheme: felt)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: felt.baseColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFBBF24) : Colors.white24,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFBBF24).withAlpha(120),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: felt.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          felt.displayName.split(' ').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 2. Card Back Style Selector
          _sectionHeader('Card Back Pattern'),
          const SizedBox(height: 10),
          Row(
            children: CardBackTheme.values.map((theme) {
              final isSelected = _settings.cardBackTheme == theme;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _update(_settings.copyWith(cardBackTheme: theme)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.accent, theme.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFBBF24) : Colors.white24,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('♠', style: TextStyle(color: Colors.white, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          theme.displayName.split(' ').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 3. Rounds Count
          _sectionHeader('Total Match Rounds'),
          const SizedBox(height: 10),
          Row(
            children: [3, 5, 7, 10].map((rounds) {
              final isSelected = _settings.totalRounds == rounds;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      '$rounds Rnds',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFBBF24),
                    backgroundColor: const Color(0xFF1E293B),
                    onSelected: (val) {
                      if (val) _update(_settings.copyWith(totalRounds: rounds));
                    },
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 4. AI Difficulty
          _sectionHeader('AI Bots Difficulty'),
          const SizedBox(height: 10),
          ...AIDifficulty.values.map((diff) {
            final isSelected = _settings.aiDifficulty == diff;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFBBF24) : Colors.white12,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: RadioListTile<AIDifficulty>(
                value: diff,
                groupValue: _settings.aiDifficulty,
                activeColor: const Color(0xFFFBBF24),
                title: Text(
                  diff.displayName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  diff.description,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                onChanged: (val) {
                  if (val != null) _update(_settings.copyWith(aiDifficulty: val));
                },
              ),
            );
          }),

          const SizedBox(height: 24),

          // 5. Extra Trick Bonus
          _sectionHeader('Scoring System'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                RadioListTile<double>(
                  value: 0.1,
                  groupValue: _settings.extraTrickBonus,
                  activeColor: const Color(0xFFFBBF24),
                  title: const Text('Standard (0.1 pt per extra trick)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Called 3, won 4 → 3.1 pts (Standard Call Bridge)', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  onChanged: (val) {
                    if (val != null) _update(_settings.copyWith(extraTrickBonus: val));
                  },
                ),
                RadioListTile<double>(
                  value: 1.0,
                  groupValue: _settings.extraTrickBonus,
                  activeColor: const Color(0xFFFBBF24),
                  title: const Text('Whole Point (1.0 pt per extra trick)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Called 3, won 4 → 4.0 pts', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  onChanged: (val) {
                    if (val != null) _update(_settings.copyWith(extraTrickBonus: val));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 6. Audio & Haptics Toggles
          _sectionHeader('Tactile & Feedback'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Haptic Vibration Feedback', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Vibrations on card tap, bids, and trick wins', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: _settings.hapticsEnabled,
                  activeColor: const Color(0xFFFBBF24),
                  onChanged: (val) => _update(_settings.copyWith(hapticsEnabled: val)),
                ),
                const Divider(color: Colors.white12, height: 1),
                SwitchListTile(
                  title: const Text('Strict Trump Rule', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Must play higher Trump than current table trump if possible', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: _settings.strictTrumpRule,
                  activeColor: const Color(0xFFFBBF24),
                  onChanged: (val) => _update(_settings.copyWith(strictTrumpRule: val)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFBBF24),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}
