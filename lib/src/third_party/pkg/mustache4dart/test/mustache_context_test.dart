import 'dart:mirrors';
import 'package:test/test.dart';
import '../lib/mustache_context.dart';

void main() {
  group('mustache_context lib', () {
    test('Recursion of iterable contextes', () {
      var contextY = {'content': 'Y', 'nodes': []};
      var contextX = {
        'content': 'X',
        'nodes': [contextY]
      };
      var ctx = new MustacheContext(contextX);
      expect(ctx.field('nodes'), isNotNull);
      expect(ctx.field('nodes') is Iterable, isTrue);
      expect((ctx.field('nodes') as Iterable).length, 1);
      (ctx.field('nodes') as Iterable).forEach((n) {
        expect(n.field('content').value(), 'Y');
        expect(n.field('nodes').length, 0);
      });
    });

    test('Direct interpolation', () {
      var ctx = new MustacheContext({'n1': 1, 'n2': 2.0, 's': 'some string'});
      expect(ctx.field('n1').field('.').value(), '1');
      expect(ctx.field('n2').field('.').value(), '2.0');
      expect(ctx.field('s').field('.').value(), 'some string');
    }, testOn: "vm");

    test('Direct list interpolation', () {
      var list = [1, 'two', 'three', '4'];
      var ctx = new MustacheContext(list);
      expect(ctx.field('.') is Iterable, isTrue);
    });
  });

  test('Simple context with map', () {
    var ctx = new MustacheContext({'k1': 'value1', 'k2': 'value2'});
    expect(ctx.field('k1').value(), 'value1');
    expect(ctx.field('k2').value(), 'value2');
    expect(ctx.field('k3'), null);
  });

  test('Simple context with object', () {
    var ctx = new MustacheContext(new _Person('Γιώργος', 'Βαλοτάσιος'));
    expect(ctx.field('name').value(), 'Γιώργος');
    expect(ctx.field('lastname').value(), 'Βαλοτάσιος');
    expect(ctx.field('last'), null);
    expect(ctx.field('fullname').value(), 'Γιώργος Βαλοτάσιος');
    expect(ctx.field('reversedName'), null);
    expect(ctx.field('reversedLastName').value(), 'ςοισάτολαΒ');
  });

  test('Simple map with list of maps', () {
    dynamic ctx = new MustacheContext({
      'k': [
        {'k1': 'item1'},
        {'k2': 'item2'},
        {
          'k3': {'kk1': 'subitem1', 'kk2': 'subitem2'}
        }
      ]
    });
    expect(ctx.field('k').length, 3);
  });

  test('Map with list of lists', () {
    var ctx = new MustacheContext({
      'k': [
        {'k1': 'item1'},
        {
          'k3': [
            {'kk1': 'subitem1'},
            {'kk2': 'subitem2'}
          ]
        }
      ]
    });
    expect(ctx.field('k') is Iterable, isTrue);
    expect((ctx.field('k') as Iterable).length, 2);
    expect((ctx.field('k') as Iterable).last.field('k3').length, 2);
  });

  test('Object with iterables', () {
    var p = new _Person('Νικόλας', 'Νικολάου');
    p.contactInfos.add(new _ContactInfo('Address', {
      'Street': 'Κολοκωτρόνη',
      'Num': '31',
      'Zip': '42100',
      'Country': 'GR'
    }));
    p.contactInfos.add(new _ContactInfo('skype', 'some1'));
    var ctx = new MustacheContext(p);
    var contactInfos = ctx.field('contactInfos');
    expect(contactInfos is Iterable, isTrue);
    var iterableContactInfos = contactInfos as Iterable;
    expect(iterableContactInfos.length, 2);
    expect(
        iterableContactInfos.first.field('value').field('Num').value(), '31');
  });

  test('Deep search with object', () {
    //create our model:
    _Person p = null;
    for (int i = 10; i > 0; i--) {
      p = new _Person("name$i", "lastname$i", p);
    }

    MustacheContext ctx = new MustacheContext(p);
    expect(ctx.field('name').value(), 'name1');
    expect(ctx.field('parent').field('lastname').value(), 'lastname2');
    expect(ctx.field('parent').field('parent').field('fullname').value(),
        'name3 lastname3');
  });

  test('simple MustacheFunction value', () {
    var t = new _Transformer();
    var ctx = new MustacheContext(t);
    var f = ctx.field('transform');

    expect(f.isLambda, true);
    expect(f.value('123 456 777'), t.transform('123 456 777'));
  });

  test('MustacheFunction from anonymus function', () {
    var map = {'transform': (String val) => "$val!"};
    var ctx = new MustacheContext(map);
    var f = ctx.field('transform');

    expect(f.isLambda, true);
    expect(f.value('woh'), 'woh!');
  });

  test('Dotted names', () {
    var ctx =
        new MustacheContext({'person': new _Person('George', 'Valotasios')});
    expect(ctx.field('person.name').value(), 'George');
  });

  test('Context with another context', () {
    var ctx = new MustacheContext(new _Person('George', 'Valotasios'),
        parent: new MustacheContext({
          'a': {'one': 1},
          'b': {'two': 2}
        }));
    expect(ctx.field('name').value(), 'George');
    expect(ctx.field('a').field('one').value(), '1');
    expect(ctx.field('b.two').value(), '2');
  });

  test('Deep subcontext test', () {
    var map = {
      'a': {'one': 1},
      'b': {'two': 2},
      'c': {'three': 3}
    };
    var ctx = new MustacheContext({
      'a': {'one': 1},
      'b': {'two': 2},
      'c': {'three': 3}
    });
    expect(ctx.field('a'), isNotNull,
        reason: "a should exists when using $map");
    expect(ctx.field('a').field('one').value(), '1');
    expect(ctx.field('a').field('two'), isNull);
    expect(ctx.field('a').field('b'), isNotNull,
        reason: "a.b should exists when using $map");
    expect(ctx.field('a').field('b').field('one').value(), '1',
        reason: "a.b.one == a.own when using $map");
    expect(ctx.field('a').field('b').field('two').value(), '2',
        reason: "a.b.two == b.two when using $map");
    expect(ctx.field('a').field('b').field('three'), isNull);
    expect(ctx.field('a').field('b').field('c'), isNotNull,
        reason: "a.b.c should not be null when using $map");

    var abc = ctx.field('a').field('b').field('c');
    expect(abc.field('one').value(), '1',
        reason: "a.b.c.one == a.one when using $map");
    expect(abc.field('two').value(), '2',
        reason: "a.b.c.two == b.two when using $map");
    expect(abc.field('three').value(), '3');
  });
}

@MirrorsUsed()
class _Person {
  final name;
  final lastname;
  final _Person parent;
  List<_ContactInfo> contactInfos = [];

  _Person(this.name, this.lastname, [this.parent = null]);

  get fullname => "$name $lastname";

  static _reverse(String str) {
    StringBuffer out = new StringBuffer();
    for (int i = str.length; i > 0; i--) {
      out.write(str[i - 1]);
    }
    return out.toString();
  }

  reversedLastName() => _reverse(lastname);
}

@MirrorsUsed()
class _ContactInfo {
  final String type;
  final value;

  _ContactInfo(this.type, this.value);
}

@MirrorsUsed()
class _Transformer {
  String transform(String val) => "<b>$val</b>";
}
