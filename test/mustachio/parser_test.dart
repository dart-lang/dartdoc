import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:test/test.dart';

final _filePath = Uri.parse('file:///foo.dart');

void main() {
  test('parses an empty template', () {
    var parser = MustachioParser('', _filePath);
    var ast = parser.parse();
    expect(ast, isEmpty);
  });

  test('parses "{" as text', () {
    var parser = MustachioParser('{', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals('{'), spanStart: 0, spanEnd: 1);
  });

  test('parses "{{" as text', () {
    var parser = MustachioParser('{{', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('{{'), spanStart: 0, spanEnd: 2);
  });

  test('parses "{{}}" as text', () {
    var parser = MustachioParser('{{}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('{{}}'), spanStart: 0, spanEnd: 4);
  });
  test('parses "{{{}}" as text', () {
    var parser = MustachioParser('{{{}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('{{{}}'), spanStart: 0, spanEnd: 5);
  });

  test('parses text as text', () {
    var parser = MustachioParser('Words, punctuation, #^!>/ etc.', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals('Words, punctuation, #^!>/ etc.'),
        spanStart: 0, spanEnd: 30);
  });

  test('drops comment, start of content', () {
    var parser = MustachioParser('{{!comment}} Text', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals(' Text'), spanStart: 12, spanEnd: 17);
  });

  test('drops comment, end of content', () {
    var parser = MustachioParser('Text {{!comment}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals('Text '), spanStart: 0, spanEnd: 5);
  });

  test('drops comment, entire content', () {
    var parser = MustachioParser('{{!comment}}', _filePath);
    var ast = parser.parse();
    expect(ast, isEmpty);
  });

  test('drops comment with whitespace', () {
    var parser = MustachioParser('Text {{  !comment  }} Text', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '), spanStart: 0, spanEnd: 5);
    _expectText(ast[1], equals(' Text'), spanStart: 21, spanEnd: 26);
  });

  test('drops comment with newlines', () {
    var parser = MustachioParser('Text {{ \n !comment \n }} Text', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '), spanStart: 0, spanEnd: 5);
    _expectText(ast[1], equals(' Text'), spanStart: 23, spanEnd: 28);
  });

  test('drops comment with various chars', () {
    var parser = MustachioParser(
        'Text {{!Text, punct. `!@#\$%^&*()-=+}} Text', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '), spanStart: 0, spanEnd: 5);
    _expectText(ast[1], equals(' Text'), spanStart: 37, spanEnd: 42);
  });

  test('drops comment with newlines inside', () {
    var parser = MustachioParser('Text {{!Text\nMore text}} Text', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '), spanStart: 0, spanEnd: 5);
    _expectText(ast[1], equals(' Text'), spanStart: 24, spanEnd: 29);
  });

  test('parses variable', () {
    var parser = MustachioParser('Text {{key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '), spanStart: 0, spanEnd: 5);
    _expectVariable(ast[1], equals(['key']),
        spanStart: 5, spanEnd: 12, keySpanStart: 7, keySpanEnd: 10);
  });

  test('parses variable with whitespace', () {
    var parser = MustachioParser('Text {{  key  }}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']),
        spanStart: 5, spanEnd: 16, keySpanStart: 9, keySpanEnd: 12);
  });

  test('parses variable with newlines', () {
    var parser = MustachioParser('Text {{\n  \nkey\n  \n}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']),
        spanStart: 5, spanEnd: 20, keySpanStart: 11, keySpanEnd: 14);
  });

  test('parses variable with triple mustaches', () {
    var parser = MustachioParser('Text {{{key}}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']),
        escape: false,
        spanStart: 5,
        spanEnd: 14,
        keySpanStart: 8,
        keySpanEnd: 11);
  });

  test('parses variable with triple mustaches, whitespace', () {
    var parser = MustachioParser('Text {{{  key  }}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']),
        escape: false,
        spanStart: 5,
        spanEnd: 18,
        keySpanStart: 10,
        keySpanEnd: 13);
  });

  test('parses "." pseudo-variable', () {
    var parser = MustachioParser('Text {{.}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['.']),
        spanStart: 5, spanEnd: 10, keySpanStart: 7, keySpanEnd: 8);
  });

  test('parses "." pseudo-variable with whitespace', () {
    var parser = MustachioParser('Text {{ . }}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['.']),
        spanStart: 5, spanEnd: 12, keySpanStart: 8, keySpanEnd: 9);
  });

  test('parses variable with multiple names', () {
    var parser = MustachioParser('Text {{a.b}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['a', 'b']),
        spanStart: 5, spanEnd: 12, keySpanStart: 7, keySpanEnd: 10);
  });

  test('parses variable with multiple names and whitespace', () {
    var parser = MustachioParser('Text {{ a.b }}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['a', 'b']),
        spanStart: 5, spanEnd: 14, keySpanStart: 8, keySpanEnd: 11);
  });

  test('parses almost-variable with trailing "." as text', () {
    var parser = MustachioParser('Text {{ a.b. }}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{ a.b. }}'), spanStart: 0, spanEnd: 15);
  });

  test('parses almost-variable missing one "}" as text', () {
    var parser = MustachioParser('Text {{ a.b }', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{ a.b }'), spanStart: 0, spanEnd: 13);
  });

  test('parses almost-variable missing one "{" as text', () {
    var parser = MustachioParser('Text { a.b }}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals('Text { a.b }}'), spanStart: 0, spanEnd: 13);
  });

  test('parses variable with extra "{"', () {
    var parser = MustachioParser('Text {{{ a.b }}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text {'), spanStart: 0, spanEnd: 6);
    _expectVariable(ast[1], equals(['a', 'b']), spanStart: 6, spanEnd: 15);
  });

  test('parses section', () {
    var parser =
        MustachioParser('Text {{#key}}Section text{{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']),
        spanStart: 5, spanEnd: 33, keySpanStart: 8, keySpanEnd: 11);
    expect(section.children, hasLength(1));
    _expectText(section.children.single, equals('Section text'),
        spanStart: 13, spanEnd: 25);
  });

  test('parses empty section', () {
    var parser = MustachioParser('Text {{#key}}{{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']), spanStart: 5, spanEnd: 21);
    expect(section.children, isEmpty);
  });

  test('parses section with variable tag inside', () {
    var parser = MustachioParser('Text {{#key}}{{two}}{{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']), spanStart: 5, spanEnd: 28);
    expect(section.children, hasLength(1));
    _expectVariable(section.children.single, equals(['two']),
        spanStart: 13, spanEnd: 20);
  });

  test('parses section with multi-name key', () {
    var parser = MustachioParser(
        'Text {{#one.two.three}}Text{{/one.two.three}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var sectionOne = ast[1] as Section;
    _expectSection(sectionOne, equals(['one']),
        spanStart: 5, spanEnd: 45, keySpanStart: 8, keySpanEnd: 11);
    expect(sectionOne.children, hasLength(1));
    var sectionTwo = sectionOne.children[0] as Section;
    _expectSection(sectionTwo, equals(['two']),
        spanStart: 5, spanEnd: 45, keySpanStart: 12, keySpanEnd: 15);
    var sectionThree = sectionTwo.children[0] as Section;
    _expectSection(sectionThree, equals(['three']),
        spanStart: 5, spanEnd: 45, keySpanStart: 16, keySpanEnd: 21);
    _expectText(sectionThree.children[0], equals('Text'),
        spanStart: 23, spanEnd: 27);
  });

  test('parses inverse section with multi-name key', () {
    var parser =
        MustachioParser('Text {{^one.two}}Text{{/one.two}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var sectionOne = ast[1] as Section;
    _expectSection(sectionOne, equals(['one']),
        spanStart: 5, spanEnd: 33, keySpanStart: 8, keySpanEnd: 11);
    expect(sectionOne.children, hasLength(1));
    var sectionTwo = sectionOne.children[0] as Section;
    _expectSection(sectionTwo, equals(['two']),
        invert: true,
        spanStart: 5,
        spanEnd: 33,
        keySpanStart: 12,
        keySpanEnd: 15);
    _expectText(sectionTwo.children[0], equals('Text'));
  });

  test('parses section with empty key as text', () {
    var parser = MustachioParser('Text {{#}}{{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{#}}{{/key}}'));
  });

  test('parses section with missing closing tag as text', () {
    var parser = MustachioParser('Text {{#}}{{/key}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{#}}{{/key}'));
  });

  test('parses section with other closing tag', () {
    var parser = MustachioParser('Text {{#key}}{{/other}}{{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']), spanStart: 5, spanEnd: 31);
    expect(section.children, hasLength(1));
    _expectText(section.children.single, equals('{{/other}}'),
        spanStart: 13, spanEnd: 23);
  });

  test('parses empty closing tag as text', () {
    var parser = MustachioParser('Text {{#key}}{{/}}{{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']), spanStart: 5, spanEnd: 26);
    expect(section.children, hasLength(1));
    _expectText(section.children.single, equals('{{/}}'));
  });

  test('parses nested sections', () {
    var parser = MustachioParser(
        'Text {{#key1}} AA {{#key2}} BB {{/key2}} CC {{/key1}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key1']), spanStart: 5, spanEnd: 53);
    expect(section.children, hasLength(3));
    _expectText(section.children[0], equals(' AA '));
    var innerSection = section.children[1] as Section;
    _expectSection(innerSection, equals(['key2']), spanStart: 18, spanEnd: 40);
    expect(innerSection.children, hasLength(1));
    _expectText(innerSection.children[0], equals(' BB '));
  });

  test('parses nested sections with the same key', () {
    var parser = MustachioParser(
        'Text {{#key}} AA {{#key}} BB {{/key}} CC {{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']));
    expect(section.children, hasLength(3));
    _expectText(section.children[0], equals(' AA '));
    var innerSection = section.children[1] as Section;
    _expectSection(innerSection, equals(['key']));
    expect(innerSection.children, hasLength(1));
    _expectText(innerSection.children[0], equals(' BB '));
  });

  test('parses inverted section', () {
    var parser = MustachioParser('Text {{^key}} AA {{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']),
        invert: true,
        spanStart: 5,
        spanEnd: 25,
        keySpanStart: 8,
        keySpanEnd: 11);
    expect(section.children, hasLength(1));
    _expectText(section.children[0], equals(' AA '));
  });

  test('parses section with empty key as text', () {
    var parser = MustachioParser('Text {{^}}{{/key}}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{^}}{{/key}}'));
  });

  test('parses partial', () {
    var parser = MustachioParser('Text {{ >partial }}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectPartial(ast[1], equals('partial'),
        spanStart: 5, spanEnd: 19, keySpanStart: 9, keySpanEnd: 16);
  });

  test('parses partial with various chars', () {
    var parser =
        MustachioParser('Text {{ >Text,punct.`!@#\$%^&*()-=+ }}', _filePath);
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectPartial(ast[1], equals('Text,punct.`!@#\$%^&*()-=+'),
        spanStart: 5, spanEnd: 37, keySpanStart: 9, keySpanEnd: 34);
  });
}

