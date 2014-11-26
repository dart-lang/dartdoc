
library css;

import 'dart:io';
import 'dart:convert';

class CSS {

  // The bootstrap css file
  final String cssFilePath = '/packages/bootstrap/css/bootstrap.css';

  String getCssName() => 'bootstrap.css';

  String getCssContent() {
      var script = new File(Platform.script.toFilePath());
      var cssFile = new File('${script.parent.path}$cssFilePath');
//      cssFile = new File.fromUri(Uri.parse('package://bootstrap/css/bootstrap.css'));
      String text = cssFile.readAsStringSync(encoding: ASCII);
      return text;
  }
}
