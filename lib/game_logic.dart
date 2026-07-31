import 'dart:math';

enum LetterState { absent, present, correct }

class GameLogic {
  static const int maxAttempts = 6;
  
  late String _targetWord;
  late int _wordLength;
  late List<String> _wordList;
  late Set<String>? _dictionary;
  List<String> _guesses = [];
  List<List<LetterState>> _letterStates = [];
  int _currentAttempt = 0;
  bool _isGameOver = false;
  bool _hasWon = false;
  Map<String, LetterState> _keyboardStates = {};
  
  GameLogic({List<String>? wordList, Set<String>? dictionary}) {
    _wordList = wordList ?? _defaultWordList;
    _dictionary = dictionary;
    _initGame();
  }
  
  void _initGame() {
    final random = Random();
    _targetWord = _wordList[random.nextInt(_wordList.length)];
    _wordLength = _targetWord.length;
    _guesses = [];
    _letterStates = [];
    _currentAttempt = 0;
    _isGameOver = false;
    _hasWon = false;
    _keyboardStates = {};
  }
  
  void resetGame({List<String>? wordList, Set<String>? dictionary}) {
    if (wordList != null) {
      _wordList = wordList;
    }
    if (dictionary != null) {
      _dictionary = dictionary;
    }
    _initGame();
  }
  
  String get targetWord => _targetWord;
  int get wordLength => _wordLength;
  List<String> get guesses => _guesses;
  List<List<LetterState>> get letterStates => _letterStates;
  int get currentAttempt => _currentAttempt;
  bool get isGameOver => _isGameOver;
  bool get hasWon => _hasWon;
  Map<String, LetterState> get keyboardStates => _keyboardStates;
  
  bool isValidWord(String word) {
    final w = word.toUpperCase();
    if (_wordList.contains(w)) return true;
    if (_dictionary != null && _dictionary!.contains(w)) return true;
    return false;
  }
  
  bool submitGuess(String guess) {
    if (_isGameOver || _currentAttempt >= maxAttempts) {
      return false;
    }
    
    guess = guess.toUpperCase();
    if (guess.length != _wordLength) {
      return false;
    }
    
    if (!isValidWord(guess)) {
      return false;
    }
    
    _guesses.add(guess);
    List<LetterState> states = List.filled(_wordLength, LetterState.absent);
    
    // First pass: mark correct letters
    for (int i = 0; i < _wordLength; i++) {
      if (guess[i] == _targetWord[i]) {
        states[i] = LetterState.correct;
      }
    }
    
    // Second pass: mark present letters
    for (int i = 0; i < _wordLength; i++) {
      if (states[i] == LetterState.correct) {
        continue;
      }
      
      for (int j = 0; j < _wordLength; j++) {
        if (guess[i] == _targetWord[j] && states[j] != LetterState.correct && states[j] != LetterState.present) {
          states[i] = LetterState.present;
          break;
        }
      }
    }
    
    _letterStates.add(states);
    
    // Update keyboard states
    for (int i = 0; i < _wordLength; i++) {
      String letter = guess[i];
      LetterState newState = states[i];
      
      if (_keyboardStates.containsKey(letter)) {
        LetterState currentState = _keyboardStates[letter]!;
        if (newState == LetterState.correct || 
            (newState == LetterState.present && currentState != LetterState.correct)) {
          _keyboardStates[letter] = newState;
        }
      } else {
        _keyboardStates[letter] = newState;
      }
    }
    
    _currentAttempt++;
    
    if (guess == _targetWord) {
      _hasWon = true;
      _isGameOver = true;
    } else if (_currentAttempt >= maxAttempts) {
      _isGameOver = true;
    }
    
    return true;
  }
  
  String getHint() {
    if (_currentAttempt == 0) {
      return 'Try to guess the word!';
    }
    
    List<String> hints = [];
    for (int i = 0; i < _wordLength; i++) {
      bool found = false;
      for (int j = 0; j < _currentAttempt; j++) {
        if (_letterStates[j][i] == LetterState.correct) {
          hints.add('${_targetWord[i]} is in position ${i + 1}');
          found = true;
          break;
        }
      }
      if (!found) {
        hints.add('Position ${i + 1} is unknown');
      }
    }
    
    return hints.join('\n');
  }
  
