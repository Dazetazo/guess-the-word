import 'package:flutter/material.dart';
import 'categories.dart';
import 'theme_state.dart';
import 'wordle_game.dart';
import 'history_screen.dart';
import 'daily_limit.dart';
import 'ad_banner.dart';
import 'rewarded_ad.dart';

class MainMenu extends StatefulWidget {
  final String language;
  
  const MainMenu({super.key, required this.language});
  
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Map<String, bool> _playedToday = {};
  
  @override
  void initState() {
    super.initState();
    _loadDailyLimits();
  }
  
  Future<void> _loadDailyLimits() async {
    final played = <String, bool>{};
    for (final cat in categories) {
      played[cat.id] = await DailyLimitStorage.hasPlayedToday(cat.id);
    }
    setState(() {
      _playedToday = played;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, _) {
        final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
        final descColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        
        final isEs = widget.language == 'es';
        
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.history, color: textColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: textColor,
                ),
                onPressed: () {
                  themeNotifier.value = !themeNotifier.value;
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'WORDMIX',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEs ? 'Selecciona una categoría' : 'Select a category',
                  style: TextStyle(
                    fontSize: 16,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isPlayed = _playedToday[category.id] ?? false;
                        return _CategoryCard(
                          category: category,
                          lang: widget.language,
                          cardBg: cardBg,
                          descColor: descColor,
                          isPlayedToday: isPlayed,
                          isEs: isEs,
                          onTap: () {
                            if (isPlayed) {
                              _showUnlockDialog(context, category, isEs);
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WordleGame(
                                  category: category,
                                  language: widget.language,
                                ),
                              ),
                            ).then((_) => _loadDailyLimits());
                          },
                        );
                      },
                    ),
                  ),
                ),
                const BannerAdWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUnlockDialog(BuildContext context, WordleCategory category, bool isEs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEs ? 'Límite diario' : 'Daily limit'),
        content: Text(
          isEs
              ? 'Ya jugaste esta categoría hoy. ¿Quieres ver un anuncio para desbloquearla y jugar otra palabra?'
              : 'You already played this category today. Want to watch an ad to unlock it and play another word?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isEs ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final rewarded = await RewardedAdManager.showAd();
              if (!rewarded) return;
              if (!context.mounted) return;
              await DailyLimitStorage.clearPlay(category.id);
              await _loadDailyLimits();
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordleGame(
                    category: category,
                    language: widget.language,
                  ),
                ),
              ).then((_) => _loadDailyLimits());
            },
            child: Text(
              isEs ? 'Ver anuncio' : 'Watch ad',
              style: const TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final WordleCategory category;
  final String lang;
  final Color cardBg;
  final Color descColor;
  final VoidCallback onTap;
  final bool isPlayedToday;
  final bool isEs;
  
  const _CategoryCard({
    required this.category,
    required this.lang,
    required this.cardBg,
    required this.descColor,
    required this.onTap,
    this.isPlayedToday = false,
    this.isEs = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final opacity = isPlayedToday ? 0.6 : 1.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlayedToday
                  ? Colors.grey.withValues(alpha: 0.3)
                  : category.color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      size: 40,
                      color: category.color,
                    ),
                  ),
                  if (isPlayedToday)
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 36,
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                category.getName(lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  isPlayedToday
                      ? (isEs ? 'Ya jugado hoy' : 'Played today')
                      : category.getDescription(lang),
                  style: TextStyle(
                    fontSize: 12,
                    color: isPlayedToday ? Colors.grey : descColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isPlayedToday
                      ? Colors.grey.withValues(alpha: 0.2)
                      : category.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPlayedToday
                      ? (isEs ? '🔒 Ver anuncio' : '🔒 Watch ad')
                      : '${category.getWords(lang).length} ${lang == 'es' ? 'palabras' : 'words'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isPlayedToday ? Colors.amber : category.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isPlayedToday)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    isEs ? 'Toca para desbloquear' : 'Tap to unlock',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.amber.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