void _expectText(MustachioNode node, Object matcher,
    {int spanStart, int spanEnd}) {
  expect(node, isA<Text>().having((e) => e.content, 'content', matcher));
  if (spanStart != null) {
    expect(
        node,
        isA<Text>()
            .having((e) => e.span.start.offset, 'span.start', spanStart));
  }
  if (spanEnd != null) {
    expect(node,
        isA<Text>().having((e) => e.span.end.offset, 'span.end', spanEnd));
  }
}

void _expectVariable(MustachioNode node, Object matcher,
    {bool escape = true,
    int spanStart,
    int spanEnd,
    int keySpanStart,
    int keySpanEnd}) {
  expect(
      node,
      isA<Variable>()
          .having((e) => e.key, 'key', matcher)
          .having((e) => e.escape, 'escape', escape));
  if (spanStart != null) {
    var actualSpanStart = (node as Variable).span.start.offset;
    _expectSpanOffset('Variable', 'start', actualSpanStart, spanStart);
  }
  if (spanEnd != null) {
    var actualSpanEnd = (node as Variable).span.end.offset;
    _expectSpanOffset('Variable', 'end', actualSpanEnd, spanEnd);
  }
  if (keySpanStart != null) {
    var actualKeySpanStart = (node as Variable).keySpan.start.offset;
    _expectSpanOffset(
        'Variable key', 'start', actualKeySpanStart, keySpanStart);
  }
  if (keySpanEnd != null) {
    var actualKeySpanEnd = (node as Variable).keySpan.end.offset;
    _expectSpanOffset('Variable key', 'end', actualKeySpanEnd, keySpanEnd);
  }
}

