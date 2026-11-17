// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library for getting external source code links for Dartdoc.
library;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;

final _uriTemplateRegExp = RegExp(r'(%[frl]%)');

mixin SourceLinkerOptionContext implements DartdocOptionContextBase {
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
            help: 'A list of directories to exclude from linking to a source '
                'code repository.'),
        // TODO(jcollins-g): Use [DartdocOptionArgSynth], possibly in
        // combination with a repository type and the root directory, and get
        // revision number automatically.
        DartdocOptionArgOnly<String?>('revision', null, resourceProvider,
            help: 'Revision number to insert into the URI.'),
        DartdocOptionArgFile<String?>('root', null, resourceProvider,
            optionIs: OptionKind.dir,
            help:
                'Path to a local directory that is the root of the repository '
                'we link to.  All source code files under this directory will '
                'be linked.'),
        DartdocOptionArgFile<String?>('uriTemplate', null, resourceProvider,
            help: '''
Substitute into this template to generate a uri for an element's source code.
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

  /// Called with the URL when [href] rejects it as not a plain http(s) URL.
  final void Function(String url)? onInvalidUrl;

  /// Most users of this class should use the [SourceLinker.fromElement] factory
  /// instead.  This constructor is public for testing.
  SourceLinker(
      {required this.excludes,
      required this.lineNumber,
      required this.sourceFileName,
      this.revision,
      this.root,
      this.uriTemplate,
      this.onInvalidUrl}) {
    if (revision != null || root != null || uriTemplate != null) {
      if (root == null || uriTemplate == null) {
        throw DartdocOptionError(
            'linkToSource root and uriTemplate must both be specified to '
            'generate repository links');
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
      // Warn on the default package, not on `element.package`: warnings on
      // non-local packages are hidden by default, but this one affects the
      // output of the package being documented. Leaving the element out of the
      // message deduplicates the warning to once per package.
      onInvalidUrl: (url) =>
          element.packageGraph.defaultPackage.warn(PackageWarning.invalidUrl,
              message: 'linkToSource.uriTemplate '
                  "'${config.linkToSourceUriTemplate}' "
                  'in package:${element.package.name}'),
    );
  }

  /// The URL of the source of [sourceFileName] at [lineNumber], or the empty
  /// string if there is none.
  ///
  /// The result is written into an `href` attribute, so anything that is not a
  /// plain http(s) URL is rejected (see [isSafeHttpUrl]).
  String href() {
    var root = this.root;
    var uriTemplate = this.uriTemplate;
    if (root == null || uriTemplate == null) {
      return '';
    }
    if (!path.isWithin(root, sourceFileName) ||
        excludes
            .any((String exclude) => path.isWithin(exclude, sourceFileName))) {
      return '';
    }
    var href = uriTemplate.replaceAllMapped(_uriTemplateRegExp, (match) {
      return switch (match[1]) {
        '%f%' => path.url
            .joinAll(path.split(path.relative(sourceFileName, from: root))),
        '%r%' => revision!,
        '%l%' => lineNumber.toString(),
        _ => ''
      };
    });
    if (!isSafeHttpUrl(href)) {
      onInvalidUrl?.call(href);
      return '';
    }
    return href;
  }
}
