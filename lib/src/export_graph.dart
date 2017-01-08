import 'package:analyzer/dart/element/element.dart';

class _ExportGraphNode {
  final LibraryElement libraryElement;
  Set<_ExportGraphNode> exportedBy = new Set();
  Set<_ExportGraphNode> exports = new Set();

  _ExportGraphNode(this.libraryElement);

  _ExportGraphNode canonicalLibraryElement(Iterable<LibraryElement> libraryElements) {
    if (libraryElements.contains(libraryElement)) {
      return this;
    } else {
      return exportedBy.toList().firstWhere((l) => l.canonicalLibraryElement(libraryElements) != null);
    }
  }
}

void _buildSubGraph(Map<String, _ExportGraphNode> map, LibraryElement libraryElement) {
  if (!map.containsKey(libraryElement.source.fullName)) {
    map[libraryElement.source.fullName] = new _ExportGraphNode(libraryElement);
  }
  final node = map[libraryElement.source.fullName];
  libraryElement.exports.forEach((ExportElement export) {
    final exportedLibraryElement = export.exportedLibrary;
    if (!map.containsKey(exportedLibraryElement.source.fullName)) {
      map[exportedLibraryElement.source.fullName] = new _ExportGraphNode(exportedLibraryElement);
    }
    final childNode = map[exportedLibraryElement.source.fullName];
    childNode.exportedBy.add(node);
    node.exports.add(childNode);
    _buildSubGraph(map, exportedLibraryElement);
  });
}

class ExportGraph {
  final Map<String, _ExportGraphNode> map = {};
  final Iterable<LibraryElement> packageLibraryElements;

  ExportGraph(this.packageLibraryElements) {
    packageLibraryElements.forEach((LibraryElement libraryElement) {
      _buildSubGraph(map, libraryElement);
    });
  }

  LibraryElement canonicalLibraryElement(LibraryElement libraryElement) {
    if (map.containsKey(libraryElement.source.fullName)) {
      final node = map[libraryElement.source.fullName];
      return node.canonicalLibraryElement(packageLibraryElements)?.libraryElement;
    } else {
      return libraryElement;
    }
  }
}