void _expectSection(MustachioNode node, Object matcher,
    {bool invert = false,
    int spanStart,
    int spanEnd,
    int keySpanStart,
    int keySpanEnd}) {
  expect(
      node,
      isA<Section>()
          .having((e) => e.key, 'key', matcher)
          .having((e) => e.invert, 'invert', invert));
  if (spanStart != null) {
    var actualSpanStart = (node as Section).span.start.offset;
    _expectSpanOffset('Section', 'start', actualSpanStart, spanStart);
  }
  if (spanEnd != null) {
    var actualSpanEnd = (node as Section).span.end.offset;
    _expectSpanOffset('Section', 'end', actualSpanEnd, spanEnd);
  }
  if (keySpanStart != null) {
    var actualKeySpanStart = (node as Section).keySpan.start.offset;
    _expectSpanOffset('Section key', 'start', actualKeySpanStart, keySpanStart);
  }
  if (keySpanEnd != null) {
    var actualKeySpanEnd = (node as Section).keySpan.end.offset;
    _expectSpanOffset('Section key', 'end', actualKeySpanEnd, keySpanEnd);
  }
}

void _expectPartial(MustachioNode node, Object matcher,
    {int spanStart, int spanEnd, int keySpanStart, int keySpanEnd}) {
  expect(node, isA<Partial>().having((e) => e.key, 'key', matcher));
  if (spanStart != null) {
    var actualSpanStart = (node as Partial).span.start.offset;
    _expectSpanOffset('Partial', 'start', actualSpanStart, spanStart);
  }
  if (spanEnd != null) {
    var actualSpanEnd = (node as Partial).span.end.offset;
    _expectSpanOffset('Partial', 'end', actualSpanEnd, spanEnd);
  }
  if (keySpanStart != null) {
    var actualKeySpanStart = (node as Partial).keySpan.start.offset;
    _expectSpanOffset('Partial key', 'start', actualKeySpanStart, keySpanStart);
  }
  if (keySpanEnd != null) {
    var actualKeySpanEnd = (node as Partial).keySpan.end.offset;
    _expectSpanOffset('Partial key', 'end', actualKeySpanEnd, keySpanEnd);
  }
}

void _expectSpanOffset(
    String nodeType, String offsetType, int actualOffset, int expectedOffset) {
  expect(actualOffset, expectedOffset,
      reason:
          '$nodeType span $offsetType offset expected to be $expectedOffset '
          'but was $actualOffset');
}
