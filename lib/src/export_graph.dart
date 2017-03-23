import 'package:analyzer/dart/element/element.dart';

/// Node in the directed export graph.
///
/// It wraps a library element, and also contains links to the nodes/libs, which export this lib,
/// and nodes/libs, which are exported by this lib.
class _ExportGraphNode {
  final LibraryElement libraryElement;
  Set<_ExportGraphNode> exportedBy = new Set();
  Set<_ExportGraphNode> exports = new Set();

  _ExportGraphNode(this.libraryElement);

  /// It returns a "canonical" library element
  ///
  /// That's one of the passed in the arguments, which is the closest if we go up the graph.
  _ExportGraphNode canonicalLibraryElement(
      Iterable<LibraryElement> libraryElements) {
    if (libraryElements.contains(libraryElement)) {
      return this;
    } else {
      return exportedBy.toList().firstWhere(
          (l) => l.canonicalLibraryElement(libraryElements) != null);
    }
  }
}

/// Recursively builds the export graph, and also populates the index [map]. It takes
/// the library element from the arguments, adds it to the index, then goes through all
/// the libraries this library element exports, adds them to the index too and also connects
/// them to build a graph.
void _buildSubGraph(
    Map<String, _ExportGraphNode> map, LibraryElement libraryElement) {
  if (!map.containsKey(libraryElement.source.fullName)) {
    map[libraryElement.source.fullName] = new _ExportGraphNode(libraryElement);
  }
  final node = map[libraryElement.source.fullName];
  libraryElement.exports.forEach((ExportElement export) {
    final exportedLibraryElement = export.exportedLibrary;
    if (!map.containsKey(exportedLibraryElement.source.fullName)) {
      map[exportedLibraryElement.source.fullName] =
          new _ExportGraphNode(exportedLibraryElement);
    }
    final childNode = map[exportedLibraryElement.source.fullName];
    childNode.exportedBy.add(node);
    node.exports.add(childNode);
    _buildSubGraph(map, exportedLibraryElement);
  });
}

/// Directed graph, which allows to track what libs export and being exported by what libs
/// (where libs are the documentable package libraries).
///
/// Also, allows to find the "canonical" library element for the provided element, i.e. the
/// one, which should contain documentation of the provided element.
class ExportGraph {
  final Map<String, _ExportGraphNode> map = {};
  final Iterable<LibraryElement> packageLibraryElements;

  ExportGraph(this.packageLibraryElements) {
    packageLibraryElements.forEach((LibraryElement libraryElement) {
      _buildSubGraph(map, libraryElement);
    });
  }

  LibraryElement canonicalLibraryElement(Element element) {
    if (map.containsKey(element.library.source.fullName)) {
      final node = map[element.library.source.fullName];
      return node
          .canonicalLibraryElement(packageLibraryElements)
          ?.libraryElement;
    } else {
      return element.library;
    }
  }
}
