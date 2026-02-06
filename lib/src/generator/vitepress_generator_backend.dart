// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_backend.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/generator/vitepress_doc_processor.dart';
import 'package:dartdoc/src/generator/vitepress_paths.dart'
    show VitePressPathResolver;
import 'package:dartdoc/src/generator/vitepress_renderer.dart' as renderer;
import 'package:dartdoc/src/generator/vitepress_sidebar_generator.dart'
    show VitePressSidebarGenerator;
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:path/path.dart' as p;

/// Generator backend that produces VitePress-compatible markdown documentation.
///
/// Extends [GeneratorBackend] to reuse the model traversal loop from
/// [Generator._generateDocs], but overrides ALL 17 `generate*()` methods to
/// produce `.md` files instead of `.html` files.
///
/// Key design decisions:
/// - Never calls `super.generate*()` (super produces HTML via templates).
/// - Passes [_NoOpTemplates] stub to satisfy the base constructor's
///   [Templates] requirement.
/// - Member-level methods (`generateConstructor`, `generateMethod`,
///   `generateProperty`) are no-ops because members are embedded inline
///   on their container's page (class, enum, mixin, extension).
/// - Sidebar is generated in [generatePackage] because it is called first
///   by the traversal and has access to the full [PackageGraph].
/// - Uses [_writeMarkdown] for all file writes; never uses the base class
///   [write] method (which performs `htmlBasePlaceholder` replacement).
class VitePressGeneratorBackend extends GeneratorBackend {
  final VitePressPathResolver _paths;
  late VitePressDocProcessor _docs;
  late VitePressSidebarGenerator _sidebar;

  /// Tracks all file paths written during this generation run.
  ///
  /// Used for incremental generation: after generation completes, files
  /// in the output directory that are NOT in this set can be deleted
  /// as stale artifacts from renamed/removed elements.
  final Set<String> _expectedFiles = {};

  /// Number of files actually written (content changed or new).
  int _writtenCount = 0;

  /// Number of files skipped because content was identical.
  // ignore: prefer_final_fields
  int _unchangedCount = 0;

  VitePressGeneratorBackend(
    DartdocGeneratorBackendOptions options,
    FileWriter writer,
    ResourceProvider resourceProvider,
  )   : _paths = VitePressPathResolver(),
        super(options, _NoOpTemplates(), writer, resourceProvider);

  // ---------------------------------------------------------------------------
  // Package -- called first by the traversal (generator.dart:86-87).
  // ---------------------------------------------------------------------------

  /// Generates the package overview page and the VitePress sidebar.
  ///
  /// This is the first container-level method called by the traversal. We
  /// initialize the doc processor and sidebar generator here because the
  /// [PackageGraph] is now available.
  @override
  void generatePackage(PackageGraph packageGraph, Package package) {
    // Initialize dependencies that require the PackageGraph.
    _docs = VitePressDocProcessor(packageGraph, _paths);
    _sidebar = VitePressSidebarGenerator(_paths);

    logInfo('Generating VitePress docs for package ${package.name}...');

    // Write package overview page: api/index.md
    var content = renderer.renderPackagePage(package, _paths, _docs);
    var filePath = _paths.filePathFor(package);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    // Generate sidebar from the full PackageGraph.
    var sidebarContent = _sidebar.generate(packageGraph);
    _writeMarkdown(
      p.join('.vitepress', 'generated', 'api-sidebar.ts'),
      sidebarContent,
    );

    runtimeStats.incrementAccumulator('writtenPackageFileCount');
  }

  // ---------------------------------------------------------------------------
  // Category
  // ---------------------------------------------------------------------------

  /// Generates a category (topic) page.
  ///
  /// Output: `topics/<CategoryName>.md`
  ///
  /// Unlike the HTML backend, no redirect file is generated -- VitePress
  /// handles clean URLs natively.
  @override
  void generateCategory(PackageGraph packageGraph, Category category) {
    logInfo(
      'Generating docs for category ${category.name} '
      'from ${category.package.fullyQualifiedName}...',
    );

    var content = renderer.renderCategoryPage(category, _paths, _docs);
    var filePath = _paths.filePathFor(category);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenCategoryFileCount');
  }

  // ---------------------------------------------------------------------------
  // Library
  // ---------------------------------------------------------------------------

