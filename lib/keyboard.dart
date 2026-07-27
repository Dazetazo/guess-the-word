import 'package:flutter/material.dart';
import 'game_logic.dart';

class Keyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final Function() onEnterPressed;
  final Function() onDeletePressed;
  final Map<String, LetterState> keyStates;
  final bool isDisabled;
  final bool isDark;
  
  const Keyboard({
    super.key,
    required this.onKeyPressed,
    required this.onEnterPressed,
    required this.onDeletePressed,
    required this.keyStates,
    this.isDisabled = false,
    this.isDark = true,
  });
  
  Color _getKeyColor(String key) {
    if (!keyStates.containsKey(key)) {
      return isDark ? Colors.grey[800]! : Colors.grey[300]!;
    }
    
    switch (keyStates[key]!) {
      case LetterState.correct:
        return const Color(0xFF538D4E);
      case LetterState.present:
        return const Color(0xFFB59F3B);
      case LetterState.absent:
        return isDark ? Colors.grey[700]! : Colors.grey[400]!;
    }
  }
  
  Widget _buildKey(String key, {double width = 32}) {
    final isSpecialKey = key == 'ENTER' || key == 'DEL';
    final displayText = key == 'DEL' ? '⌫' : key;
    final specialKeyColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return GestureDetector(
      onTap: isDisabled ? null : () {
        if (key == 'ENTER') {
          onEnterPressed();
        } else if (key == 'DEL') {
          onDeletePressed();
        } else {
          onKeyPressed(key);
        }
      },
      child: Container(
        width: width,
        height: 50,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSpecialKey ? specialKeyColor : _getKeyColor(key),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: isSpecialKey ? 14 : 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'
          ].map((key) => _buildKey(key)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'
          ].map((key) => _buildKey(key)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey('ENTER', width: 56),
            ...['Z', 'X', 'C', 'V', 'B', 'N', 'M']
                .map((key) => _buildKey(key)),
            _buildKey('DEL', width: 56),
          ],
        ),
      ],
    );
  }
}
