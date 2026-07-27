import 'package:flutter/material.dart';
import 'history_storage.dart';
import 'theme_state.dart';
import 'categories.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameHistory> _history = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    final history = await HistoryStorage.getHistory();
    setState(() {
      _history = history.reversed.toList();
      _isLoading = false;
    });
  }
  
  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await HistoryStorage.clearHistory();
      _loadHistory();
    }
  }
  
  String _getCategoryName(String categoryId, String lang) {
    for (final cat in categories) {
      if (cat.id == categoryId) {
        return cat.getName(lang);
      }
    }
    return categoryId;
  }
  
  IconData _getCategoryIcon(String categoryId) {
    for (final cat in categories) {
      if (cat.id == categoryId) {
        return cat.icon;
      }
    }
    return Icons.category;
  }
  
  Color _getCategoryColor(String categoryId) {
    for (final cat in categories) {
      if (cat.id == categoryId) {
        return cat.color;
      }
    }
    return Colors.grey;
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, _) {
        final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
        final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'History',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
            actions: [
              if (_history.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: textColor),
                  onPressed: _clearHistory,
                ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: textColor))
              : _history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: subtitleColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No words guessed yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Win a game to see your history',
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final entry = _history[index];
                        final categoryColor = _getCategoryColor(entry.category);
                        final categoryName = _getCategoryName(entry.category, entry.language);
                        final categoryIcon = _getCategoryIcon(entry.category);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: categoryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  categoryIcon,
                                  color: categoryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.word,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$categoryName · ${entry.attempts}/6 attempts',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(entry.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
