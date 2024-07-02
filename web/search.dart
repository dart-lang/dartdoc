// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:js_interop';

import 'package:dartdoc/src/search.dart';
import 'package:web/web.dart';

final String _htmlBase = () {
  final body = document.body;
  if (body == null) return '';

  // If dartdoc did not add a base-href tag, we will need to add the relative
  // path ourselves.
  if (body.getAttribute('data-using-base-href') == 'false') {
    // Dartdoc stores the htmlBase in 'body[data-base-href]'.
    return body.getAttribute('data-base-href') ?? '';
  } else {
    return '';
  }
}();

void init() {
  var searchBox = document.getElementById('search-box') as HTMLInputElement?;
  var searchBody = document.getElementById('search-body') as HTMLInputElement?;
  var searchSidebar =
      document.getElementById('search-sidebar') as HTMLInputElement?;

  void disableSearch() {
    print('Could not activate search functionality.');

    searchBox?.placeholder = 'Failed to initialize search';
    searchBody?.placeholder = 'Failed to initialize search';
    searchSidebar?.placeholder = 'Failed to initialize search';
  }

  window
      .fetch('${_htmlBase}index.json'.toJS)
      .toDart
      .then((fetchResponse) async {
    if (fetchResponse.status != 200) {
      disableSearch();
      return;
    }

    final text = (await fetchResponse.text().toDart).toDart;
    final index = Index.fromJson(text);

    // Navigate to the first result from the 'search' query parameter
    // if specified and found.
    final url = Uri.parse(window.location.toString());
    final searchQuery = url.queryParameters['search'];
    if (searchQuery != null) {
      final matches = index.find(searchQuery);
      if (matches.isNotEmpty) {
        final href = matches.first.href;
        if (href != null) {
          window.location.assign('$_htmlBase$href');
          return;
        }
      }
    }

    // Initialize all three search fields.
    if (searchBox != null) {
      _Search(index).initialize(searchBox);
    }
    if (searchBody != null) {
      _Search(index).initialize(searchBody);
    }
    if (searchSidebar != null) {
      _Search(index).initialize(searchSidebar);
    }
  });
}

int _suggestionLimit = 10;
int _suggestionLength = 0;
const _htmlEscape = HtmlEscape();

/// A limited tree of element containers.
///
/// Each key is the inner HTML of a container suggestion element. Each value is
/// an element for the container, and which contains one or more child
/// suggestions, all of whom have the container as their parent. This is only
/// useful for the search results page.
final _containerMap = <String, Element>{};

class _Search {
  final Index index;
  final Uri uri;

  late final listBox = document.createElement('div') as HTMLElement
    ..setAttribute('role', 'listbox')
    ..setAttribute('aria-expanded', 'false')
    ..style.display = 'none'
    ..classList.add('tt-menu')
    ..appendChild(moreResults)
    ..appendChild(searchResults);

  /// Element used in [listBox] to inform the functionality of hitting enter in
  /// search box.
  late final moreResults = document.createElement('div')
    ..classList.add('enter-search-message');

  /// Element that contains the search suggestions in a new format.
  late final searchResults = document.createElement('div')
    ..classList.add('tt-search-results');

  String? storedValue;
  String actualValue = '';
  final List<HTMLElement> suggestionElements = <HTMLElement>[];
  List<IndexItem> suggestionsInfo = <IndexItem>[];
  int selectedElement = -1;

  _Search(this.index) : uri = Uri.parse(window.location.href);

  void initialize(HTMLInputElement inputElement) {
    inputElement.disabled = false;
    inputElement.setAttribute('placeholder', 'Search API Docs');
    // Handle grabbing focus when the user types '/' outside of the input.
    document.addEventListener(
      'keydown',
      (KeyboardEvent event) {
        if (event.key != '/') {
          return;
        }

        var activeElement = document.activeElement;
        if (activeElement == null || !activeElement.acceptsInput) {
          event.preventDefault();
          inputElement.focus();
        }
      }.toJS,
    );

    // Prepare elements.
    var wrapper = document.createElement('div')..classList.add('tt-wrapper');
    inputElement
      ..replaceWith(wrapper)
      ..setAttribute('autocomplete', 'off')
      ..setAttribute('spellcheck', 'false')
      ..classList.add('tt-input');

    wrapper
      ..appendChild(inputElement)
      ..appendChild(listBox);

    setEventListeners(inputElement);

    // Display the search results in the main body, if we're rendering the
    // search page.
    if (window.location.href.contains('search.html')) {
      var query = uri.queryParameters['q'];
      if (query == null) {
        return;
      }
      query = _htmlEscape.convert(query);
      _suggestionLimit = _suggestionLength;
      handleSearch(query, isSearchPage: true);
      showSearchResultPage(query);
      hideSuggestions();
      _suggestionLimit = 10;
    }
  }

  /// Displays the suggestions [searchResults] list box.
  void showSuggestions() {
    if (searchResults.hasChildNodes()) {
      listBox
        ..style.display = 'block'
        ..setAttribute('aria-expanded', 'true');
    }
  }

