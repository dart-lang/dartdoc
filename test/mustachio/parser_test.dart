import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:test/test.dart';

void main() {
  test('parses an empty template', () {
    var parser = MustachioParser('');
    var ast = parser.parse();
    expect(ast, isEmpty);
  });

  test('parses "{" as text', () {
    var parser = MustachioParser('{');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals('{'));
  });

  test('parses "{{" as text', () {
    var parser = MustachioParser('{{');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('{{'));
  });

  test('parses "{{}}" as text', () {
    var parser = MustachioParser('{{}}');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('{{}}'));
  });
  test('parses "{{{}}" as text', () {
    var parser = MustachioParser('{{{}}');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('{{{}}'));
  });

  test('parses text as text', () {
    var parser = MustachioParser('Words, punctuation, #^!>/ etc.');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals('Words, punctuation, #^!>/ etc.'));
  });

  test('drops comment, start of content', () {
    var parser = MustachioParser('{{!comment}} Text');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals(' Text'));
  });

  test('drops comment, end of content', () {
    var parser = MustachioParser('Text {{!comment}}');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals('Text '));
  });

  test('drops comment, entire content', () {
    var parser = MustachioParser('{{!comment}}');
    var ast = parser.parse();
    expect(ast, isEmpty);
  });

  test('drops comment with whitespace', () {
    var parser = MustachioParser('Text {{  !comment  }} Text');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectText(ast[1], equals(' Text'));
  });

  test('drops comment with newlines', () {
    var parser = MustachioParser('Text {{ \n !comment \n }} Text');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectText(ast[1], equals(' Text'));
  });

  test('drops comment with various chars', () {
    var parser = MustachioParser('Text {{!Text, punct. `!@#\$%^&*()-=+}} Text');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectText(ast[1], equals(' Text'));
  });

  test('drops comment with newlines inside', () {
    var parser = MustachioParser('Text {{!Text\nMore text}} Text');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectText(ast[1], equals(' Text'));
  });

  test('parses variable', () {
    var parser = MustachioParser('Text {{key}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']));
  });

  test('parses variable with whitespace', () {
    var parser = MustachioParser('Text {{  key  }}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']));
  });

  test('parses variable with newlines', () {
    var parser = MustachioParser('Text {{\n  \nkey\n  \n}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']));
  });

  test('parses variable with triple mustaches', () {
    var parser = MustachioParser('Text {{{key}}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']), escape: false);
  });

  test('parses variable with triple mustaches, whitespace', () {
    var parser = MustachioParser('Text {{{  key  }}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['key']), escape: false);
  });

  test('parses "." pseudo-variable', () {
    var parser = MustachioParser('Text {{.}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['.']));
  });

  test('parses "." pseudo-variable with whitespace', () {
    var parser = MustachioParser('Text {{ . }}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['.']));
  });

  test('parses variable with multiple names', () {
    var parser = MustachioParser('Text {{a.b}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['a', 'b']));
  });

  test('parses variable with multiple names and whitespace', () {
    var parser = MustachioParser('Text {{ a.b }}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectVariable(ast[1], equals(['a', 'b']));
  });

  test('parses almost-variable with trailing "." as text', () {
    var parser = MustachioParser('Text {{ a.b. }}');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{ a.b. }}'));
  });

  test('parses almost-variable missing one "}" as text', () {
    var parser = MustachioParser('Text {{ a.b }');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{ a.b }'));
  });

  test('parses almost-variable missing one "{" as text', () {
    var parser = MustachioParser('Text { a.b }}');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast.single, equals('Text { a.b }}'));
  });

  test('parses variable with extra "{"', () {
    var parser = MustachioParser('Text {{{ a.b }}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text {'));
    _expectVariable(ast[1], equals(['a', 'b']));
  });

  test('parses section', () {
    var parser = MustachioParser('Text {{#key}}Section text{{/key}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']));
    expect(section.children, hasLength(1));
    _expectText(section.children.single, equals('Section text'));
  });

  test('parses empty section', () {
    var parser = MustachioParser('Text {{#key}}{{/key}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']));
    expect(section.children, isEmpty);
  });

  test('parses section with variable tag inside', () {
    var parser = MustachioParser('Text {{#key}}{{two}}{{/key}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']));
    expect(section.children, hasLength(1));
    _expectVariable(section.children.single, equals(['two']));
  });

  test('parses section with empty key as text', () {
    var parser = MustachioParser('Text {{#}}{{/key}}');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{#}}{{/key}}'));
  });

  test('parses section with missing closing tag as text', () {
    var parser = MustachioParser('Text {{#}}{{/key}');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{#}}{{/key}'));
  });

  test('parses section with other closing tag', () {
    var parser = MustachioParser('Text {{#key}}{{/other}}{{/key}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']));
    expect(section.children, hasLength(1));
    _expectText(section.children.single, equals('{{/other}}'));
  });

  test('parses empty closing tag as text', () {
    var parser = MustachioParser('Text {{#key}}{{/}}{{/key}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']));
    expect(section.children, hasLength(1));
    _expectText(section.children.single, equals('{{/}}'));
  });

  test('parses nested sections', () {
    var parser = MustachioParser(
        'Text {{#key1}} AA {{#key2}} BB {{/key2}} CC {{/key1}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key1']));
    expect(section.children, hasLength(3));
    _expectText(section.children[0], equals(' AA '));
    var innerSection = section.children[1] as Section;
    _expectSection(innerSection, equals(['key2']));
    expect(innerSection.children, hasLength(1));
    _expectText(innerSection.children[0], equals(' BB '));
  });

  test('parses nested sections with the same key', () {
    var parser =
        MustachioParser('Text {{#key}} AA {{#key}} BB {{/key}} CC {{/key}}');
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
    var parser = MustachioParser('Text {{^key}} AA {{/key}}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    var section = ast[1] as Section;
    _expectSection(section, equals(['key']), invert: true);
    expect(section.children, hasLength(1));
    _expectText(section.children[0], equals(' AA '));
  });

  test('parses section with empty key as text', () {
    var parser = MustachioParser('Text {{^}}{{/key}}');
    var ast = parser.parse();
    expect(ast, hasLength(1));
    _expectText(ast[0], equals('Text {{^}}{{/key}}'));
  });

  test('parses partial', () {
    var parser = MustachioParser('Text {{ >partial }}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectPartial(ast[1], equals('partial'));
  });

  test('parses partial with various chars', () {
    var parser = MustachioParser('Text {{ >Text,punct.`!@#\$%^&*()-=+ }}');
    var ast = parser.parse();
    expect(ast, hasLength(2));
    _expectText(ast[0], equals('Text '));
    _expectPartial(ast[1], equals('Text,punct.`!@#\$%^&*()-=+'));
  });
}

void _expectText(MustachioNode node, Object matcher) {
  expect(node, isA<Text>().having((e) => e.content, 'content', matcher));
}

void _expectVariable(MustachioNode node, Object matcher, {bool escape = true}) {
  expect(
      node,
      isA<Variable>()
          .having((e) => e.key, 'key', matcher)
          .having((e) => e.escape, 'escape', escape));
}

void _expectSection(MustachioNode node, Object matcher, {bool invert = false}) {
  expect(
      node,
      isA<Section>()
          .having((e) => e.key, 'key', matcher)
          .having((e) => e.invert, 'invert', invert));
}

void _expectPartial(MustachioNode node, Object matcher) {
  expect(node, isA<Partial>().having((e) => e.key, 'key', matcher));
}
