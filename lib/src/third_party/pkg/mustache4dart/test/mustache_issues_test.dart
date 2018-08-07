import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import '../lib/mustache4dart.dart';
import '../lib/mustache_context.dart';

class A {
  final bar = 'bar';

  String get foo => 'foo';
}

class B extends A {}

class Parent {
  String foo;
}

class Child extends Parent {
  List<OtherChild> children = [];
}

class OtherChild extends Parent {}

void main() {
  group('mustache4dart issues', () {
    test(
        '#9: use empty strings for non existing variable',
        () => expect(
            render("{{#sec}}[{{variable}}]{{/sec}}", {'sec': 42}), '[]'));

    test('#10',
        () => expect(render('|\n{{#bob}}\n{{/bob}}\n|', {'bob': []}), '|\n|'));

    test(
        '#11',
        () => expect(
            () => render("{{#sec}}[{{var}}]{{/somethingelse}}", {'sec': 42}),
            throwsFormatException));

    test('#12: Write to a StringSink', () {
      StringSink out = new StringBuffer();
      StringSink outcome = render("{{name}}!", {'name': "George"}, out: out);
      expect(out, outcome);
      expect(out.toString(), "George!");
    });

    group('#16', () {
      test('side effect',
          () => expect(render('{{^x}}x{{/x}}!!!', null), 'x!!!'));

      test(
          'root cause: For null objects the value of any property should be null',
          () {
        var ctx = new MustacheContext(null);
        expect(ctx.field('xxx'), null);
        expect(ctx.field('123'), null);
        expect(ctx.field(''), null);
        expect(ctx.field(null), null);
      });
    });

    group('#17', () {
      test(
          'side effect',
          () => expect(
              render('{{#a}}[{{{a}}}|{{b}}]{{/a}}', {'a': 'aa', 'b': 'bb'}),
              '[aa|bb]'));

      test('root cause: setting the same context as a subcontext', () {
        final ctx = new MustacheContext({'a': 'aa', 'b': 'bb'});
        expect(ctx, isNotNull);
        expect(ctx.field('a').toString(), isNotNull);

        //Here lies a problem if the subaa.other == suba
        expect(ctx.field('a').field('a').toString(), isNotNull);
      });
    });

    test('#20', () {
      var currentPath = Directory.current.path;
      if (!currentPath.endsWith('/test')) {
        currentPath = "$currentPath/test";
      }
      final template = new File("$currentPath/lorem-ipsum.txt")
          .readAsStringSync(encoding: UTF8);

      final String out = render(template, {'ma': 'ma'});
      expect(out, template);
    }, onPlatform: {"js": new Skip("io is not available on a browser")});

    test('#25', () {
      var ctx = {
        "parent_name": "John",
        "children": [
          {"name": "child"}
        ]
      };
      expect(render('{{#children}}Parent: {{parent_name}}{{/children}}', ctx),
          'Parent: John');
    });

    test('#28', () {
      var model = {
        "name": "God",
        "hasChildren": true,
        "children": [
          {"name": "granpa", "hasChildren": true},
          {"name": "granma", "hasChildren": false}
        ]
      };

      expect(
          render(
              '{{#children}}{{name}}{{#hasChildren}} has children{{/hasChildren}},{{/children}}',
              model),
          'granpa has children,granma,');
    });

    test('#29', () {
      var list = [1, 'two', 'three', '4'];
      expect(render('{{#.}}{{.}},{{/.}}', list), '1,two,three,4,');
    });

    test('#30', () {
      final txt = '''

<div>
  <h1>Hello World!</h1>
</div>

''';
      expect(render(txt, null), txt);
    });

    test('#33', () {
      final b = new B();
      expect(render('{{b.foo}}', {'b': b}), 'foo');
      expect(render('{{b.bar}}', {'b': b}), 'bar');
    });

    test(
        '#41 do not look into parent context if current context has field but its value is null',
        () {
      var c = new Child()
        ..foo = 'child'
        ..children = [
          new OtherChild()..foo = 'otherchild',
          new OtherChild()..foo = null
        ];

      var template = '''
{{foo}}
{{#children}}{{foo}}!{{/children}}''';

      var output = render(template, c, assumeNullNonExistingProperty: false);
      var expected = "child\notherchild!!";

      expect(output, expected);
    });

    test('#44 should provide a way to check for non empty lists', () {
      final map = {
        'list': [1, 2]
      };
      expect(
          render(
              '{{^list.empty}}<ul>{{#list}}<li>{{.}}</li>{{/list}}</ul>{{/list.empty}}',
              map),
          '<ul><li>1</li><li>2</li></ul>');
    });
  });
}