  /// Creates the content displayed in the main-content element, for the search
  /// results page.
  void showSearchResultPage(String searchText) {
    final mainContent = document.getElementById('dartdoc-main-content');

    if (mainContent == null) {
      return;
    }

    mainContent
      ..textContent = ''
      ..appendChild(
        document.createElement('section')..classList.add('search-summary'),
      )
      ..appendChild(
        document.createElement('h2')..innerHTML = 'Search Results',
      )
      ..appendChild(
        document.createElement('div')
          ..classList.add('search-summary')
          ..innerHTML = '$_suggestionLength results for "$searchText"',
      );

    if (_containerMap.isNotEmpty) {
      for (final element in _containerMap.values) {
        mainContent.appendChild(element);
      }
    } else {
      var noResults = document.createElement('div')
        ..classList.add('search-summary')
        ..innerHTML =
            'There was not a match for "$searchText". Want to try searching '
                'from additional Dart-related sites? ';

      var buildLink = Uri.parse(
              'https://dart.dev/search?cx=011220921317074318178%3A_yy-tmb5t_i&ie=UTF-8&hl=en&q=')
          .replace(queryParameters: {'q': searchText});
      var link = document.createElement('a')
        ..setAttribute('href', buildLink.toString())
        ..textContent = 'Search on dart.dev.';
      noResults.appendChild(link);
      mainContent.appendChild(noResults);
    }
  }

  void hideSuggestions() => listBox
    ..style.display = 'none'
    ..setAttribute('aria-expanded', 'false');

  void showEnterMessage() => moreResults.textContent = _suggestionLength > 10
      ? 'Press "Enter" key to see all $_suggestionLength results'
      : '';

  /// Updates the suggestions displayed below the search bar to [suggestions].
  ///
  /// [query] is only required here so that it can be displayed with emphasis
  /// (as a prefix, for example).
  void updateSuggestions(String query, List<IndexItem> suggestions,
      {bool isSearchPage = false}) {
    suggestionsInfo = [];
    suggestionElements.clear();
    _containerMap.clear();
    searchResults.textContent = '';

    if (suggestions.isEmpty) {
      hideSuggestions();
      return;
    }

    for (final suggestion in suggestions) {
      suggestionElements.add(_createSuggestion(query, suggestion));
    }

    var suggestionSource =
        isSearchPage ? _containerMap.values : suggestionElements;
    for (final element in suggestionSource) {
      searchResults.appendChild(element);
    }
    suggestionsInfo = suggestions;

    removeSelectedElement();

    showSuggestions();
    showEnterMessage();
  }

  /// Handles [searchText] by generating suggestions.
  void handleSearch(String? searchText,
      {bool forceUpdate = false, bool isSearchPage = false}) {
    if (actualValue == searchText && !forceUpdate) {
      return;
    }

    if (searchText == null || searchText.isEmpty) {
      updateSuggestions('', []);
      return;
    }

    var suggestions = index.find(searchText);
    _suggestionLength = suggestions.length;
    if (suggestions.length > _suggestionLimit) {
      suggestions = suggestions.sublist(0, _suggestionLimit);
    }

    actualValue = searchText;
    updateSuggestions(searchText, suggestions, isSearchPage: isSearchPage);
  }

  /// Clears the search box and suggestions.
  void clearSearch(HTMLInputElement inputElement) {
    removeSelectedElement();
    if (storedValue case var value?) {
      inputElement.value = value;
      storedValue = null;
    }
    hideSuggestions();
  }

  void setEventListeners(HTMLInputElement inputElement) {
    inputElement.addEventListener(
      'focus',
      (Event event) {
        handleSearch(inputElement.value, forceUpdate: true);
      }.toJS,
    );

    inputElement.addEventListener(
      'blur',
      (Event event) {
        clearSearch(inputElement);
      }.toJS,
    );

    inputElement.addEventListener(
      'input',
      (Event event) {
        handleSearch(inputElement.value);
      }.toJS,
    );

    inputElement.addEventListener(
      'keydown',
      (Event event) {
        if (event.type != 'keydown') {
          return;
        }

        event = event as KeyboardEvent;

        if (event.code == 'Enter') {
          event.preventDefault();
          if (!selectedElement.isBlurred) {
            if (suggestionElements[selectedElement].getAttribute('data-href')
                case var href?) {
              window.location.assign('$_htmlBase$href');
            }
            return;
          } else {
            // If there is no search suggestion selected, then change the
            // window location to `search.html`.
            var query = _htmlEscape.convert(actualValue);
            var searchPath = Uri.parse('${_htmlBase}search.html')
                .replace(queryParameters: {'q': query});
            window.location.assign(searchPath.toString());
            return;
          }
        }

        var lastIndex = suggestionElements.length - 1;
        var previousSelectedElement = selectedElement;

        if (event.code == 'ArrowUp') {
          if (selectedElement.isBlurred) {
            selectedElement = lastIndex;
          } else {
            selectedElement = selectedElement - 1;
          }
        } else if (event.code == 'ArrowDown') {
          if (selectedElement == lastIndex) {
            removeSelectedElement();
          } else {
            selectedElement = selectedElement + 1;
          }
        } else if (event.code == 'Escape') {
          clearSearch(inputElement);
        } else {
          if (storedValue != null) {
            storedValue = null;
            handleSearch(inputElement.value);
          }
          return;
        }

        if (!previousSelectedElement.isBlurred) {
          suggestionElements[previousSelectedElement]
              .classList
              .remove('tt-cursor');
        }

        if (!selectedElement.isBlurred) {
          var selected = suggestionElements[selectedElement];
          selected.classList.add('tt-cursor');

          // Guarantee the selected element is visible.
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

          // Store the actual input value to
          // display their currently selected item.
          storedValue ??= inputElement.value;
          inputElement.value = suggestionsInfo[selectedElement].name;
        } else if (storedValue case var value?
            when !previousSelectedElement.isBlurred) {
          // They are moving back to the input field,
          // so return the stored value.
          inputElement.value = value;
          storedValue = null;
        }

        event.preventDefault();
      }.toJS,
    );
  }

