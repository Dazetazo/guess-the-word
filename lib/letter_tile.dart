import 'package:flutter/material.dart';
import 'game_logic.dart';

class LetterTile extends StatefulWidget {
  final String letter;
  final LetterState? state;
  final bool isAnimating;
  final int animationDelay;
  final bool isDark;
  final double size;
  
  const LetterTile({
    super.key,
    required this.letter,
    this.state,
    this.isAnimating = false,
    this.animationDelay = 0,
    this.isDark = true,
    this.size = 60,
  });
  
  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _hasAnimated = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isAnimating && !_hasAnimated) {
      _scheduleAnimation();
    }
  }
  
  void _scheduleAnimation() {
    Future.delayed(Duration(milliseconds: widget.animationDelay * 350), () {
      if (mounted && !_hasAnimated) {
        _hasAnimated = true;
        _controller.forward();
      }
    });
  }
  
  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating && !_hasAnimated) {
      _scheduleAnimation();
    }
    if (!widget.isAnimating && oldWidget.isAnimating) {
      _hasAnimated = false;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Color _getBackgroundColor() {
    if (widget.state == null) {
      return widget.isDark ? Colors.grey[800]! : Colors.grey[300]!;
    }
    
    switch (widget.state!) {
      case LetterState.correct:
        return const Color(0xFF538D4E);
      case LetterState.present:
        return const Color(0xFFB59F3B);
      case LetterState.absent:
        return widget.isDark ? Colors.grey[700]! : Colors.grey[500]!;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final hasSubmitted = widget.state != null;
    final emptyTileColor = widget.isDark ? Colors.grey[800] : Colors.grey[200];
    final emptyBorderColor = widget.isDark ? Colors.grey[600]! : Colors.grey[400]!;
    final tileBorderColor = widget.isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    
    final fontSize = widget.size * 0.5;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _hasAnimated ? _scaleAnim.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            margin: EdgeInsets.all(widget.size * 0.067),
            decoration: BoxDecoration(
              color: _hasAnimated ? _getBackgroundColor() 
                  : (widget.letter.isNotEmpty ? emptyTileColor : Colors.transparent),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: hasSubmitted
                    ? _getBackgroundColor()
                    : (widget.letter.isNotEmpty ? tileBorderColor : emptyBorderColor),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.letter.toUpperCase(),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: _hasAnimated ? Colors.white : textColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
