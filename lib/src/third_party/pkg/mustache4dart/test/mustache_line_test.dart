import 'package:test/test.dart';
import '../lib/mustache4dart.dart';

void main() {
  group('mustache4dart Line', () {
    var del = new Delimiter('{{', '}}');

    newToken(String s) => new Token(s, null, del, null);

    test('Should not accept more tokens when it is full', () {
      var l = new Line(newToken('Random text'));
      l.add(newToken('Random text2'));
      l.add(newToken(NL));
      expect(() => l.add(newToken('Some more random text')), throwsStateError);
    });

    test('add method should return the right line to add more stuff', () {
      var l = new Line(newToken('some text'));
      var l2 = l.add(newToken('some more text'));
      expect(l2, same(l));
      var nl = l.add(newToken(NL));
      expect(nl, isNot(same(l)));
    });

    test('Should not be standalone if it contains a string token', () {
      var l = new Line(newToken('Some text!'));
      expect(l.standAlone, isFalse);
    });

    test("Expression tokens should be considered stand alone capable", () {
      var l = new Line(newToken(' '));
      l.add(newToken(' '));
      l.add(newToken('{{/xxx}}'));
      expect(l.standAlone, isTrue);
    });

    test("Last line with an expression only should be considered standalone",
        () {
      var l = new Line(newToken(' '));
      l = l
          .add(newToken(NL))
          .add(newToken(' '))
          .add(newToken(' '))
          .add(newToken('{{/ending}}'));

      expect(l.standAlone, isTrue);
    });

    test("Last line should not end with a new line", () {
      var l = new Line(newToken('#')).add(newToken('{{#a}}'));
      var l2 = l.add(newToken(NL)).add(newToken('/'));
      var l3 = l2.add(newToken(NL)).add(newToken(' ')).add(newToken(' '));

      expect(l2, isNot(same(l)));
      expect(l3, isNot(same(l2)));
      expect(l.standAlone, isFalse);
      expect(l2.standAlone, isFalse);
      expect(l3.standAlone, isTrue);
    });

    test("Stand empty line should not be considered standAlone", () {
      //{{#a}}\n{{one}}\n{{/a}}\n\n{{b.two}}\n
      var l_a = new Line(newToken('{{#a}}'));
      var l_one = l_a.add(newToken(NL)).add(newToken('{{one}}'));
      var l_a_end = l_one.add(newToken(NL)).add(newToken('{{/a}}'));
      var l_empty = l_a_end.add(newToken(NL));
      var l_b = l_empty.add(newToken(NL)).add(newToken('{{b.two}}'));
      l_b.add(newToken(NL));

      expect(l_a.standAlone, isTrue);
      expect(l_one.standAlone, isFalse);
      expect(l_a_end.standAlone, isTrue);

      //Make sure that the empty line is actual an empty line. It only contains a NL char
      expect(l_empty.tokens.length, 1);
      expect(l_empty.tokens[0], newToken(NL));
      expect(l_empty.standAlone, isFalse,
          reason:
              'empty line is part of the template and should not be considered as a standAlone one');

      expect(l_b.standAlone, isFalse);
    });

    test(
        "Should cosider partial tag followed by a newline as an standAlone line",
        () {
      var l = new Line(newToken('|'));
      l = l.add(newToken(CRNL));
      l = l.add(newToken('{{> p}}'));
      l.add(newToken(CRNL)).add(newToken('|'));
      expect(l.standAlone, isTrue);
    });
  });
}