  /// Sets the selection index to `-1`.
  void removeSelectedElement() => selectedElement = -1;
}

HTMLElement _createSuggestion(String query, IndexItem match) {
  final suggestion = document.createElement('div') as HTMLElement
    ..setAttribute('data-href', match.href ?? '')
    ..classList.add('tt-suggestion');

  final suggestionTitle = document.createElement('span')
    ..classList.add('tt-suggestion-title')
    ..innerHTML = _highlight(
        '${match.name} ${match.kind.toString().toLowerCase()}', query);
  suggestion.appendChild(suggestionTitle);

  final enclosingElement = match.enclosedBy;
  if (enclosingElement != null) {
    suggestion.appendChild(document.createElement('span') as HTMLElement
      ..classList.add('tt-suggestion-container')
      ..innerHTML = '(in ${_highlight(enclosingElement.name, query)})');
  }

  // The one line description to use in the search suggestions.
  final matchDescription = match.desc;
  if (matchDescription != null && matchDescription.isNotEmpty) {
    final inputDescription = document.createElement('blockquote') as HTMLElement
      ..classList.add('one-line-description')
      ..setAttribute('title', _decodeHtml(matchDescription))
      ..innerHTML = _highlight(matchDescription, query);
    suggestion.appendChild(inputDescription);
  }

  suggestion.addEventListener(
    'mousedown',
    (Event event) {
      event.preventDefault();
    }.toJS,
  );

  suggestion.addEventListener(
    'click',
    (Event event) {
      if (match.href case var matchHref?) {
        window.location.assign('$_htmlBase$matchHref');
        event.preventDefault();
      }
    }.toJS,
  );

  if (enclosingElement != null) {
    _mapToContainer(
      _createContainer(
        '${enclosingElement.name} ${enclosingElement.kind}',
        enclosingElement.href,
      ),
      suggestion,
    );
  }
  return suggestion;
}

/// Maps a suggestion library/class [Element] to the other suggestions, if any.
void _mapToContainer(HTMLElement containerElement, HTMLElement suggestion) {
  final containerInnerHtml = containerElement.innerHTML;

  if (containerInnerHtml.isEmpty) {
    return;
  }

  final element = _containerMap[containerInnerHtml];
  if (element != null) {
    element.appendChild(suggestion);
  } else {
    containerElement.appendChild(suggestion);
    _containerMap[containerInnerHtml] = containerElement;
  }
}

/// Creates an `<a>` [Element] for the enclosing library/class.
HTMLElement _createContainer(String encloser, String href) =>
    document.createElement('div') as HTMLElement
      ..classList.add('tt-container')
      ..appendChild(document.createElement('p')
        ..textContent = 'Results from '
        ..classList.add('tt-container-text')
        ..appendChild(document.createElement('a')
          ..setAttribute('href', href)
          ..innerHTML = encloser));

/// Wraps each instance of [query] in [text] with a `<strong>` tag, as HTML
/// text.
String _highlight(String text, String query) => text.replaceAllMapped(
      RegExp(query, caseSensitive: false),
      (match) => "<strong class='tt-highlight'>${match[0]}</strong>",
    );

/// Decodes HTML entities (like `&lt;`) into their HTML elements (like `<`).
///
/// This is safe for use in an HTML attribute like `title`.
String _decodeHtml(String html) {
  return ((document.createElement('textarea') as HTMLTextAreaElement)
        ..innerHTML = html)
      .value;
}

extension on int {
  // TODO(srawlins): Re-implement in inline class someday.
  bool get isBlurred => this == -1;
}

extension on Element {
  bool get acceptsInput =>
      const {'input', 'textarea'}.contains(nodeName.toLowerCase());
}
