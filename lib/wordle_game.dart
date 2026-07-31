import 'package:flutter/material.dart';
import 'categories.dart';
import 'game_logic.dart';
import 'letter_tile.dart';
import 'keyboard.dart';
import 'theme_state.dart';
import 'history_storage.dart';
import 'daily_limit.dart';
import 'ad_banner.dart';
import 'dictionary.dart';

class WordleGame extends StatefulWidget {
  final WordleCategory category;
  final String language;
  
  const WordleGame({super.key, required this.category, required this.language});
  
  @override
  State<WordleGame> createState() => _WordleGameState();
}

class _WordleGameState extends State<WordleGame> {
  late GameLogic _gameLogic;
  String _currentGuess = '';
  bool _showInvalidWordMessage = false;
  bool _showInvalidWordLengthMessage = false;
  bool _isAnimating = false;
  int _animatingRow = -1;
  
  @override
  void initState() {
    super.initState();
    _gameLogic = GameLogic(
      wordList: widget.category.getWords(widget.language),
      dictionary: widget.language == 'es' ? WordDictionary.spanish : WordDictionary.english,
    );
    _startNewGame();
  }
  
  void _startNewGame() {
    setState(() {
      _gameLogic.resetGame(
        wordList: widget.category.getWords(widget.language),
        dictionary: widget.language == 'es' ? WordDictionary.spanish : WordDictionary.english,
      );
      _currentGuess = '';
      _showInvalidWordMessage = false;
      _showInvalidWordLengthMessage = false;
      _isAnimating = false;
      _animatingRow = -1;
    });
  }
  
  void _onKeyPressed(String key) {
    if (_isAnimating || _gameLogic.isGameOver) return;
    
    setState(() {
      if (_currentGuess.length < _gameLogic.wordLength) {
        _currentGuess += key;
        _showInvalidWordMessage = false;
        _showInvalidWordLengthMessage = false;
      }
    });
  }
  
  void _onDeletePressed() {
    if (_isAnimating || _gameLogic.isGameOver) return;
    
    setState(() {
      if (_currentGuess.isNotEmpty) {
        _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
        _showInvalidWordMessage = false;
        _showInvalidWordLengthMessage = false;
      }
    });
  }
  
