// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:dartdoc/src/search.dart';
import 'package:meta/meta.dart';
import 'package:web/web.dart';

const _searchPlaceholder = 'Search API Docs';
const _loadingStatusMessage = 'Loading search index\u2026';
const _failedStatusMessage =
    'Failed to load search index. Type or refocus to retry.';
const _failedPlaceholder = 'Failed to initialize search';

String get _htmlBase {
  final body = document.body;
  if (body == null) return '';

  // If dartdoc did not add a base-href tag, we will need to add the relative
  // path ourselves.
  if (body.getAttribute('data-using-base-href') == 'false') {
    // Dartdoc stores the htmlBase in 'body[data-base-href]'.
    return body.getAttribute('data-base-href') ?? '';
  }
  return '';
}

enum _LoadState { idle, loading, failed, loaded }

_LazySearchLoader? _activeLoader;
Timer? _liveAnnouncementDebounce;

/// Initializes lazy search index loading and UI bindings on search inputs.
///
/// [fetchIndexText] and [navigateTo] may be overridden in browser tests.
void init({
  @visibleForTesting Future<String?> Function()? fetchIndexText,
  @visibleForTesting void Function(String url)? navigateTo,
}) {
  _activeLoader?.dispose();
  _activeLoader = null;
  _liveAnnouncementDebounce?.cancel();
  _liveAnnouncementDebounce = null;

  var searchBox = document.getElementById('search-box') as HTMLInputElement?;
  var searchBody = document.getElementById('search-body') as HTMLInputElement?;
  var searchSidebar =
      document.getElementById('search-sidebar') as HTMLInputElement?;
  var inputs = [searchBox, searchBody, searchSidebar].nonNulls.toList();
  var slashCandidates =
      [searchBox, searchSidebar, searchBody].nonNulls.toList();

  if (inputs.isEmpty &&
      !_shouldLoadIndexEagerly(Uri.parse(window.location.toString()), inputs)) {
    return;
  }

  _ensureLiveStatusElement();
  _activeLoader = _LazySearchLoader(
    inputs: inputs,
    slashCandidates: slashCandidates,
    fetchIndexText: fetchIndexText ?? _defaultFetchIndexText,
    navigateTo: navigateTo ?? _defaultNavigateTo,
  )..bind();
}

void _defaultNavigateTo(String url) {
  window.location.assign(url);
}

Future<String?> _defaultFetchIndexText() async {
  try {
    var response = await window.fetch('${_htmlBase}index.json'.toJS).toDart;
    if (response.status != HttpStatus.ok) {
      return null;
    }
    return (await response.text().toDart).toDart;
  } catch (_) {
    return null;
  }
}

HTMLElement? _ensureLiveStatusElement() {
  final body = document.body;
  if (body == null) return null;
  if (document.getElementById('dartdoc-search-status')
      case HTMLElement existing) {
    existing.textContent = '';
    return existing;
  }
  final status = HTMLDivElement()
    ..id = 'dartdoc-search-status'
    ..setAttribute('role', 'status')
    ..setAttribute('aria-live', 'polite')
    ..setAttribute('aria-atomic', 'true');
  status.style
    ..position = 'absolute'
    ..width = '1px'
    ..height = '1px'
    ..padding = '0'
    ..margin = '-1px'
    ..overflow = 'hidden'
    ..setProperty('clip', 'rect(0, 0, 0, 0)')
    ..setProperty('clip-path', 'inset(50%)')
    ..whiteSpace = 'nowrap'
    ..border = '0';
  body.appendChild(status);
  return status;
}

void _announcePolite(String message) {
  _liveAnnouncementDebounce?.cancel();
  _liveAnnouncementDebounce = null;
  if (document.getElementById('dartdoc-search-status')
      case HTMLElement status) {
    status.textContent = message;
  }
}

void _announcePoliteDebounced(String message) {
  _liveAnnouncementDebounce?.cancel();
  _liveAnnouncementDebounce = Timer(const Duration(milliseconds: 400), () {
    _liveAnnouncementDebounce = null;
    if (document.getElementById('dartdoc-search-status')
        case HTMLElement status) {
      status.textContent = message;
    }
  });
}

String _resultsAnnouncementText(int totalCount) => switch (totalCount) {
      0 => 'No search results.',
      1 => '1 search result available.',
      _ => '$totalCount search results available.',
    };

bool _isSearchPageWithQuery(Uri url) =>
    url.path.endsWith('search.html') && url.queryParameters.containsKey('q');

