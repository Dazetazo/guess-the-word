import 'package:flutter/material.dart';
import 'theme_state.dart';
import 'main_menu.dart';
import 'ad_banner.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, _) {
        final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: textColor,
                        size: 28,
                      ),
                      onPressed: () {
                        themeNotifier.value = !themeNotifier.value;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'WORDMIX',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Elige tu idioma',
                          style: TextStyle(
                            fontSize: 18,
                            color: subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LanguageButton(
                              flag: '🇺🇸',
                              label: 'English',
                              color: const Color(0xFF0984E3),
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainMenu(language: 'en'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 32),
                            _LanguageButton(
                              flag: '🇪🇸',
                              label: 'Español',
                              color: const Color(0xFFE17055),
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainMenu(language: 'es'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
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
}

class _LanguageButton extends StatelessWidget {
  final String flag;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  
  const _LanguageButton({
    required this.flag,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
