// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:html';
import 'dart:js_util' as js_util;

void init() {
  final document = window.document;

  var searchBox = document.getElementById('search-box') as InputElement?;
  var searchBody = document.getElementById('search-body') as InputElement?;
  var searchSidebar =
      document.getElementById('search-sidebar') as InputElement?;

  void disableSearch() {
    print('Could not activate search functionality.');

    searchBox?.placeholder = 'Failed to initialize search';
    searchBody?.placeholder = 'Failed to initialize search';
    searchSidebar?.placeholder = 'Failed to initialize search';
  }

  var body = document.querySelector('body')!;

  // If dartdoc did not add a base-href tag, we will need to add the relative
  // path ourselves.
  var htmlBase = '';
  if (body.attributes['data-using-base-href'] == 'false') {
    // Dartdoc stores the htmlBase in 'body[data-base-href]'.
    htmlBase = body.attributes['data-base-href'] ?? '';
  }

  window.fetch('${htmlBase}index.json').then((response) async {
    int code = js_util.getProperty(response, 'status');
    if (code == 404) {
      disableSearch();
      return;
    }

    var textPromise = js_util.callMethod<Object>(response, 'text', []);
    var text = await promiseToFuture<String>(textPromise);
    var jsonIndex = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
    final index = jsonIndex.map(IndexItem.fromMap).toList();

    // Navigate to the first result from the 'search' query parameter
    // if specified and found.
    final url = Uri.parse(window.location.toString());
    final search = url.queryParameters['search'];
    if (search != null) {
      final matches = findMatches(index, search);
      if (matches.isNotEmpty) {
        final href = matches.first.href;
        if (href != null) {
          window.location.assign('$htmlBase$href');
          return;
        }
      }
    }

    // Initialize all three search fields.
    if (searchBox != null) {
      initializeSearch(searchBox, index, htmlBase);
    }
    if (searchBody != null) {
      initializeSearch(searchBody, index, htmlBase);
    }
    if (searchSidebar != null) {
      initializeSearch(searchSidebar, index, htmlBase);
    }
  });
}

const weights = {
  'library': 2,
  'class': 2,
  'mixin': 3,
  'extension': 3,
  'typedef': 3,
  'method': 4,
  'accessor': 4,
  'operator': 4,
  'constant': 4,
  'property': 4,
  'constructor': 4,
};

List<IndexItem> findMatches(List<IndexItem> index, String query) {
  if (query.isEmpty) {
    return [];
  }

  var allMatches = <SearchMatch>[];

  for (var element in index) {
    void score(int value) {
      value -= (element.overriddenDepth ?? 0) * 10;
      var weightFactor = weights[element.type] ?? 4;
      allMatches.add(SearchMatch(element, value / weightFactor));
    }

    var name = element.name;
    var qualifiedName = element.qualifiedName;
    var lowerName = name.toLowerCase();
    var lowerQualifiedName = qualifiedName.toLowerCase();
    var lowerQuery = query.toLowerCase();

    if (name == query || qualifiedName == query || name == 'dart:$query') {
      score(2000);
    } else if (lowerName == 'dart:$lowerQuery') {
      score(1800);
    } else if (lowerName == lowerQuery || lowerQualifiedName == lowerQuery) {
      score(1700);
    } else if (query.length > 1) {
      if (name.startsWith(query) || qualifiedName.startsWith(query)) {
        score(750);
      } else if (lowerName.startsWith(lowerQuery) ||
          lowerQualifiedName.startsWith(lowerQuery)) {
        score(650);
      } else if (name.contains(query) || qualifiedName.contains(query)) {
        score(500);
      } else if (lowerName.contains(lowerQuery) ||
          lowerQualifiedName.contains(query)) {
        score(400);
      }
    }
  }

  allMatches.sort((SearchMatch a, SearchMatch b) {
    var x = (b.score - a.score).round();
    if (x == 0) {
      return a.element.name.length - b.element.name.length;
    }
    return x;
  });

  return allMatches.map((match) => match.element).toList();
}

const minLength = 1;
const suggestionLimit = 10;

