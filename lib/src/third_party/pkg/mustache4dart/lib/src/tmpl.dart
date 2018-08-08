part of mustache4dart;

class _Template {
  final _TokenList list;

  factory _Template(
      {String template, Delimiter delimiter, String ident, Function partial}) {
    if (template == null) {
      throw new FormatException("The given template is null");
    }
    _TokenList tokens = new _TokenList(delimiter, ident);

    bool searchForOpening = true;
    for (int i = 0; i < template.length; i++) {
      String char = template[i];
      if (delimiter.isDelimiter(template, i, searchForOpening)) {
        if (searchForOpening) {
          //opening delimiter
          tokens.addTokenWithBuffer(delimiter, ident, partial);
          searchForOpening = false;
        } else {
          //closing delimiter
          tokens.write(delimiter.closing); //add the closing delimiter
          tokens.addTokenWithBuffer(delimiter, ident, partial);
          i = i + delimiter.closingLength - 1;
          delimiter = tokens.nextDelimiter; //get the next delimiter to use
          searchForOpening = true;
          continue;
        }
      } else if (isSingleCharToken(char, searchForOpening)) {
        tokens.addTokenWithBuffer(delimiter, ident, partial);
        tokens.addToken(char, delimiter, ident, partial);
        continue;
      } else if (isSpecialNewLine(template, i)) {
        tokens.addTokenWithBuffer(delimiter, ident, partial);
        tokens.addToken(CRNL, delimiter, ident, partial);
        i++;
        continue;
      }
      tokens.write(char);
    }
    tokens.addTokenWithBuffer(delimiter, ident, partial, last: true);

    return new _Template._internal(tokens);
  }

  static bool isSingleCharToken(String char, bool opening) {
    if (!opening) {
      return false;
    }
    if (char == NL) {
      return true;
    }
    if (char == SPACE) {
      return true;
    }
    return false;
  }

  static bool isSpecialNewLine(String template, int position) {
    if (position + 1 == template.length) {
      return false;
    }
    var char = template[position];
    var nextChar = template[position + 1];
    return char == '\r' && nextChar == NL;
  }

  _Template._internal(this.list);

  call(ctx,
      {StringSink out: null,
      bool errorOnMissingProperty: false,
      bool assumeNullNonExistingProperty: true}) {
    StringSink o = out == null ? new StringBuffer() : out;
    _write(ctx, o,
        assumeNullNonExistingProperty: assumeNullNonExistingProperty);

    //If we provide a StringSink, write there and return it as
    //the response of the function. Otherwise make our library
    //easier to use by returning the string representation of
    //the template
    if (out == null) {
      return o.toString();
    }
    return o;
  }

  void _write(ctx, StringSink out, {bool assumeNullNonExistingProperty}) {
    if (list.head == null) {
      return;
    }
    if (!(ctx is MustacheContext)) {
      ctx = new MustacheContext(ctx,
          assumeNullNonExistingProperty: assumeNullNonExistingProperty);
    }

    //Iterate the tokens and apply the context
    Token token = list.head;
    while (token != null) {
      token = token(ctx, out);
    }
  }

  String toString() {
    return "Template($list)";
  }
}

class _TokenList {
  StringBuffer buffer;
  Token head;
  Token tail;
  Delimiter _nextDelimiter;
  Line line = new Line(null);
  final List<_StartSectionToken> startingTokens = [];

  _TokenList(Delimiter delimiter, String ident) {
    //Our template should start as an empty string token
    head = new _SpecialCharToken(EMPTY_STRING, ident);
    tail = head;
    _nextDelimiter = delimiter;
    buffer = new StringBuffer();
  }

  void addTokenWithBuffer(Delimiter del, String ident, Function partial,
      {last: false}) {
    if (buffer.length > 0) {
      addToken(buffer.toString(), del, ident, partial, last: last);
      buffer = new StringBuffer();
    }
  }

  void addToken(String str, Delimiter del, String ident, Function partial,
      {last: false}) {
    _add(new Token(str, partial, del, ident), last);
  }

  void _add(Token other, [bool last]) {
    if (other == null) {
      return;
    }
    if (other is _DelimiterToken) {
      _nextDelimiter = other.newDelimiter;
    } else if (other is _StartSectionToken) {
      _addStartingToken(other);
    } else if (other is _EndSectionToken) {
      _addEndingToken(other);
    }

    _addToLine(other, last);

    tail.next = other;
    tail = other;
  }

  void _addStartingToken(_StartSectionToken t) {
    startingTokens.add(t);
  }

  void _addEndingToken(_EndSectionToken t) {
    var lastStarting = startingTokens.removeLast();
    if (lastStarting.value != t.value) {
      throw new FormatException(
          "Expected {{/${lastStarting.value}}} but got {{/${t.value}}}");
    } else {
      lastStarting.endSection = t;
    }
  }

  void _addToLine(Token t, [bool last]) {
    line = line.add(t, last);
  }

  Delimiter get nextDelimiter => _nextDelimiter;

  void write(String txt) {
    buffer.write(txt);
  }

  String toString() {
    StringBuffer str = new StringBuffer("TokenList(");
    if (head == null) {
      //Do not display anything
    } else if (head == tail) {
      str.write(head);
    } else {
      str.write("$head...$tail");
    }
    str.write(")");
    return str.toString();
  }
}

class Delimiter {
  final String opening;
  final String _closing;
  String realClosingTag;

  Delimiter(this.opening, this._closing);

  bool isDelimiter(String template, int position, bool opening) {
    String d = opening ? this.opening : this._closing;
    if (d.length == 1) {
      return d == template[position];
    }
    //else:
    int endIndex = position + d.length;
    if (endIndex >= template.length) {
      return false;
    }
    String dd = template.substring(position, endIndex);
    if (d != dd) {
      return false;
    }
    //A hack to support tripple brackets
    if (!opening && _closing == '}}' && template[endIndex] == '}') {
      realClosingTag = '}}}';
    } else {
      realClosingTag = null;
    }
    return true;
  }

  String get closing => realClosingTag != null ? realClosingTag : _closing;

  int get closingLength => closing.length;

  int get openingLength => opening.length;

  toString() => "Delimiter($opening, $closing)";
}

class Line {
  final tokens = [];
  bool full = false;
  bool standAlone = true;
  Line prev = null;

  Line(Token t) {
    if (t != null) {
      add(t, false);
    }
  }

  Line add(Token t, [eof = false]) {
    if (full) {
      throw new StateError("Line is full. Can not add $t to it.");
    }
    if (!_isStandAloneToken(t) && standAlone) {
      standAlone = false;
    }
    tokens.add(t);
    if (_isEndOfLine(t) || eof) {
      return _eol();
    }
    //in any other case:
    return this;
  }

  Line _eol() {
    _markStandAloneLineTokens();
    full = true;
    Line newLine = new Line(null);
    newLine.prev = this;
    return newLine;
  }

  bool _isStandAloneToken(Token t) {
    return t is StandAloneLineCapable;
  }

  bool _isEndOfLine(Token t) {
    return t == NL || t == CRNL;
  }

  _markStandAloneLineTokens() {
    if (tokens.length == 1) {
      standAlone = false;
    }
    if (standAlone) {
      tokens.forEach((t) => t.rendable = false);
    }
  }
}