  /// Generates the library overview page.
  ///
  /// Output: `api/<dirName>/index.md`
  ///
  /// No redirect file is generated (the HTML backend writes one for the
  /// old library path; VitePress does not need this).
  @override
  void generateLibrary(PackageGraph packageGraph, Library library) {
    logInfo('Generating docs for library ${library.name}...');

    var content = renderer.renderLibraryPage(library, _paths, _docs);
    var filePath = _paths.filePathFor(library);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenLibraryFileCount');
  }

  // ---------------------------------------------------------------------------
  // Container-level: Class, Enum, Mixin, Extension, ExtensionType
  //
  // Each produces ONE markdown file with all members inlined as sections.
  // ---------------------------------------------------------------------------

  /// Generates a class page with all members (constructors, properties,
  /// methods, operators) embedded as sections.
  ///
  /// Output: `api/<dirName>/<ClassName>.md`
  @override
  void generateClass(PackageGraph packageGraph, Library library, Class class_) {
    var content = renderer.renderClassPage(class_, library, _paths, _docs);
    var filePath = _paths.filePathFor(class_);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenClassFileCount');
  }

  /// Generates an enum page with enum values and all members embedded.
  ///
  /// Output: `api/<dirName>/<EnumName>.md`
  @override
  void generateEnum(PackageGraph packageGraph, Library library, Enum enum_) {
    var content = renderer.renderEnumPage(enum_, library, _paths, _docs);
    var filePath = _paths.filePathFor(enum_);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenEnumFileCount');
  }

  /// Generates a mixin page with superclass constraints and all members.
  ///
  /// Output: `api/<dirName>/<MixinName>.md`
  @override
  void generateMixin(PackageGraph packageGraph, Library library, Mixin mixin) {
    var content = renderer.renderMixinPage(mixin, library, _paths, _docs);
    var filePath = _paths.filePathFor(mixin);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenMixinFileCount');
  }

  /// Generates an extension page with extended type and all members.
  ///
  /// Output: `api/<dirName>/<ExtensionName>.md`
  @override
  void generateExtension(
      PackageGraph packageGraph, Library library, Extension extension) {
    var content =
        renderer.renderExtensionPage(extension, library, _paths, _docs);
    var filePath = _paths.filePathFor(extension);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenExtensionFileCount');
  }

  /// Generates an extension type page with representation type and all
  /// members.
  ///
  /// Output: `api/<dirName>/<ExtensionTypeName>.md`
  @override
  void generateExtensionType(
      PackageGraph packageGraph, Library library, ExtensionType extensionType) {
    var content =
        renderer.renderExtensionTypePage(extensionType, library, _paths, _docs);
    var filePath = _paths.filePathFor(extensionType);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenExtensionTypeFileCount');
  }

  // ---------------------------------------------------------------------------
  // Top-level elements: Function, Property, Typedef
  //
  // Each produces one page per element.
  // ---------------------------------------------------------------------------

  /// Generates a top-level function page.
  ///
  /// Output: `api/<dirName>/<FunctionName>.md`
  @override
  void generateFunction(
      PackageGraph packageGraph, Library library, ModelFunction function) {
    var content = renderer.renderFunctionPage(function, library, _paths, _docs);
    var filePath = _paths.filePathFor(function);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenFunctionFileCount');
  }

  /// Generates a top-level property or constant page.
  ///
  /// Output: `api/<dirName>/<PropertyName>.md`
  @override
  void generateTopLevelProperty(
      PackageGraph packageGraph, Library library, TopLevelVariable property) {
    var content = renderer.renderPropertyPage(property, library, _paths, _docs);
    var filePath = _paths.filePathFor(property);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenTopLevelPropertyFileCount');
  }

  /// Generates a typedef page.
  ///
  /// Output: `api/<dirName>/<TypedefName>.md`
  @override
  void generateTypeDef(
      PackageGraph packageGraph, Library library, Typedef typedef) {
    var content = renderer.renderTypedefPage(typedef, library, _paths, _docs);
    var filePath = _paths.filePathFor(typedef);
    if (filePath != null) {
      _writeMarkdown(filePath, content);
    }

    runtimeStats.incrementAccumulator('writtenTypedefFileCount');
  }

  // ---------------------------------------------------------------------------
  // Member-level methods -- NO-OPs.
  //
  // Members (constructors, methods, properties, operators) are embedded
  // directly on their container's page as anchored sections. The traversal
  // in generator.dart still calls these methods, but we intentionally
  // produce no output.
  // ---------------------------------------------------------------------------

  /// No-op: constructors are rendered inline on the class/enum page.
  @override
  void generateConstructor(PackageGraph packageGraph, Library library,
      Constructable constructable, Constructor constructor) {
    // Intentionally empty -- constructors are embedded on the container page.
  }