void initializeSearch(
  InputElement input,
  List<IndexItem> index,
  String htmlBase,
) {
  input.disabled = false;
  input.setAttribute('placeholder', 'Search API Docs');

  // Handle grabbing focus when the users types / outside of the input
  document.addEventListener('keypress', (Event event) {
    if (event is! KeyEvent) {
      return;
    }
    if (event.code == 'Slash' && document.activeElement is! InputElement) {
      event.preventDefault();
      input.focus();
    }
  });

  // Prepare elements
  var wrapper = document.createElement('div');
  wrapper.classes.add('tt-wrapper');
  input.replaceWith(wrapper);

  var inputHint = document.createElement('input') as InputElement;
  inputHint.setAttribute('type', 'text');
  inputHint.setAttribute('autocomplete', 'off');
  inputHint.setAttribute('readonly', 'true');
  inputHint.setAttribute('spellcheck', 'false');
  inputHint.setAttribute('tabindex', '-1');
  inputHint.classes
    ..add('typeahead')
    ..add('tt-hint');

  wrapper.append(inputHint);

  input.setAttribute('autocomplete', 'off');
  input.setAttribute('spellcheck', 'false');
  input.classes.add('tt-input');

  wrapper.append(input);

  var listBox = document.createElement('div');
  listBox.setAttribute('role', 'listbox');
  listBox.setAttribute('aria-expanded', 'false');
  listBox.style.display = 'none';
  listBox.classes.add('tt-menu');

  var presentation = document.createElement('div');
  presentation.classes.add('tt-elements');

  listBox.append(presentation);

  wrapper.append(listBox);

  // Set up various search functionality.
  String highlight(String text, String query) {
    final sanitizedText = const HtmlEscape().convert(query);
    return text.replaceAll(
        query, "<strong class='tt-highlight'>$sanitizedText</strong>");
  }

  Element createSuggestion(String query, IndexItem match) {
    var suggestion = document.createElement('div');
    suggestion.setAttribute('data-href', match.href ?? '');
    suggestion.classes.add('tt-suggestion');

    var suggestionTitle = document.createElement('span');
    suggestionTitle.classes.add('tt-suggestion-title');
    suggestionTitle.innerHtml =
        highlight('${match.name} ${match.type.toLowerCase()}', query);

    suggestion.append(suggestionTitle);

    if (match.enclosedBy != null) {
      var fromLib = document.createElement('div');
      fromLib.classes.add('search-from-lib');
      fromLib.innerHtml = 'from ${highlight(match.enclosedBy!.name, query)}';

      suggestion.append(fromLib);
    }

    suggestion.addEventListener('mousedown', (event) {
      event.preventDefault();
    });

    suggestion.addEventListener('click', (event) {
      if (match.href != null) {
        window.location.assign('$htmlBase${match.href}');
        event.preventDefault();
      }
    });

    return suggestion;
  }

  String? storedValue;
  var actualValue = '';
  String? hint;

  var suggestionElements = <Element>[];
  var suggestionsInfo = <IndexItem>[];
  int? selectedElement;

  void setHint(String? value) {
    hint = value;
    inputHint.value = value ?? '';
  }

  void showSuggestions() {
    if (presentation.hasChildNodes()) {
      listBox.style.display = 'block';
      listBox.setAttribute('aria-expanded', 'true');
    }
  }

  void hideSuggestions() {
    listBox.style.display = 'none';
    listBox.setAttribute('aria-expanded', 'false');
  }

  void updateSuggestions(String query, List<IndexItem> suggestions) {
    suggestionsInfo = [];
    suggestionElements = [];
    presentation.text = '';

    if (suggestions.length < minLength) {
      setHint(null);
      hideSuggestions();
      return;
    }

    for (final suggestion in suggestions) {
      var element = createSuggestion(query, suggestion);
      suggestionElements.add(element);
      presentation.append(element);
    }

    suggestionsInfo = suggestions;

    setHint(query + suggestions[0].name.substring(query.length));
    selectedElement = null;

    showSuggestions();
  }

  void handle(String? newValue, [bool forceUpdate = false]) {
    if (actualValue == newValue && !forceUpdate) {
      return;
    }

    if (newValue == null || newValue.isEmpty) {
      updateSuggestions('', []);
      return;
    }

    var suggestions = findMatches(index, newValue);
    if (suggestions.length > suggestionLimit) {
      suggestions = suggestions.sublist(0, suggestionLimit);
    }

    actualValue = newValue;

    updateSuggestions(newValue, suggestions);
  }

  // Hook up events
  input.addEventListener('focus', (Event event) {
    handle(input.value, true);
  });

  input.addEventListener('blur', (Event event) {
    selectedElement = null;
    if (storedValue != null) {
      input.value = storedValue;
      storedValue = null;
    }
    hideSuggestions();
    setHint(null);
  });

  input.addEventListener('input', (event) {
    handle(input.value);
  });

  input.addEventListener('keydown', (Event event) {
    if (suggestionElements.isEmpty) {
      return;
    }

    if (event is! KeyEvent) {
      return;
    }

    if (event.code == 'Enter') {
      var selectingElement = selectedElement ?? 0;
      var href = suggestionElements[selectingElement].dataset['href'];
      if (href != null) {
        window.location.assign('$htmlBase$href');
      }
      return;
    }

    if (event.code == 'Tab') {
      if (selectedElement == null) {
        // The user wants to fill the field with the hint
        if (hint != null) {
          input.value = hint;
          handle(hint);
          event.preventDefault();
        }
      } else {
        // The user wants to fill the input field with their currently selected suggestion
        handle(suggestionsInfo[selectedElement!].name);
        storedValue = null;
        selectedElement = null;
        event.preventDefault();
      }
      return;
    }

    var lastIndex = suggestionElements.length - 1;
    var previousSelectedElement = selectedElement;

    if (event.code == 'ArrowUp') {
      if (selectedElement == null) {
        selectedElement = lastIndex;
      } else if (selectedElement == 0) {
        selectedElement = null;
      } else {
        selectedElement = (selectedElement! - 1);
      }
    } else if (event.code == 'ArrowDown') {
      if (selectedElement == null) {
        selectedElement = 0;
      } else if (selectedElement == lastIndex) {
        selectedElement = null;
      } else {
        selectedElement = (selectedElement! + 1);
      }
    } else {
      if (storedValue != null) {
        storedValue = null;
        handle(input.value);
      }
      return;
    }

    if (previousSelectedElement != null) {
      suggestionElements[previousSelectedElement].classes.remove('tt-cursor');
    }

    if (selectedElement != null) {
      var selected = suggestionElements[selectedElement!];
      selected.classes.add('tt-cursor');

      // Guarantee the selected element is visible
      if (selectedElement == 0) {
        listBox.scrollTop = 0;
      } else if (selectedElement == lastIndex) {
        listBox.scrollTop = listBox.scrollHeight;
      } else {
        var offsetTop = selected.offsetTop;
        var parentOffsetHeight = listBox.offsetHeight;
        if (offsetTop < parentOffsetHeight ||
            parentOffsetHeight < (offsetTop + selected.offsetHeight)) {
          selected.scrollIntoView();
        }
      }

      // Store the actual input value to display their currently selected item.
      storedValue ??= input.value;
      input.value = suggestionsInfo[selectedElement!].name;
      setHint('');
    } else if (storedValue != null && previousSelectedElement != null) {
      // They are moving back to the input field, so return the stored value.
      input.value = storedValue;
      setHint(storedValue! +
          suggestionsInfo[0].name.substring(storedValue!.length));
      storedValue = null;
    }

    event.preventDefault();
  });
}

