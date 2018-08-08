library mustache_usage;

import '../lib/mustache4dart.dart';

void main() {
  //Basic use of the library as you can find it at http://mustache.github.io/mustache.5.html
  var template = '''Hello {{name}}
You have just won \${{value}}!
{{#in_ca}}
Well, \${{taxed_value}}, after taxes.
{{/in_ca}}''';

  var obj = {
    "name": "Chris",
    "value": 10000,
    "taxed_value": 10000 - (10000 * 0.4),
    "in_ca": true
  };

  print(render(template, obj));

  //Print something to a StringSink
  var out = new StringBuffer();
  render(template, obj, out: out);
  print(out);
}