  /// No-op: methods are rendered inline on the container page.
  @override
  void generateMethod(PackageGraph packageGraph, Library library,
      Container container, Method method) {
    // Intentionally empty -- methods are embedded on the container page.
  }

  /// No-op: properties/fields are rendered inline on the container page.
  @override
  void generateProperty(PackageGraph packageGraph, Library library,
      Container container, Field field) {
    // Intentionally empty -- properties are embedded on the container page.
  }

  // ---------------------------------------------------------------------------
  // Infrastructure -- NO-OPs for VitePress.
  // ---------------------------------------------------------------------------

  /// No-op: VitePress has built-in full-text search via MiniSearch.
  ///
  /// The HTML backend writes `index.json` for its custom search; VitePress
  /// does not need this.
  @override
  void generateSearchIndex(List<Documentable> indexedElements) {
    // Intentionally empty -- VitePress provides its own search.
  }

  /// No-op: category JSON is only used by the HTML frontend.
  @override
  void generateCategoryJson(List<ModelElement> categorizedElements) {
    // Intentionally empty -- not needed for VitePress.
  }

  /// No-op: called BEFORE the traversal at `generator.dart:49`, so no model
  /// data is available yet.
  ///
  /// The HTML backend uses this to copy static resources (CSS, JS, favicon).
  /// VitePress handles its own static assets, so nothing to do here.
  @override
  Future<void> generateAdditionalFiles() async {
    // Intentionally empty -- VitePress manages its own static assets.
  }

  // ---------------------------------------------------------------------------
  // File writing
  // ---------------------------------------------------------------------------

  /// Writes markdown content to the output directory.
  ///
  /// Tracks the file path in [_expectedFiles] for manifest-based stale file
  /// deletion. In the future, this method will compare content against the
  /// existing file and skip the write if identical (incremental generation).
  void _writeMarkdown(String filePath, String content) {
    _expectedFiles.add(filePath);
    writer.write(filePath, content);
    _writtenCount++;
  }

  // ---------------------------------------------------------------------------
  // Accessors for generation statistics
  // ---------------------------------------------------------------------------

  /// All file paths written during this generation run.
  Set<String> get expectedFiles => Set.unmodifiable(_expectedFiles);

  /// Number of files that were written (new or changed content).
  int get writtenCount => _writtenCount;

  /// Number of files skipped because content was identical.
  int get unchangedCount => _unchangedCount;
}

// ---------------------------------------------------------------------------
// _NoOpTemplates
// ---------------------------------------------------------------------------

/// A no-op [Templates] implementation that satisfies [GeneratorBackend]'s
/// constructor requirement.
///
/// [VitePressGeneratorBackend] never calls any template rendering methods
/// because it overrides all `generate*()` methods and never delegates to
/// `super`. All template methods return an empty string.
class _NoOpTemplates implements Templates {
  @override
  String renderCategory(CategoryTemplateData context) => '';

  @override
  String renderCategoryRedirect(CategoryTemplateData context) => '';

  @override
  String renderClass<T extends Class>(ClassTemplateData context) => '';

  @override
  String renderConstructor(ConstructorTemplateData context) => '';

  @override
  String renderEnum(EnumTemplateData context) => '';

  @override
  String renderError(PackageTemplateData context) => '';

  @override
  String renderExtension(ExtensionTemplateData context) => '';

  @override
  String renderExtensionType(ExtensionTypeTemplateData context) => '';

  @override
  String renderFunction(FunctionTemplateData context) => '';

  @override
  String renderIndex(PackageTemplateData context) => '';

  @override
  String renderLibrary(LibraryTemplateData context) => '';

  @override
  String renderLibraryRedirect(LibraryTemplateData context) => '';

  @override
  String renderMethod(MethodTemplateData context) => '';

  @override
  String renderMixin(MixinTemplateData context) => '';

  @override
  String renderProperty(PropertyTemplateData context) => '';

  @override
  String renderSearchPage(PackageTemplateData context) => '';

  @override
  String renderSidebarForContainer(
          TemplateDataWithContainer<Documentable> context) =>
      '';

  @override
  String renderSidebarForLibrary(
          TemplateDataWithLibrary<Documentable> context) =>
      '';

  @override
  String renderTopLevelProperty(TopLevelPropertyTemplateData context) => '';

  @override
  String renderTypedef(TypedefTemplateData context) => '';
}