  static const List<String> _defaultWordList = [
    'APPLE', 'BEACH', 'BRAIN', 'BREAD', 'BRUSH', 'CANDY',
    'CHAIR', 'CHAMP', 'CHART', 'CHASE', 'CHESS', 'CLOUD',
    'CORAL', 'CREAM', 'DANCE', 'DEATH', 'DIARY', 'DRAFT',
    'DREAM', 'DRINK', 'EAGLE', 'EARTH', 'FEAST', 'FLAME',
    'FLASH', 'FLOAT', 'FLOWER', 'FOCUS', 'FORCE', 'FRAME',
    'GHOST', 'GIANT', 'GLOBE', 'GRACE', 'GRAIN', 'GRAND',
    'GRASS', 'GRAVE', 'GREEN', 'GREET', 'GROSS', 'GROUP',
    'GROWN', 'GUARD', 'GUESS', 'GUEST', 'HAPPY', 'HEART',
    'HONEY', 'HORSE', 'HOTEL', 'HOUSE', 'HUMAN', 'IDEAL',
    'IMAGE', 'INDEX', 'INNER', 'INPUT', 'JELLY', 'JEWEL',
    'JUDGE', 'JUICE', 'KNOCK', 'KNIFE', 'KNOWN', 'LABEL',
    'LARGE', 'LASER', 'LATER', 'LEARN', 'LEVEL', 'LIGHT',
    'LIMIT', 'LINEN', 'LIVER', 'LOCAL', 'LOGIC', 'LOVER',
    'LOWER', 'LUCKY', 'LUNCH', 'MAGIC', 'MAJOR', 'MAKER',
    'MANGO', 'MAPLE', 'MATCH', 'MAYOR', 'MEDAL', 'MEDIA',
    'METAL', 'MIGHT', 'MINOR', 'MODEL', 'MONEY', 'MONTH',
    'MORAL', 'MOTOR', 'MOUNT', 'MOUSE', 'MOUTH', 'MOVIE',
    'MUSIC', 'NERVE', 'NIGHT', 'NOISE', 'NORTH', 'NOVEL',
    'NURSE', 'OCEAN', 'OFFER', 'OLIVE', 'ONSET', 'OPERA',
    'ORBIT', 'ORDER', 'OTHER', 'OUTER', 'OWNER', 'OZONE',
    'PAINT', 'PANEL', 'PANIC', 'PAPER', 'PATCH', 'PAUSE',
    'PEACH', 'PENNY', 'PHASE', 'PHONE', 'PHOTO', 'PIANO',
    'PIECE', 'PILOT', 'PINCH', 'PITCH', 'PIZZA', 'PLACE',
    'PLAIN', 'PLANE', 'PLANT', 'PLATE', 'PLAZA', 'PLEAD',
    'POINT', 'POISE', 'POLAR', 'POWER', 'PRESS', 'PRICE',
    'PRIDE', 'PRIME', 'PRINT', 'PRIZE', 'PROOF', 'PROUD',
    'PROVE', 'PUNCH', 'PUPIL', 'QUEEN', 'QUERY', 'QUEST',
    'QUICK', 'QUIET', 'QUOTA', 'QUOTE', 'RADAR', 'RADIO',
    'RAISE', 'RALLY', 'RANCH', 'RANGE', 'RAPID', 'RATIO',
    'REACH', 'READY', 'REBEL', 'REFER', 'REIGN', 'RELAX',
    'REPLY', 'RIDER', 'RIDGE', 'RIFLE', 'RIGHT', 'RIGID',
    'RISKY', 'RIVAL', 'RIVER', 'ROBOT', 'ROCKY', 'ROMAN',
    'ROUGH', 'ROUND', 'ROUTE', 'ROYAL', 'RUGBY', 'RULER',
    'RURAL', 'SADLY', 'SAINT', 'SALAD', 'SCALE', 'SCENE',
    'SCENT', 'SCOPE', 'SCORE', 'SCOUT', 'SCRAP', 'SENSE',
    'SERVE', 'SEVEN', 'SHADE', 'SHAKE', 'SHALL', 'SHAME',
    'SHAPE', 'SHARE', 'SHARK', 'SHARP', 'SHAVE', 'SHEEP',
    'SHEER', 'SHEET', 'SHELF', 'SHELL', 'SHIFT', 'SHINE',
    'SHIRT', 'SHOCK', 'SHOOT', 'SHORE', 'SHORT', 'SHOUT',
    'SIGHT', 'SIXTH', 'SIXTY', 'SKILL', 'SKULL', 'SLAVE',
    'SLEEP', 'SLICE', 'SLIDE', 'SLOPE', 'SMALL', 'SMART',
    'SMELL', 'SMILE', 'SMOKE', 'SNAKE', 'SOLAR', 'SOLID',
    'SOLVE', 'SORRY', 'SOUND', 'SOUTH', 'SPACE', 'SPARE',
    'SPARK', 'SPEAK', 'SPEED', 'SPELL', 'SPEND', 'SPICE',
    'SPINE', 'SPLIT', 'SPOKE', 'SPORT', 'SPRAY', 'SQUAD',
    'STACK', 'STAFF', 'STAGE', 'STAIN', 'STAKE', 'STALE',
    'STAMP', 'STAND', 'STARE', 'START', 'STATE', 'STAVE',
    'STAYS', 'STEAK', 'STEAL', 'STEAM', 'STEEL', 'STEEP',
    'STEER', 'STICK', 'STIFF', 'STILL', 'STOCK', 'STONE',
    'STOOD', 'STORE', 'STORM', 'STORY', 'STOUT', 'STOVE',
    'STRIP', 'STUCK', 'STUDY', 'STUFF', 'STYLE', 'SUGAR',
    'SUNNY', 'SUPER', 'SURGE', 'SWAMP', 'SWEAR', 'SWEAT',
    'SWEEP', 'SWEET', 'SWIFT', 'SWING', 'SWORD', 'SWEPT',
    'TABLE', 'TASTE', 'TEACH', 'TEETH', 'TEMPO', 'THANK',
    'THEFT', 'THEIR', 'THEME', 'THERE', 'THICK', 'THIEF',
    'THING', 'THINK', 'THIRD', 'THOSE', 'THREE', 'THREW',
    'THROW', 'TIGER', 'TIGHT', 'TIMER', 'TIRED', 'TITLE',
    'TODAY', 'TOKEN', 'TOOTH', 'TOPIC', 'TOTAL', 'TOUCH',
    'TOUGH', 'TOWER', 'TOXIC', 'TRACE', 'TRACK', 'TRADE',
    'TRAIL', 'TRAIN', 'TRAIT', 'TRASH', 'TREAT', 'TREND',
    'TRIAL', 'TRIBE', 'TRICK', 'TRIED', 'TROOP', 'TRUCK',
    'TRULY', 'TRUMP', 'TRUNK', 'TRUST', 'TRUTH', 'TUMOR',
    'TWICE', 'TWIST', 'ULTRA', 'UNCLE', 'UNDER', 'UNIFY',
    'UNION', 'UNITE', 'UNITY', 'UNTIL', 'UPPER', 'UPSET',
    'URBAN', 'USAGE', 'USUAL', 'UTTER', 'VALID', 'VALUE',
    'VALVE', 'VAULT', 'VERSE', 'VIDEO', 'VIGOR', 'VIRAL',
    'VIRUS', 'VISIT', 'VISTA', 'VITAL', 'VIVID', 'VOCAL',
    'VOICE', 'VOTER', 'WASTE', 'WATCH', 'WATER', 'WEARY',
    'WEAVE', 'WEDGE', 'WHEAT', 'WHEEL', 'WHERE', 'WHICH',
    'WHILE', 'WHITE', 'WHOLE', 'WHOSE', 'WIDER', 'WIDTH',
    'WITCH', 'WOMAN', 'WORLD', 'WORRY', 'WORSE', 'WORST',
    'WORTH', 'WOULD', 'WOUND', 'WRATH', 'WRITE', 'WRONG',
    'WROTE', 'YACHT', 'YIELD', 'YOUNG', 'YOURS', 'YOUTH',
    'ZEBRA', 'ZONES',
  ];
}
