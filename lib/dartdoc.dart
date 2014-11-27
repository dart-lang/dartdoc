// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc;

import 'dart:io';

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source_io.dart';


import 'src/css.dart';
import 'src/helpers.dart';
import 'src/html_gen.dart';
import 'src/io_utils.dart';
import 'src/model_utils.dart';
import 'src/package_utils.dart';
import 'src/utils.dart';

const String DEFAULT_OUTPUT_DIRECTORY = 'docs';

/// Generates Dart documentation for all public Dart libraries in the given
/// directory.
class DartDoc {

  //TODO(keertip): implement excludes
  List<String> _excludes;
  Directory _rootDir;
  final CSS css = new CSS();
  HtmlGenerator html;
  Directory out;
  Set<LibraryElement> libraries = new Set();
  Generator generator;

  DartDoc(this._rootDir, this._excludes);

  /// Generate the documentation
  void generateDocs() {
    Stopwatch stopwatch = new Stopwatch();
    stopwatch.start();
    var files = findFilesToDocumentInPackage(_rootDir.path);
    libraries.addAll(parseLibraries(files));
    generator = new GeneratorHelper(libraries);
    // create the out directory
    out = new Directory(DEFAULT_OUTPUT_DIRECTORY);
    if (!out.existsSync()) {
      out.createSync(recursive: true);
    }
    // generate the docs
    html = new HtmlGenerator();
    generatePackage();
    libraries.forEach((lib) => generateLibrary(lib));
    // copy the css resource into 'out'
    File f = joinFile(new Directory(out.path), [css.getCssName()]);
    f.writeAsStringSync(css.getCssContent());

    double seconds = stopwatch.elapsedMilliseconds / 1000.0;
    print('');
    print("Documented ${libraries.length} " "librar${libraries.length == 1 ? 'y' : 'ies'} in " "${seconds.toStringAsFixed(1)} seconds.");
  }

  List<LibraryElement> parseLibraries(List<String> files) {
    DartSdk sdk = new DirectoryBasedDartSdk(new JavaFile(_getSdkDir().path));

    ContentCache contentCache = new ContentCache();
    List<UriResolver> resolvers = [new DartUriResolver(sdk), new FileUriResolver()];
    JavaFile packagesDir = new JavaFile.relative(new JavaFile(_rootDir.path), 'packages');
    if (packagesDir.exists()) {
      resolvers.add(new PackageUriResolver([packagesDir]));
    }
    SourceFactory sourceFactory = new SourceFactory(/*contentCache,*/ resolvers);
    AnalysisContext context = AnalysisEngine.instance.createAnalysisContext();
    context.sourceFactory = sourceFactory;

    files.forEach((String filePath) {
      Source source = new FileBasedSource.con1(new JavaFile(filePath));
      if (context.computeKindOf(source) == SourceKind.LIBRARY) {
        LibraryElement library = context.computeLibraryElement(source);
        CompilationUnit unit = context.resolveCompilationUnit(source, library);
        libraries.add(library);
        libraries.addAll(library.exportedLibraries);
      }
    });
    return libraries.toList();
  }

  Directory _getSdkDir() {
    // Look for --dart-sdk on the command line.
    // TODO:
    List<String> args = []; //new Options().arguments;
    if (args.contains('--dart-sdk')) {
      return new Directory(args[args.indexOf('dart-sdk') + 1]);
    }
    // Look in env['DART_SDK'].
    if (Platform.environment['DART_SDK'] != null) {
      return new Directory(Platform.environment['DART_SDK']);
    }
    // Look relative to the dart executable.
    return new File(Platform.executable).parent.parent;
  }

  void generatePackage() {
    var packageName = getPackageName(_rootDir.path);
    if (packageName.isNotEmpty) {
      File f = joinFile(new Directory(out.path), ['${packageName}_package.html']);
      print('generating ${f.path}');
      html = new HtmlGenerator();
      html.start(title: 'Package ${packageName}', cssRef: css.getCssName());
      generateHeader();

      html.startTag('div', attributes: "class='container'", newLine: false);
      html.writeln();
      html.startTag('div', attributes: "class='row'", newLine: false);
      html.writeln();
      html.startTag('div', attributes: "class='span3'");
      html.startTag('ul', attributes: 'class="nav nav-tabs nav-stacked left-nav"');
      html.startTag('li', attributes: 'class="active"', newLine: false);
      html.write('<a href="${packageName}">' '<i class="chevron-nav icon-white icon-chevron-right"></i> ' '${packageName}</a>');
      html.endTag(); //li
      html.endTag(); //ul
      html.endTag();
      html.startTag('div', attributes: "class='span9'");
      html.tag('h1', contents: packageName);
      html.writeln('<hr>');
      html.startTag('dl');
      html.startTag('h4');
      html.tag('dt', contents: 'Libraries');
      html.endTag();
      html.startTag('dd');
      for (LibraryElement lib in libraries) {
        html.writeln('<a href="${getFileNameFor(lib)}"> ${lib.name}</a><br>');
      }
      html.endTag();
      html.endTag(); // div.container
      generateFooter();
      html.end();
      f.writeAsStringSync(html.toString());
    }

  }