  void _onEnterPressed() {
    if (_isAnimating || _gameLogic.isGameOver) return;
    
    setState(() {
      _showInvalidWordMessage = false;
      _showInvalidWordLengthMessage = false;
      
      if (_currentGuess.length != _gameLogic.wordLength) {
        _showInvalidWordLengthMessage = true;
        return;
      }
      
      if (!_gameLogic.isValidWord(_currentGuess)) {
        _showInvalidWordMessage = true;
        return;
      }
      
      _isAnimating = true;
      _animatingRow = _gameLogic.currentAttempt;
      
      bool success = _gameLogic.submitGuess(_currentGuess);
      
      if (success) {
        _currentGuess = '';
        
        final isDark = themeNotifier.value;
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) {
            setState(() {
              _isAnimating = false;
              _animatingRow = -1;
            });
            
            if (_gameLogic.isGameOver) {
              _showGameOverDialog(isDark);
            }
          }
        });
      }
    });
  }
  
  void _showGameOverDialog(bool isDark) {
    DailyLimitStorage.recordPlay(widget.category.id);
    final dialogBg = isDark ? Colors.grey[900] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black87;
    final isEs = widget.language == 'es';
    
    if (_gameLogic.hasWon) {
      HistoryStorage.addEntry(GameHistory(
        word: _gameLogic.targetWord,
        category: widget.category.id,
        language: widget.language,
        date: DateTime.now(),
        attempts: _gameLogic.currentAttempt,
      ));
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text(
          _gameLogic.hasWon 
              ? (isEs ? '¡Felicidades!' : 'Congratulations!')
              : (isEs ? 'Juego Terminado' : 'Game Over'),
          style: TextStyle(color: textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _gameLogic.hasWon 
                  ? (isEs 
                      ? '¡Adivinaste en ${_gameLogic.currentAttempt} intentos!'
                      : 'You guessed it in ${_gameLogic.currentAttempt} attempts!')
                  : (isEs 
                      ? 'La palabra era: ${_gameLogic.targetWord}'
                      : 'The word was: ${_gameLogic.targetWord}'),
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (_gameLogic.hasWon)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _gameLogic.currentAttempt,
                  (index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: Text(
              isEs ? 'Jugar de Nuevo' : 'Play Again',
              style: TextStyle(color: textColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              isEs ? 'Menú Principal' : 'Main Menu',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final tileSize = (screenWidth - 40) / _gameLogic.wordLength;
        final clampedSize = tileSize.clamp(30.0, 65.0);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(GameLogic.maxAttempts, (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_gameLogic.wordLength, (colIndex) {
                String letter = '';
                LetterState? state;
                bool isAnimating = false;
                
                if (rowIndex < _gameLogic.guesses.length) {
                  letter = _gameLogic.guesses[rowIndex][colIndex];
                  state = _gameLogic.letterStates[rowIndex][colIndex];
                  isAnimating = rowIndex == _animatingRow;
                } else if (rowIndex == _gameLogic.currentAttempt) {
                  if (colIndex < _currentGuess.length) {
                    letter = _currentGuess[colIndex];
                  }
                }
                
                return LetterTile(
                  letter: letter,
                  state: state,
                  isAnimating: isAnimating,
                  animationDelay: colIndex,
                  isDark: isDark,
                  size: clampedSize,
                );
              }),
            );
          }),
        );
      },
    );
  }
  
  Widget _buildMessage(bool isDark) {
    final messageColor = isDark ? Colors.white : Colors.black87;
    final isEs = widget.language == 'es';
    
    if (_showInvalidWordMessage) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          isEs ? 'Palabra no válida' : 'Not in word list',
          style: TextStyle(
            color: messageColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    if (_showInvalidWordLengthMessage) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          isEs ? 'Faltan letras' : 'Not enough letters',
          style: TextStyle(
            color: messageColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    return const SizedBox(height: 34);
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, _) {
        final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final appBarColor = isDark ? const Color(0xFF121212) : Colors.white;
        final dialogBg = isDark ? Colors.grey[900] : Colors.grey[100];
        final dialogTextColor = isDark ? Colors.white : Colors.black87;
        
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: appBarColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.category.icon, color: widget.category.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.category.getName(widget.language).toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: textColor,
                ),
                onPressed: () {
                  themeNotifier.value = !themeNotifier.value;
                },
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: textColor),
                onPressed: () {
                  final isEs = widget.language == 'es';
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: dialogBg,
                      title: Text(
                        isEs ? 'Cómo Jugar' : 'How to Play',
                        style: TextStyle(color: dialogTextColor),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEs 
                                ? 'Adivina la palabra en 6 intentos.'
                                : 'Guess the word in 6 tries.',
                            style: TextStyle(color: dialogTextColor),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isEs 
                                ? 'Cada intento debe ser una palabra válida de ${_gameLogic.wordLength} letras.'
                                : 'Each guess must be a valid ${_gameLogic.wordLength}-letter word.',
                            style: TextStyle(color: dialogTextColor),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isEs 
                                ? 'Después de cada intento, el color de las casillas cambiará:'
                                : 'After each guess, the color of the tiles will change:',
                            style: TextStyle(color: dialogTextColor),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.circle, color: Color(0xFF538D4E), size: 20),
                              const SizedBox(width: 10),
                              Text(isEs 
                                  ? 'Verde: Letra correcta en posición correcta'
                                  : 'Green: Correct letter in correct position', 
                                   style: TextStyle(color: dialogTextColor)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.circle, color: Color(0xFFB59F3B), size: 20),
                              const SizedBox(width: 10),
                              Text(isEs 
                                  ? 'Amarillo: Letra correcta en posición incorrecta'
                                  : 'Yellow: Correct letter in wrong position', 
                                   style: TextStyle(color: dialogTextColor)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.circle, color: isDark ? Colors.grey : Colors.grey[500], size: 20),
                              const SizedBox(width: 10),
                              Text(isEs 
                                  ? 'Gris: Letra no está en la palabra'
                                  : 'Gray: Letter not in the word', 
                                   style: TextStyle(color: dialogTextColor)),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            isEs ? '¡Entendido!' : 'Got it!',
                            style: TextStyle(color: dialogTextColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: textColor),
                onPressed: _startNewGame,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: _buildGrid(isDark),
                  ),
                ),
                _buildMessage(isDark),
                const SizedBox(height: 10),
                Keyboard(
                  onKeyPressed: _onKeyPressed,
                  onEnterPressed: _onEnterPressed,
                  onDeletePressed: _onDeletePressed,
                  keyStates: _gameLogic.keyboardStates,
                  isDisabled: _isAnimating || _gameLogic.isGameOver,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                const BannerAdWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