class SearchMatch {
  final IndexItem element;
  final double score;

  SearchMatch(this.element, this.score);
}

class IndexItem {
  final String name;
  final String qualifiedName;
  final String type;
  final String? href;
  final int? overriddenDepth;
  final EnclosedBy? enclosedBy;

  IndexItem._({
    required this.name,
    required this.qualifiedName,
    required this.type,
    this.href,
    this.overriddenDepth,
    this.enclosedBy,
  });

  // "name":"dartdoc",
  // "qualifiedName":"dartdoc",
  // "href":"dartdoc/dartdoc-library.html",
  // "type":"library",
  // "overriddenDepth":0,
  // "packageName":"dartdoc"
  // ["enclosedBy":{"name":"Accessor","type":"class"}]

  factory IndexItem.fromMap(Map<String, dynamic> data) {
    // Note that this map also contains 'packageName', but we're not currently
    // using that info.

    EnclosedBy? enclosedBy;
    if (data['enclosedBy'] != null) {
      final map = data['enclosedBy'] as Map<String, dynamic>;
      enclosedBy = EnclosedBy._(name: map['name'], type: map['type']);
    }

    return IndexItem._(
      name: data['name'],
      qualifiedName: data['qualifiedName'],
      href: data['href'],
      type: data['type'],
      overriddenDepth: data['overriddenDepth'],
      enclosedBy: enclosedBy,
    );
  }
}

class EnclosedBy {
  final String name;
  final String type;

  // ["enclosedBy":{"name":"Accessor","type":"class"}]
  EnclosedBy._({
    required this.name,
    required this.type,
  });
}
