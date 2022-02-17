// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library for getting external source code links for Dartdoc.
library dartdoc.source_linker;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:path/path.dart' as p;

final _uriTemplateRegExp = RegExp(r'(%[frl]%)');

abstract class SourceLinkerOptionContext implements DartdocOptionContextBase {
  List<String> get linkToSourceExcludes =>
      optionSet['linkToSource']['excludes'].valueAt(context);

  String? get linkToSourceRevision =>
      optionSet['linkToSource']['revision'].valueAt(context);

  String? get linkToSourceRoot =>
      optionSet['linkToSource']['root'].valueAt(context);

  String? get linkToSourceUriTemplate =>
      optionSet['linkToSource']['uriTemplate'].valueAt(context);
}

List<DartdocOption<Object?>> createSourceLinkerOptions(
    ResourceProvider resourceProvider) {
  return [
    DartdocOptionSet('linkToSource', resourceProvider)
      ..addAll([
        DartdocOptionArgFile<List<String>>('excludes', [], resourceProvider,
            optionIs: OptionKind.dir,
            help:
                'A list of directories to exclude from linking to a source code repository.'),
        // TODO(jcollins-g): Use [DartdocOptionArgSynth], possibly in combination with a repository type and the root directory, and get revision number automatically
        DartdocOptionArgOnly<String?>('revision', null, resourceProvider,
            help: 'Revision number to insert into the URI.'),
        DartdocOptionArgFile<String?>('root', null, resourceProvider,
            optionIs: OptionKind.dir,
            help:
                'Path to a local directory that is the root of the repository we link to.  All source code files under this directory will be linked.'),
        DartdocOptionArgFile<String?>('uriTemplate', null, resourceProvider,
            help:
                '''Substitute into this template to generate a uri for an element's source code.
             Dartdoc dynamically substitutes the following fields into the template:
               %f%:  Relative path of file to the repository root
               %r%:  Revision number
               %l%:  Line number'''),
      ])
  ];
}

class SourceLinker {
  final List<String> excludes;
  final int lineNumber;
  final String sourceFileName;
  final String? revision;
  final String? root;
  final String? uriTemplate;

  /// Most users of this class should use the [SourceLinker.fromElement] factory
  /// instead.  This constructor is public for testing.
  SourceLinker(
      {required this.excludes,
      required this.lineNumber,
      required this.sourceFileName,
      this.revision,
      this.root,
      this.uriTemplate}) {
    if (revision != null || root != null || uriTemplate != null) {
      if (root == null || uriTemplate == null) {
        throw DartdocOptionError(
            'linkToSource root and uriTemplate must both be specified to generate repository links');
      }
      var uriTemplateValue = uriTemplate;
      if (uriTemplateValue != null &&
          uriTemplateValue.contains('%r%') &&
          revision == null) {
        throw DartdocOptionError(
            r'%r% specified in uriTemplate, but no revision available');
      }
    }
  }

  /// Build a SourceLinker from a ModelElement.
  factory SourceLinker.fromElement(ModelElement element) {
    SourceLinkerOptionContext config = element.config;
    return SourceLinker(
      excludes: config.linkToSourceExcludes,
      // TODO(jcollins-g): disallow defaulting?  Some elements come back without
      // a line number right now.
      lineNumber: element.characterLocation?.lineNumber ?? 1,
      sourceFileName: element.sourceFileName,
      revision: config.linkToSourceRevision,
      root: config.linkToSourceRoot,
      uriTemplate: config.linkToSourceUriTemplate,
    );
  }

  String href() {
    var root = this.root;
    var uriTemplate = this.uriTemplate;
    if (root == null || uriTemplate == null) {
      return '';
    }
    if (!p.isWithin(root, sourceFileName) ||
        excludes.any((String exclude) => p.isWithin(exclude, sourceFileName))) {
      return '';
    }
    return uriTemplate.replaceAllMapped(_uriTemplateRegExp, (match) {
      switch (match[1]) {
        case '%f%':
          var urlContext = p.Context(style: p.Style.url);
          return urlContext
              .joinAll(p.split(p.relative(sourceFileName, from: root)));
        case '%r%':
          return revision!;
        case '%l%':
          return lineNumber.toString();
        default:
          return '';
      }
    });
  }
}