bool _shouldLoadIndexEagerly(Uri url, List<HTMLInputElement> inputs) {
  if (url.queryParameters.containsKey('search')) return true;
  if (_isSearchPageWithQuery(url)) return true;
  return inputs.any(
    (input) => document.activeElement == input || input.value.isNotEmpty,
  );
}

HTMLInputElement? _selectSlashTarget(List<HTMLInputElement> candidates) {
  for (var input in candidates) {
    if (input.offsetParent != null) return input;
  }
  return candidates.firstOrNull;
}

final class _InputHost {
  final HTMLInputElement input;
  final HTMLElement wrapper;
  final HTMLDivElement statusElement;

  _InputHost({
    required this.input,
    required this.wrapper,
    required this.statusElement,
  });

  factory _InputHost.prepare(HTMLInputElement input) {
    input
      ..disabled = false
      ..placeholder = _searchPlaceholder
      ..setAttribute('autocomplete', 'off')
      ..setAttribute('spellcheck', 'false')
      ..classList.add('tt-input');
    if (!input.hasAttribute('aria-label') &&
        !input.hasAttribute('aria-labelledby')) {
      input.setAttribute('aria-label', _searchPlaceholder);
    }

    final wrapper = _ensureWrapper(input);
    _ensureChildElement(
      wrapper,
      selector: '.tt-search-spinner',
      create: () => HTMLSpanElement()
        ..classList.add('tt-search-spinner')
        ..setAttribute('aria-hidden', 'true'),
    );
    final statusElement = _ensureChildElement(
      wrapper,
      selector: '.tt-search-status',
      create: () => HTMLDivElement()
        ..classList.add('tt-menu')
        ..classList.add('tt-search-status')
        ..setAttribute('aria-hidden', 'true')
        ..style.display = 'none',
    ) as HTMLDivElement;

    return _InputHost(
      input: input,
      wrapper: wrapper,
      statusElement: statusElement,
    );
  }
}

HTMLElement _ensureWrapper(HTMLInputElement input) {
  if (input.parentElement case HTMLElement parent
      when parent.classList.contains('tt-wrapper')) {
    return parent;
  }
  var wasFocused = document.activeElement == input;
  var selectionStart = input.selectionStart;
  var selectionEnd = input.selectionEnd;
  var wrapper = HTMLDivElement()..classList.add('tt-wrapper');
  input.replaceWith(wrapper);
  wrapper.appendChild(input);
  if (wasFocused) {
    input.focus();
    if (selectionStart != null && selectionEnd != null) {
      input.setSelectionRange(selectionStart, selectionEnd);
    }
  }
  return wrapper;
}

HTMLElement _ensureChildElement(
  HTMLElement parent, {
  required String selector,
  required HTMLElement Function() create,
}) {
  if (parent.querySelector(selector) case HTMLElement existing) {
    return existing;
  }
  final created = create();
  parent.appendChild(created);
  return created;
}

final class _LazySearchLoader {
  final List<HTMLInputElement> inputs;
  final List<HTMLInputElement> slashCandidates;
  final Future<String?> Function() fetchIndexText;
  final void Function(String url) navigateTo;
  late final List<_InputHost> hosts = [
    for (final input in inputs) _InputHost.prepare(input),
  ];

  _LoadState _state = _LoadState.idle;
  Future<void>? _inFlightLoad;
  bool _isDisposed = false;
  final _removeListeners = <void Function()>[];

  _LazySearchLoader({
    required this.inputs,
    required this.slashCandidates,
    required this.fetchIndexText,
    required this.navigateTo,
  });

  /// Adds [listener] to [target] and records it for removal in [dispose].
  void _listen(EventTarget target, String type, JSFunction listener) {
    target.addEventListener(type, listener);
    _removeListeners.add(() => target.removeEventListener(type, listener));
  }

  /// Removes every listener this loader added and abandons any load in flight,
  /// so that a later call to [init] starts from a clean page.
  void dispose() {
    _isDisposed = true;
    for (final removeListener in _removeListeners) {
      removeListener();
    }
    _removeListeners.clear();
  }

  void bind() {
    if (slashCandidates.isNotEmpty) {
      _listen(document, 'keydown', _handleSlashKeydown.toJS);
    }

    for (final host in hosts) {
      _attachPreLoadListeners(host);
    }

    if (_shouldLoadIndexEagerly(
      Uri.parse(window.location.toString()),
      inputs,
    )) {
      _ensureLoaded();
    }
  }