  void generateLibrary(LibraryElement library) {
    File f = joinFile(new Directory(out.path), [getFileNameFor(library)]);
    print('generating ${f.path}');
    html = new HtmlGenerator();
    html.start(title: 'Library ${library.name}', cssRef: css.getCssName());

    generateHeader();

    html.startTag('div', attributes: "class='container'", newLine: false);
    html.writeln();
    html.startTag('div', attributes: "class='row'", newLine: false);
    html.writeln();

    // left nav
    html.startTag('div', attributes: "class='span3'");
    html.startTag('ul', attributes: 'class="nav nav-tabs nav-stacked left-nav"');
//      for (LibraryElement lib in libraries) {
//        if (lib == library) {
    html.startTag('li', attributes: 'class="active"', newLine: false);
    html.write('<a href="${getFileNameFor(library)}">' '<i class="chevron-nav icon-white icon-chevron-right"></i> ' '${library.name}</a>');
//        } else {
//          html.startTag('li', newLine: false);
//          html.write('<a href="${getFileNameFor(lib)}">'
//          '<i class="chevron-nav icon-chevron-right"></i> '
//          '${lib.name}</a>');
//        }
    html.endTag(); // li
//      }
    html.endTag(); // ul.nav
    html.endTag(); // div.span3

    // main content
    html.startTag('div', attributes: "class='span9'");

    html.tag('h1', contents: library.name);

    if (!library.exportedLibraries.isEmpty) {
      html.startTag('p');
      html.write('exports ');
      for (int i = 0; i < library.exportedLibraries.length; i++) {
        if (i > 0) {
          html.write(', ');
        }

        LibraryElement lib = library.exportedLibraries[i];
        if (libraries.contains(lib)) {
          html.write('<a href="${getFileNameFor(lib)}">${lib.name}</a>');
        } else {
          html.write(lib.name);
        }
      }
      html.endTag();
    }

    html.writeln('<hr>');

    LibraryHelper lib = new LibraryHelper(library);

    html.startTag('dl', attributes: "class=dl-horizontal");

    List<VariableHelper> variables = lib.getVariables();
    List<AccessorHelper> accessors = lib.getAccessors();
    List<FunctionHelper> functions = lib.getFunctions();
    List<TypedefHelper> typedefs = lib.getTypedefs();
    List<ClassHelper> types = lib.getTypes();

    createToc(variables);
    createToc(accessors);
    createToc(functions);
    createToc(typedefs);
    createToc(types);

    html.endTag(); // dl

    printComments(library);

    generateElements(variables);
    generateElements(accessors);
    generateElements(functions);
    generateElements(typedefs);

    types.forEach(generateClass);

    html.writeln('<hr>');

    html.endTag(); // div.span9

    html.endTag(); // div.row

    html.endTag(); // div.container

    generateFooter();

    html.end();

    // write the file contents
    f.writeAsStringSync(html.toString());
  }

  void generateHeader() {
    // header
    html.startTag('header');
    html.endTag();
  }

  void generateFooter() {
    // footer
    html.startTag('footer');
//    html.startTag('div', 'class="navbar navbar-fixed-bottom"');
//      html.startTag('div', 'class="navbar-inner"');
//        html.startTag('div', 'class="container" style="width: auto; padding: 0 20px;"');
//          html.tag('a', 'Title'); //<a class="brand" href="#">Title</a>
//          html.startTag('ul', 'class="nav"');
//            html.tag('li', 'Link');
//          html.endTag();
//        html.endTag();
//      html.endTag();
//    html.endTag();
    html.endTag();
  }

  void createToc(List<ElementHelper> elements) {
    if (!elements.isEmpty) {
      html.tag('dt', contents: elements[0].typeName);
      html.startTag('dd');
      for (ElementHelper e in elements) {
        html.writeln('${createIconFor(e.element)}${e.createLinkedSummary(generator)}<br>');
      }
      html.endTag();
    }
  }

