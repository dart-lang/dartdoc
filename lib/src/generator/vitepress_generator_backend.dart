// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_backend.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/generator/vitepress_doc_processor.dart';
import 'package:dartdoc/src/generator/vitepress_guide_generator.dart';
import 'package:dartdoc/src/generator/vitepress_init.dart';
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

  final String _outputPath;
  final String _packageName;
  final String _repositoryUrl;
  final List<String> _guideDirs;
  final List<String> _guideInclude;
  final List<String> _guideExclude;

  /// Tracks all file paths written during this generation run.
  ///
  /// Used for incremental generation: after generation completes, files
  /// in the output directory that are NOT in this set can be deleted
  /// as stale artifacts from renamed/removed elements.
  final Set<String> _expectedFiles = {};

  /// Number of files actually written (content changed or new).
  int _writtenCount = 0;

  /// Number of files skipped because content was identical.
  int _unchangedCount = 0;

  VitePressGeneratorBackend(
    DartdocGeneratorBackendOptions options,
    FileWriter writer,
    ResourceProvider resourceProvider, {
    required String outputPath,
    required String packageName,
    String repositoryUrl = '',
    List<String> guideDirs = const ['doc', 'docs'],
    List<String> guideInclude = const [],
    List<String> guideExclude = const [],
  })  : _paths = VitePressPathResolver(),
        _outputPath = outputPath,
        _packageName = packageName,
        _repositoryUrl = repositoryUrl,
        _guideDirs = guideDirs,
        _guideInclude = guideInclude,
        _guideExclude = guideExclude,
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
    _paths.initFromPackageGraph(packageGraph);
    _docs = VitePressDocProcessor(packageGraph, _paths);
    _sidebar = VitePressSidebarGenerator(_paths);

    final isMultiPackage = packageGraph.localPackages.length > 1;

    if (isMultiPackage) {
      logInfo('Generating VitePress docs for workspace '
          '(${packageGraph.localPackages.length} packages)...');
    } else {
      logInfo('Generating VitePress docs for package ${package.name}...');
    }

    // Write package/workspace overview page: api/index.md
    String content;
    if (isMultiPackage) {
      content = renderer.renderWorkspaceOverview(packageGraph, _paths, _docs);
    } else {
      content = renderer.renderPackagePage(package, _paths, _docs);
    }
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

    // Generate guide files from doc/docs directories.
    var guideGen = VitePressGuideGenerator(
      resourceProvider: resourceProvider,
      scanDirs: _guideDirs,
      include: _guideInclude,
      exclude: _guideExclude,
    );
    var guideEntries = guideGen.collectGuideEntries(
      packageGraph: packageGraph,
      isMultiPackage: isMultiPackage,
    );

    // Write guide files through _writeMarkdown for incremental checks.
    for (final entry in guideEntries) {
      _writeMarkdown(entry.relativePath, entry.content);
    }

    // Track scaffold guide/index.md so stale cleanup doesn't delete it.
    _expectedFiles.add(p.join('guide', 'index.md'));

    var guideSidebarContent = guideGen.generateSidebar(
      guideEntries,
      isMultiPackage: isMultiPackage,
    );
    _writeMarkdown(
      p.join('.vitepress', 'generated', 'guide-sidebar.ts'),
      guideSidebarContent,
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
    try {
      var content = renderer.renderClassPage(class_, library, _paths, _docs);
      var filePath = _paths.filePathFor(class_);
      if (filePath != null) {
        _writeMarkdown(filePath, content);
      }
    } on Object catch (e) {
      logWarning('Failed to generate page for class ${class_.name}: $e');
    }

    runtimeStats.incrementAccumulator('writtenClassFileCount');
  }

  /// Generates an enum page with enum values and all members embedded.
  ///
  /// Output: `api/<dirName>/<EnumName>.md`
  @override
  void generateEnum(PackageGraph packageGraph, Library library, Enum enum_) {
    try {
      var content = renderer.renderEnumPage(enum_, library, _paths, _docs);
      var filePath = _paths.filePathFor(enum_);
      if (filePath != null) {
        _writeMarkdown(filePath, content);
      }
    } on Object catch (e) {
      logWarning('Failed to generate page for enum ${enum_.name}: $e');
    }

    runtimeStats.incrementAccumulator('writtenEnumFileCount');
  }

  /// Generates a mixin page with superclass constraints and all members.
  ///
  /// Output: `api/<dirName>/<MixinName>.md`
  @override
  void generateMixin(PackageGraph packageGraph, Library library, Mixin mixin) {
    try {
      var content = renderer.renderMixinPage(mixin, library, _paths, _docs);
      var filePath = _paths.filePathFor(mixin);
      if (filePath != null) {
        _writeMarkdown(filePath, content);
      }
    } on Object catch (e) {
      logWarning('Failed to generate page for mixin ${mixin.name}: $e');
    }

    runtimeStats.incrementAccumulator('writtenMixinFileCount');
  }

  /// Generates an extension page with extended type and all members.
  ///
  /// Output: `api/<dirName>/<ExtensionName>.md`
  @override
  void generateExtension(
      PackageGraph packageGraph, Library library, Extension extension) {
    try {
      var content =
          renderer.renderExtensionPage(extension, library, _paths, _docs);
      var filePath = _paths.filePathFor(extension);
      if (filePath != null) {
        _writeMarkdown(filePath, content);
      }
    } on Object catch (e) {
      logWarning('Failed to generate page for extension ${extension.name}: $e');
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
    try {
      var content = renderer.renderExtensionTypePage(
          extensionType, library, _paths, _docs);
      var filePath = _paths.filePathFor(extensionType);
      if (filePath != null) {
        _writeMarkdown(filePath, content);
      }
    } on Object catch (e) {
      logWarning(
          'Failed to generate page for extension type ${extensionType.name}: $e');
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
    try {
      var content =
          renderer.renderFunctionPage(function, library, _paths, _docs);
      var filePath = _paths.filePathFor(function);
      if (filePath != null) {
        _writeMarkdown(filePath, content);
      }
    } on Object catch (e) {
      logWarning('Failed to generate page for function ${function.name}: $e');
    }

    runtimeStats.incrementAccumulator('writtenFunctionFileCount');
  }

  /// Generates a top-level property or constant page.
  ///
  /// Output: `api/<dirName>/<PropertyName>.md`
  @override
  void generateTopLevelProperty(
      PackageGraph packageGraph, Library library, TopLevelVariable property) {
    try {
      var content =
          renderer.renderPropertyPage(property, library, _paths, _docs);
      var filePath = _paths.filePathFor(property);
      if (filePath != null) {
        _writeMarkdown(filePath, content);
      }
    } on Object catch (e) {
      logWarning('Failed to generate page for property ${property.name}: $e');
    }

    runtimeStats.incrementAccumulator('writtenTopLevelPropertyFileCount');
  }

  /// Generates a typedef page.
  ///
  /// Output: `api/<dirName>/<TypedefName>.md`
  @override
  void generateTypeDef(
      PackageGraph packageGraph, Library library, Typedef typedef) {
    try {
      var content = renderer.renderTypedefPage(typedef, library, _paths, _docs);
      var filePath = _paths.filePathFor(typedef);
      if (filePath != null) {
        _writeMarkdown(filePath, content);
      }
    } on Object catch (e) {
      logWarning('Failed to generate page for typedef ${typedef.name}: $e');
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

  /// Finalizes VitePress generation: deletes stale files and logs summary.
  ///
  /// VitePress has built-in full-text search via MiniSearch, so no search
  /// index is generated. Instead, this method is used as a finalization hook
  /// (it is called last by the traversal) to clean up stale files and log
  /// generation statistics.
  @override
  void generateSearchIndex(List<Documentable> indexedElements) {
    _deleteStaleFiles();
    _logSummary();
  }

  /// No-op: category JSON is only used by the HTML frontend.
  @override
  void generateCategoryJson(List<ModelElement> categorizedElements) {
    // Intentionally empty -- not needed for VitePress.
  }

  /// Called BEFORE the traversal at `generator.dart:49`.
  ///
  /// Creates VitePress scaffold files (`package.json`, `.vitepress/config.ts`,
  /// `index.md`) if they don't already exist. These are one-time setup files
  /// that the user may customize afterwards.
  @override
  Future<void> generateAdditionalFiles() async {
    var initGenerator = VitePressInitGenerator(
      writer: writer,
      resourceProvider: resourceProvider,
      outputPath: _outputPath,
    );
    await initGenerator.generate(
      packageName: _packageName,
      repositoryUrl: _repositoryUrl,
    );
  }

  // ---------------------------------------------------------------------------
  // File writing
  // ---------------------------------------------------------------------------

  /// Writes markdown content to the output directory (incremental).
  ///
  /// Tracks the file path in [_expectedFiles] for manifest-based stale file
  /// deletion. Compares new content against the existing file on disk and
  /// skips the write if identical, incrementing [_unchangedCount] instead
  /// of [_writtenCount].
  void _writeMarkdown(String filePath, String content) {
    _expectedFiles.add(filePath);

    // Incremental generation: skip write if content is unchanged.
    final fullPath = p.join(_outputPath, filePath);
    final existingFile = resourceProvider.getFile(fullPath);
    if (existingFile.exists) {
      try {
        if (existingFile.readAsStringSync() == content) {
          _unchangedCount++;
          return;
        }
      } on FileSystemException {
        // If we can't read the file, fall through to write.
      }
    }

    writer.write(filePath, content);
    _writtenCount++;
  }

  // ---------------------------------------------------------------------------
  // Stale file cleanup
  // ---------------------------------------------------------------------------

  /// Number of stale files deleted during cleanup.
  int _deletedCount = 0;

  /// Scans the output `api/` directory and deletes files not in
  /// [_expectedFiles].
  ///
  /// Only deletes `.md` files under `api/` and `.ts` files under
  /// `.vitepress/generated/` to avoid removing user-created files.
  void _deleteStaleFiles() {
    _deletedCount = 0;
    _deleteStaleInDir('api', '.md');
    _deleteStaleInDir('guide', '.md');
    _deleteStaleInDir(p.join('.vitepress', 'generated'), '.ts');
  }

  /// Recursively scans [dirRelative] under [_outputPath] and deletes files
  /// with [extension] that are NOT in [_expectedFiles].
  ///
  /// Uses a [visited] set to protect against symlink loops (same approach as
  /// `_collectMarkdownFiles` in `vitepress_guide_generator.dart`).
  /// Normalizes paths to POSIX separators for cross-platform consistency.
  void _deleteStaleInDir(String dirRelative, String extension,
      [Set<String>? visited]) {
    visited ??= {};
    final dirPath = p.join(_outputPath, dirRelative);
    if (!visited.add(dirPath)) return; // Symlink loop protection.
    final folder = resourceProvider.getFolder(dirPath);
    if (!folder.exists) return;

    for (final child in folder.getChildren()) {
      if (child is Folder) {
        // Recurse into subdirectories.
        final relativePath = p.relative(child.path, from: _outputPath);
        _deleteStaleInDir(relativePath, extension, visited);
      } else {
        // Normalize to POSIX separators so the path matches _expectedFiles
        // (which always uses forward slashes).
        final relativePath =
            p.posix.joinAll(p.split(p.relative(child.path, from: _outputPath)));
        if (relativePath.endsWith(extension) &&
            !_expectedFiles.contains(relativePath)) {
          try {
            (child as File).delete();
            _deletedCount++;
          } on FileSystemException {
            // If we can't delete the file, skip it silently.
          }
        }
      }
    }
  }

  /// Logs a summary of generation statistics.
  void _logSummary() {
    logInfo(
      'Generated: $_writtenCount written, '
      '$_unchangedCount unchanged, '
      '$_deletedCount deleted',
    );
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

  /// Number of stale files deleted during cleanup.
  int get deletedCount => _deletedCount;
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