  void _attachPreLoadListeners(_InputHost host) {
    final input = host.input;
    if (input.form case var form?) {
      _listen(
        form,
        'submit',
        (Event event) {
          event.preventDefault();
          if (_state != _LoadState.loaded) {
            var q = input.value;
            navigateTo(
              '${_htmlBase}search.html?q=${Uri.encodeQueryComponent(q)}',
            );
          }
        }.toJS,
      );
    }
    _listen(
      input,
      'focus',
      (Event _) {
        _onInputInteraction();
      }.toJS,
    );
    _listen(
      input,
      'input',
      (Event _) {
        _onInputInteraction();
      }.toJS,
    );
    _listen(
      input,
      'blur',
      (Event _) {
        if (_state != _LoadState.loaded) {
          _syncUi();
        }
      }.toJS,
    );
    _listen(
      input,
      'keydown',
      (Event event) {
        if (_state != _LoadState.loaded &&
            event.type == 'keydown' &&
            (event as KeyboardEvent).code == 'Escape') {
          host.statusElement.style.display = 'none';
        }
      }.toJS,
    );
  }

  void _onInputInteraction() {
    if (_state == _LoadState.idle || _state == _LoadState.failed) {
      _ensureLoaded();
    } else if (_state == _LoadState.loading) {
      _syncUi();
    }
  }

  void _handleSlashKeydown(KeyboardEvent event) {
    if (event.key != '/') return;
    var activeElement = document.activeElement;
    if (activeElement != null && activeElement.acceptsInput) return;

    event.preventDefault();
    _selectSlashTarget(slashCandidates)?.focus();
    if (_state == _LoadState.idle || _state == _LoadState.failed) {
      _ensureLoaded();
    }
  }

  void _ensureLoaded() {
    if (_state == _LoadState.loaded) return;
    _inFlightLoad ??= _load();
  }

  Future<void> _load() async {
    _state = _LoadState.loading;
    _syncUi();
    final initialUrl = Uri.parse(window.location.toString());
    if (_isSearchPageWithQuery(initialUrl)) {
      _renderSearchPageStatus(_loadingStatusMessage);
    }

    var announcedLoading = false;
    final loadingTimer = Timer(const Duration(milliseconds: 150), () {
      if (_state == _LoadState.loading && !_isDisposed) {
        announcedLoading = true;
        _announcePolite(_loadingStatusMessage);
      }
    });

    Index? parsedIndex;
    try {
      final jsonText = await fetchIndexText();
      if (jsonText != null) {
        parsedIndex = Index.fromJson(jsonText);
      }
    } catch (_) {
      parsedIndex = null;
    } finally {
      loadingTimer.cancel();
      _inFlightLoad = null;
    }

    // A later call to `init` replaced this loader while the fetch was in
    // flight.
    if (_isDisposed) return;

    if (parsedIndex == null) {
      _handleLoadFailure(initialUrl);
      return;
    }

    _handleLoadSuccess(parsedIndex, announcedLoading: announcedLoading);
  }

  void _handleLoadFailure(Uri initialUrl) {
    print('Could not activate search functionality.');
    _state = _LoadState.failed;
    _syncUi();
    if (_isSearchPageWithQuery(initialUrl)) {
      _renderSearchPageStatus('Failed to load search index.');
    }
    _announcePolite('Failed to load search index.');
  }

  void _handleLoadSuccess(Index index, {required bool announcedLoading}) {
    _state = _LoadState.loaded;
    _syncUi();

    final url = Uri.parse(window.location.toString());
    if (url.queryParameters['search'] case var searchQuery?) {
      final href = index.find(searchQuery).firstOrNull?.href;
      if (href != null) {
        navigateTo('$_htmlBase$href');
        return;
      }
    }

    for (final host in hosts) {
      _Search(index, navigateTo: navigateTo).initialize(host.input);
    }

    final hasActiveQuery = _isSearchPageWithQuery(url) ||
        hosts.any(
          (h) => document.activeElement == h.input && h.input.value.isNotEmpty,
        );
    if (hasActiveQuery) {
      _announcePolite(_resultsAnnouncementText(_suggestionLength));
    } else if (announcedLoading) {
      _announcePolite('Search index ready.');
    }
  }