  String getFileNameFor(LibraryElement library) {
    return '${library.name}.html';
  }

  void generateElements(List<ElementHelper> elements, [bool header = true]) {
    if (!elements.isEmpty) {
      html.tag('h4', contents: elements[0].typeName);
      if (header) {
        html.startTag('div', attributes: "class=indent");
      }
      elements.forEach(generateElement);
      if (header) {
        html.endTag();
      }
    }
  }

  void generateAnnotations(List<ElementAnnotation> annotations) {
    if (!annotations.isEmpty) {
      html.write('<i class="icon-info-sign icon-hidden"></i> ');
      for (ElementAnnotation a in annotations) {
        Element e = a.element;
        // TODO: I don't believe we get back the right elements for const
        // ctor annotations
        html.writeln('@${e.name} ');
      }
      html.writeln('<br>');
    }
  }

  void generateElement(ElementHelper f) {
    html.startTag('b', newLine: false);
    html.write('${createAnchor(f.element)}');
    generateAnnotations(f.element.metadata);
    html.write(createIconFor(f.element));
    if (f.element is MethodElement) {
      html.write(generateOverrideIcon(f.element as MethodElement));
    }
    html.write(f.createLinkedDescription(generator));
    html.endTag();
    printComments(f.element);
  }

  String createIconFor(Element e) {
    if (e is PropertyAccessorElement) {
      PropertyAccessorElement a = e;

      if (a.isGetter) {
        return '<i class=icon-circle-arrow-right></i> ';
      } else {
        return '<i class=icon-circle-arrow-left></i> ';
      }
    } else if (e is ClassElement) {
      return '<i class=icon-leaf></i> ';
    } else if (e is FunctionTypeAliasElement) {
      return '<i class=icon-cog></i> ';
    } else if (e is PropertyInducingElement) {
      return '<i class=icon-minus-sign></i> ';
    } else if (e is ConstructorElement) {
      return '<i class=icon-plus-sign></i> ';
    } else if (e is ExecutableElement) {
      return '<i class=icon-ok-sign></i> ';
    } else {
      return '';
    }
  }

  String generateOverrideIcon(MethodElement element) {
    Element o = getOverriddenElement(element);

    if (o == null) {
      return '';
    } else if (!generator.isDocumented(o)) {
      return "<i title='Overrides ${getNameFor(o)}' " "class='icon-circle-arrow-up icon-disabled'></i> ";
    } else {
      return "<a href='${generator.createHrefFor(o)}'>" "<i title='Overrides ${getNameFor(o)}' " "class='icon-circle-arrow-up'></i></a> ";
    }
  }

  String getNameFor(Element e) {
    ClassElement c = getEnclosingElement(e);
    // TODO: upscale this! handle ctors
    String ext = (e is ExecutableElement) ? '()' : '';
    return '${c.name}.${htmlEscape(e.name)}${ext}';
  }

  void generateClass(ClassHelper helper) {
    ClassElement c = helper.element;
    html.write(createAnchor(c));
    html.writeln('<hr>');
    html.startTag('h4');
    generateAnnotations(c.metadata);
    html.write(createIconFor(c));
    if (c.isAbstract) {
      html.write('Abstract class ${c.name}');
    } else {
      html.write('Class ${c.name}');
    }
    if (c.supertype != null && c.supertype.element.supertype != null) {
      html.write(' extends ${generator.createLinkedTypeName(c.supertype)}');
    }
    if (!c.mixins.isEmpty) {
      html.write(' with');
      for (int i = 0; i < c.mixins.length; i++) {
        if (i == 0) {
          html.write(' ');
        } else {
          html.write(', ');
        }
        html.write(generator.createLinkedTypeName(c.mixins[i]));
      }
    }

    if (!c.interfaces.isEmpty) {
      html.write(' implements');
      for (int i = 0; i < c.interfaces.length; i++) {
        if (i == 0) {
          html.write(' ');
        } else {
          html.write(', ');
        }
        html.write(generator.createLinkedTypeName(c.interfaces[i]));
      }
    }

    html.endTag();

    html.startTag('dl', attributes: 'class=dl-horizontal');
    createToc(helper.getStaticFields());
    createToc(helper.getInstanceFields());
    createToc(helper.getAccessors());
    createToc(helper.getCtors());
    createToc(helper.getMethods());
    html.endTag();

    printComments(c);

    generateElements(helper.getStaticFields(), false);
    generateElements(helper.getInstanceFields(), false);
    generateElements(helper.getAccessors(), false);
    generateElements(helper.getCtors(), false);
    generateElements(helper.getMethods(), false);
  }

