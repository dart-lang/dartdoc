// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library for getting external source code links for Dartdoc.
library dartdoc.source_linker;

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

final uriTemplateRegexp = RegExp(r'(%[frl]%)');

abstract class SourceLinkerOptionContext implements DartdocOptionContextBase {
  List<String> get linkToSourceExcludes =>
      optionSet['linkToSource']['excludes'].valueAt(context);

  String get linkToSourceRevision =>
      optionSet['linkToSource']['revision'].valueAt(context);

  String get linkToSourceRoot =>
      optionSet['linkToSource']['root'].valueAt(context);

  String get linkToSourceUriTemplate =>
      optionSet['linkToSource']['uriTemplate'].valueAt(context);
}

Future<List<DartdocOption>> createSourceLinkerOptions() async {
  return <DartdocOption>[
    DartdocOptionSet('linkToSource')
      ..addAll([
        DartdocOptionArgFile<List<String>>('excludes', [],
            isDir: true,
            help:
                'A list of directories to exclude from linking to a source code repository.'),
        // TODO(jcollins-g): Use [DartdocOptionArgSynth], possibly in combination with a repository type and the root directory, and get revision number automatically
        DartdocOptionArgOnly<String>('revision', null,
            help: 'Revision number to insert into the URI.'),
        DartdocOptionArgFile<String>('root', null,
            isDir: true,
            help:
                'Path to a local directory that is the root of the repository we link to.  All source code files under this directory will be linked.'),
        DartdocOptionArgFile<String>('uriTemplate', null,
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
  final String revision;
  final String root;
  final String uriTemplate;

  /// Most users of this class should use the [SourceLinker.fromElement] factory
  /// instead.  This constructor is public for testing.
  SourceLinker(
      {@required this.excludes,
      this.lineNumber,
      this.sourceFileName,
      this.revision,
      this.root,
      this.uriTemplate}) {
    if (revision != null || root != null || uriTemplate != null) {
      if (root == null || uriTemplate == null) {
        throw DartdocOptionError(
            'linkToSource root and uriTemplate must both be specified to generate repository links');
      }
      if (uriTemplate.contains('%r%') && revision == null) {
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
    if (sourceFileName == null || root == null || uriTemplate == null) {
      return '';
    }
    if (!path.isWithin(root, sourceFileName) ||
        excludes
            .any((String exclude) => path.isWithin(exclude, sourceFileName))) {
      return '';
    }
    return uriTemplate.replaceAllMapped(uriTemplateRegexp, (match) {
      switch (match[1]) {
        case '%f%':
          var urlContext = path.Context(style: path.Style.url);
          return urlContext
              .joinAll(path.split(path.relative(sourceFileName, from: root)));
          break;
        case '%r%':
          return revision;
          break;
        case '%l%':
          return lineNumber.toString();
          break;
        default:
          return null;
      }
    });
  }
}