  void _syncUi() {
    switch (_state) {
      case _LoadState.idle:
        return;
      case _LoadState.loading:
        _syncLoadingUi();
      case _LoadState.failed:
        _syncFailedUi();
      case _LoadState.loaded:
        _syncLoadedUi();
    }
  }

  void _syncLoadingUi() {
    final primaryInput =
        _selectSlashTarget(slashCandidates) ?? inputs.firstOrNull;
    final anyActive = hosts.any(
      (h) => document.activeElement == h.input || h.input.value.isNotEmpty,
    );
    for (final host in hosts) {
      final isFocused = document.activeElement == host.input;
      final showSpinner = anyActive
          ? (isFocused || host.input.value.isNotEmpty)
          : host.input == primaryInput;
      host.input
        ..setAttribute('aria-busy', 'true')
        ..placeholder = _searchPlaceholder;
      host.wrapper.classList.toggle('is-loading', showSpinner);
      if (isFocused && host.input.value.trim().isNotEmpty) {
        host.statusElement
          ..textContent = _loadingStatusMessage
          ..classList.remove('is-error')
          ..style.display = 'block';
      } else {
        host.statusElement.style.display = 'none';
      }
    }
  }

  void _syncFailedUi() {
    for (final host in hosts) {
      host.input
        ..removeAttribute('aria-busy')
        ..placeholder = _failedPlaceholder;
      host.wrapper.classList.remove('is-loading');
      if (document.activeElement == host.input) {
        host.statusElement
          ..textContent = _failedStatusMessage
          ..classList.add('is-error')
          ..style.display = 'block';
      } else {
        host.statusElement.style.display = 'none';
      }
    }
  }

  void _syncLoadedUi() {
    for (final host in hosts) {
      host.input
        ..removeAttribute('aria-busy')
        ..placeholder = _searchPlaceholder;
      host.wrapper.classList.remove('is-loading');
      host.statusElement
        ..textContent = ''
        ..classList.remove('is-error')
        ..style.display = 'none';
    }
  }

  void _renderSearchPageStatus(String message) {
    final mainContent = document.getElementById('dartdoc-main-content');
    if (mainContent == null) return;
    mainContent
      ..textContent = ''
      ..appendChild(HTMLElement.section()..classList.add('search-summary'))
      ..appendChild(HTMLHeadingElement.h2()..textContent = 'Search Results')
      ..appendChild(
        HTMLDivElement()
          ..classList.add('search-summary')
          ..textContent = message,
      );
  }
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
  final void Function(String url) navigateTo;

  late final listBox = HTMLDivElement()
    ..setAttribute('role', 'listbox')
    ..setAttribute('aria-expanded', 'false')
    ..style.display = 'none'
    ..classList.add('tt-menu')
    ..appendChild(moreResults)
    ..appendChild(searchResults);

  /// Element used in [listBox] to inform the functionality of hitting enter in
  /// search box.
  late final moreResults = HTMLDivElement()
    ..classList.add('enter-search-message');

  /// Element that contains the search suggestions in a new format.
  late final searchResults = HTMLDivElement()
    ..classList.add('tt-search-results');

  String? storedValue;
  String actualValue = '';
  final List<HTMLElement> suggestionElements = <HTMLElement>[];
  List<IndexItem> suggestionsInfo = <IndexItem>[];
  int selectedElement = -1;

  _Search(this.index, {required this.navigateTo})
      : uri = Uri.parse(window.location.href);