  void printComments(Element e, [bool indent = true]) {
    String comments = getDocumentationFor(e);
    if (comments != null) {
      if (indent) {
        html.startTag('div', attributes: "class=indent");
      }
      html.tag('p', contents: prettifyDocs(new Resolver(generator, e), comments));
      if (indent) {
        html.endTag();
      }
    } else {
      if (indent) {
        html.tag('div', attributes: "class=indent");
      }
    }
  }
}

class Resolver extends CodeResolver {
  Generator generator;
  Element element;

  Resolver(this.generator, this.element);

  String resolveCodeReference(String reference) {
    Element e = (element as ElementImpl).getChild(reference);

    if (e is LocalElement /*|| e is TypeVariableElement*/) {
      e = null;
    }
    if (e != null) {
      return generator.createLinkedName(e, true);
    } else {
      //return "<a>$reference</a>";
      return "<code>$reference</code>";
    }
  }
}

class GeneratorHelper implements Generator {

  Set<LibraryElement> libraries;

  GeneratorHelper(this.libraries);

  bool isDocumented(Element e) {
    return libraries.contains(e.library);
  }


  String createLinkedName(Element e, [bool appendParens = false]) {
    if (e == null) {
      return '';
    }
    if (!isDocumented(e)) {
      return htmlEscape(e.name);
    }
    if (e.name.startsWith('_')) {
      return htmlEscape(e.name);
    }
    ClassElement c = getEnclosingElement(e);
    if (c != null && c.name.startsWith('_')) {
      return '${c.name}.${htmlEscape(e.name)}';
    }
    if (c != null && e is ConstructorElement) {
      String name;
      if (e.name.isEmpty) {
        name = c.name;
      } else {
        name = '${c.name}.${htmlEscape(e.name)}';
      }
      if (appendParens) {
        return "<a href=${createHrefFor(e)}>${name}()</a>";
      } else {
        return "<a href=${createHrefFor(e)}>${name}</a>";
      }
    } else {
      String append = '';

      if (appendParens && (e is MethodElement || e is FunctionElement)) {
        append = '()';
      }
      return "<a href=${createHrefFor(e)}>${htmlEscape(e.name)}$append</a>";
    }
  }

  String createLinkedTypeName(DartType type) {
    StringBuffer buf = new StringBuffer();

    if (type is TypeParameterType) {
      buf.write(type.element.name);
    } else {
      buf.write(createLinkedName(type.element));
    }

    if (type is ParameterizedType) {
      ParameterizedType pType = type;

      if (!pType.typeArguments.isEmpty) {
        buf.write('&lt;');
        for (int i = 0; i < pType.typeArguments.length; i++) {
          if (i > 0) {
            buf.write(', ');
          }
          DartType t = pType.typeArguments[i];
          buf.write(createLinkedTypeName(t));
        }
        buf.write('&gt;');
      }
    }
    return buf.toString();
  }

  String createLinkedReturnTypeName(FunctionType type) {
    if (type.returnType.element == null) {
      if (type.returnType.name != null) {
        return type.returnType.name;
      } else {
        return '';
      }
    } else {
      return createLinkedTypeName(type.returnType);
    }
  }

  String printParams(List<ParameterElement> params) {
    StringBuffer buf = new StringBuffer();

    for (ParameterElement p in params) {
      if (buf.length > 0) {
        buf.write(', ');
      }

      if (p.type != null && p.type.name != null) {
        buf.write(createLinkedTypeName(p.type));
        buf.write(' ');
      }

      buf.write(p.name);
    }

    return buf.toString();
  }

  String createHrefFor(Element e) {
    if (!isDocumented(e)) {
      return '';
    }

    ClassElement c = getEnclosingElement(e);

    if (c != null) {
      return '${getFileNameFor(e.library)}#${c.name}.${escapeBrackets(e.name)}';
    } else {
      return '${getFileNameFor(e.library)}#${e.name}';
    }
  }


}



String createAnchor(Element e) {
  ClassElement c = getEnclosingElement(e);

  if (c != null) {
    return '<a id=${c.name}.${escapeBrackets(e.name)}></a>';
  } else {
    return '<a id=${e.name}></a>';
  }
}