  void initialize(HTMLInputElement inputElement) {
    inputElement
      ..disabled = false
      ..setAttribute('placeholder', _searchPlaceholder)
      ..setAttribute('autocomplete', 'off')
      ..setAttribute('spellcheck', 'false')
      ..classList.add('tt-input');

    // Reuse an existing `.tt-wrapper` so focused inputs are not detached.
    final wrapper = _ensureWrapper(inputElement);
    wrapper.querySelector('.tt-menu[role="listbox"]')?.remove();
    wrapper.appendChild(listBox);

    setEventListeners(inputElement);

    // Display the search results in the main body, if we're rendering the
    // search page.
    var isSearchPage = false;
    if (_isSearchPageWithQuery(uri)) {
      var query = uri.queryParameters['q'];
      if (query != null) {
        isSearchPage = true;
        query = _htmlEscape.convert(query);
        _suggestionLimit = _suggestionLength;
        handleSearch(query, isSearchPage: true);
        showSearchResultPage(query);
        hideSuggestions();
        _suggestionLimit = 10;
      }
    }

    if (!isSearchPage &&
        inputElement.value.isNotEmpty &&
        document.activeElement == inputElement) {
      handleSearch(inputElement.value, forceUpdate: true);
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
        HTMLElement.section()..classList.add('search-summary'),
      )
      ..appendChild(
        HTMLHeadingElement.h2()..innerHtml = 'Search Results',
      )
      ..appendChild(
        HTMLDivElement()
          ..classList.add('search-summary')
          ..innerHtml = '$_suggestionLength results for "$searchText"',
      );

    if (_containerMap.isNotEmpty) {
      for (final element in _containerMap.values) {
        mainContent.appendChild(element);
      }
    } else {
      var noResults = HTMLDivElement()
        ..classList.add('search-summary')
        ..innerHtml =
            'There was not a match for "$searchText". Want to try searching '
                'from additional Dart-related sites? ';

      var buildLink = Uri.parse(
              'https://dart.dev/search?cx=011220921317074318178%3A_yy-tmb5t_i&ie=UTF-8&hl=en&q=')
          .replace(queryParameters: {'q': searchText});
      var link = HTMLAnchorElement()
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
      suggestionElements.add(
        _createSuggestion(query, suggestion, navigateTo: navigateTo),
      );
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
      actualValue = '';
      _suggestionLength = 0;
      updateSuggestions('', []);
      if (!isSearchPage && !forceUpdate) {
        _announcePolite('');
      }
      return;
    }

    var suggestions = index.find(searchText);
    _suggestionLength = suggestions.length;
    if (suggestions.length > _suggestionLimit) {
      suggestions = suggestions.sublist(0, _suggestionLimit);
    }

    actualValue = searchText;
    updateSuggestions(searchText, suggestions, isSearchPage: isSearchPage);
    if (!isSearchPage && !forceUpdate) {
      _announcePoliteDebounced(_resultsAnnouncementText(_suggestionLength));
    }
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
              navigateTo('$_htmlBase$href');
            }
            return;
          } else {
            // If there is no search suggestion selected, then change the
            // window location to `search.html`.
            var query = _htmlEscape.convert(actualValue);
            var searchPath = Uri.parse('${_htmlBase}search.html')
                .replace(queryParameters: {'q': query});
            navigateTo(searchPath.toString());
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

HTMLElement _createSuggestion(
  String query,
  IndexItem match, {
  required void Function(String url) navigateTo,
}) {
  final suggestion = HTMLDivElement()
    ..setAttribute('data-href', match.href ?? '')
    ..classList.add('tt-suggestion');

  final suggestionTitle = HTMLSpanElement()
    ..classList.add('tt-suggestion-title')
    ..innerHtml = _highlight(
        '${match.name} ${match.kind.toString().toLowerCase()}', query);
  suggestion.appendChild(suggestionTitle);

  final enclosingElement = match.enclosedBy;
  if (enclosingElement != null) {
    suggestion.appendChild(HTMLSpanElement()
      ..classList.add('tt-suggestion-container')
      ..innerHtml = '(in ${_highlight(enclosingElement.name, query)})');
  }

  // The one line description to use in the search suggestions.
  final matchDescription = match.desc;
  if (matchDescription != null && matchDescription.isNotEmpty) {
    final inputDescription = HTMLQuoteElement.blockquote()
      ..classList.add('one-line-description')
      ..setAttribute('title', _decodeHtml(matchDescription))
      ..innerHtml = _highlight(matchDescription, query);
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
        navigateTo('$_htmlBase$matchHref');
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
  final containerInnerHtml = containerElement.innerHtml;

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
HTMLElement _createContainer(String encloser, String href) => HTMLDivElement()
  ..classList.add('tt-container')
  ..appendChild(HTMLParagraphElement()
    ..textContent = 'Results from '
    ..classList.add('tt-container-text')
    ..appendChild(HTMLAnchorElement()
      ..setAttribute('href', href)
      ..innerHtml = encloser));

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
  return (HTMLTextAreaElement()..innerHtml = html).value;
}

extension on int {
  // TODO(srawlins): Re-implement in inline class someday.
  bool get isBlurred => this == -1;
}

extension ElementExtension on Element {
  bool get acceptsInput =>
      const {'input', 'textarea'}.contains(nodeName.toLowerCase());

  // The default implementation allows `JSAny` to support trusted types. We only
  // use `String`s, so prefer this to avoid manual conversions.
  @JS('innerHTML')
  external String innerHtml;
}
