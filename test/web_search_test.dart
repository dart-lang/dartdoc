// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:async';
import 'dart:convert';

import 'package:dartdoc/src/model/kind.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

import '../web/search.dart' as search;

final String _sampleIndexJson = jsonEncode([
  {
    'name': 'fetchCount',
    'qualifiedName': 'a.fetchCount',
    'href': 'a/fetchCount.html',
    'kind': Kind.function.index,
    'overriddenDepth': 0,
    'packageRank': 0,
    'desc': 'Returns Future of int.',
    'enclosedBy': {'name': 'a', 'kind': Kind.library.index, 'href': 'a/'},
  },
  {
    'name': 'Future',
    'qualifiedName': 'dart:async.Future',
    'href': 'dart-async/Future-class.html',
    'kind': Kind.class_.index,
    'overriddenDepth': 0,
    'packageRank': 1,
    'desc': 'An asynchronous computation.',
    'enclosedBy': {
      'name': 'dart:async',
      'kind': Kind.library.index,
      'href': 'dart-async/',
    },
  },
]);

void main() {
  late HTMLElement hostContainer;

  setUp(() {
    hostContainer = HTMLDivElement();
    document.body!.appendChild(hostContainer);
  });

  tearDown(() {
    hostContainer.remove();
    document.getElementById('dartdoc-search-status')?.remove();
  });

  test('defers index fetch until interaction and shows in-flight UX', () async {
    hostContainer.innerHtml = '''
<header>
  <form class="search navbar-right" role="search">
    <div class="tt-wrapper">
      <input type="text" id="search-box" class="form-control typeahead tt-input" placeholder="Search API Docs">
    </div>
  </form>
</header>
''';

    var fetchCount = 0;
    var indexCompleter = Completer<String?>();
    search.init(
      fetchIndexText: () {
        fetchCount++;
        return indexCompleter.future;
      },
    );

    var input = document.getElementById('search-box')! as HTMLInputElement;
    var wrapper = input.parentElement! as HTMLElement;
    var statusPanel =
        wrapper.querySelector('.tt-search-status')! as HTMLElement;
    var liveRegion =
        document.getElementById('dartdoc-search-status')! as HTMLElement;

    // Idle state does not fetch index.json or mark inputs busy.
    expect(fetchCount, 0);
    expect(input.hasAttribute('aria-busy'), isFalse);
    expect(wrapper.classList.contains('is-loading'), isFalse);
    expect(statusPanel.style.display, 'none');
    expect(liveRegion.getAttribute('role'), 'status');
    expect(liveRegion.getAttribute('aria-live'), 'polite');

    // Focusing starts one fetch and activates in-input spinner without opening
    // the dropdown status panel while the query is still empty.
    input.focus();
    input.dispatchEvent(FocusEvent('focus'));
    expect(fetchCount, 1);
    expect(input.getAttribute('aria-busy'), 'true');
    expect(wrapper.classList.contains('is-loading'), isTrue);
    expect(statusPanel.style.display, 'none');

    // Typing while index.json is in flight preserves focus/caret and displays
    // the status message directly below the input.
    input.value = 'fetch';
    input.setSelectionRange(3, 3);
    input.dispatchEvent(Event('input'));
    expect(fetchCount, 1);
    expect(document.activeElement, equals(input));
    expect(input.selectionStart, 3);
    expect(statusPanel.style.display, 'block');
    expect(statusPanel.textContent, contains('Loading search index'));

    // Resolving index.json clears loading state and populates `.tt-menu`
    // suggestions without losing input focus or caret position.
    indexCompleter.complete(_sampleIndexJson);
    await Future<void>.delayed(Duration.zero);

    expect(input.hasAttribute('aria-busy'), isFalse);
    expect(wrapper.classList.contains('is-loading'), isFalse);
    expect(statusPanel.style.display, 'none');
    expect(document.activeElement, equals(input));
    expect(input.value, 'fetch');
    expect(input.selectionStart, 3);

    var listBox =
        wrapper.querySelector('.tt-menu[role="listbox"]')! as HTMLElement;
    expect(listBox.style.display, 'block');
    expect(listBox.textContent, contains('fetchCount'));
    expect(liveRegion.textContent, '1 search result available.');
  });

  test('degrades cleanly on pub.dev markup without .tt-wrapper', () async {
    hostContainer.innerHtml = '''
<form class="search navbar-right" role="search">
  <input id="search-box" class="form-control typeahead" type="text" placeholder="Loading search..." autocomplete="off">
</form>
''';

    var rawInput = document.getElementById('search-box')! as HTMLInputElement;
    rawInput
      ..focus()
      ..value = 'Fut'
      ..setSelectionRange(2, 2);

    var indexCompleter = Completer<String?>();
    search.init(fetchIndexText: () => indexCompleter.future);

    // Pre-focused non-empty bare input is wrapped without losing focus/caret
    // and immediately enters in-flight loading state.
    expect(rawInput.parentElement?.classList.contains('tt-wrapper'), isTrue);
    expect(rawInput.getAttribute('aria-label'), 'Search API Docs');
    expect(document.activeElement, equals(rawInput));
    expect(rawInput.selectionStart, 2);
    expect(rawInput.getAttribute('aria-busy'), 'true');

    var wrapper = rawInput.parentElement! as HTMLElement;
    var statusPanel =
        wrapper.querySelector('.tt-search-status')! as HTMLElement;
    expect(statusPanel.style.display, 'block');

    indexCompleter.complete(_sampleIndexJson);
    await Future<void>.delayed(Duration.zero);

    var listBox =
        wrapper.querySelector('.tt-menu[role="listbox"]')! as HTMLElement;
    expect(listBox.style.display, 'block');
    expect(listBox.textContent, contains('Future'));
  });

  test('surfaces transient load failure even with typed text and retries',
      () async {
    hostContainer.innerHtml = '''
<form class="search navbar-right" role="search">
  <div class="tt-wrapper">
    <input type="text" id="search-box" class="form-control typeahead tt-input" placeholder="Search API Docs">
  </div>
</form>
''';

    var attempts = 0;
    var firstAttempt = Completer<String?>();
    var secondAttempt = Completer<String?>();
    search.init(
      fetchIndexText: () {
        attempts++;
        return attempts == 1 ? firstAttempt.future : secondAttempt.future;
      },
    );

    var input = document.getElementById('search-box')! as HTMLInputElement;
    var wrapper = input.parentElement! as HTMLElement;
    var statusPanel =
        wrapper.querySelector('.tt-search-status')! as HTMLElement;

    input.focus();
    input.dispatchEvent(FocusEvent('focus'));
    input.value = 'fetch';
    input.dispatchEvent(Event('input'));

    // Fail the first attempt (offline / 500).
    firstAttempt.complete(null);
    await Future<void>.delayed(Duration.zero);

    expect(input.hasAttribute('aria-busy'), isFalse);
    expect(wrapper.classList.contains('is-loading'), isFalse);
    expect(statusPanel.style.display, 'block');
    expect(statusPanel.classList.contains('is-error'), isTrue);
    expect(statusPanel.textContent, contains('Failed to load search index'));

    // Typing again retries fetching index.json and recovers cleanly.
    input.value = 'fetchC';
    input.dispatchEvent(Event('input'));
    expect(attempts, 2);
    expect(wrapper.classList.contains('is-loading'), isTrue);
    expect(statusPanel.classList.contains('is-error'), isFalse);

    secondAttempt.complete(_sampleIndexJson);
    await Future<void>.delayed(Duration.zero);

    expect(statusPanel.style.display, 'none');
    var listBox =
        wrapper.querySelector('.tt-menu[role="listbox"]')! as HTMLElement;
    expect(listBox.style.display, 'block');
    expect(listBox.textContent, contains('fetchCount'));
  });

  test('routes pre-load form submit to search.html?q= and handles Escape',
      () async {
    hostContainer.innerHtml = '''
<form class="search navbar-right" role="search">
  <div class="tt-wrapper">
    <input type="text" id="search-box" class="form-control typeahead tt-input" placeholder="Search API Docs">
  </div>
</form>
''';

    final navigatedUrls = <String>[];
    final neverCompletes = Completer<String?>();
    search.init(
      fetchIndexText: () => neverCompletes.future,
      navigateTo: navigatedUrls.add,
    );

    var input = document.getElementById('search-box')! as HTMLInputElement;
    var wrapper = input.parentElement! as HTMLElement;
    var statusPanel =
        wrapper.querySelector('.tt-search-status')! as HTMLElement;

    input.focus();
    input.dispatchEvent(FocusEvent('focus'));
    input.value = 'Future<int>';
    input.dispatchEvent(Event('input'));
    expect(statusPanel.style.display, 'block');

    // Escape dismisses the in-flight status dropdown without dropping focus.
    input.dispatchEvent(
      KeyboardEvent('keydown', KeyboardEventInit(code: 'Escape')),
    );
    expect(statusPanel.style.display, 'none');

    // Submitting the form before index.json finishes navigates to search.html.
    input.form!.dispatchEvent(
      SubmitEvent('submit', SubmitEventInit(cancelable: true)),
    );
    expect(navigatedUrls, ['search.html?q=Future%3Cint%3E']);
  });

  test('re-running init does not append duplicate listbox menus', () async {
    hostContainer.innerHtml = '''
<form class="search navbar-right" role="search">
  <div class="tt-wrapper">
    <input type="text" id="search-box" class="form-control typeahead tt-input" placeholder="Search API Docs">
  </div>
</form>
''';

    var input = document.getElementById('search-box')! as HTMLInputElement;
    var wrapper = input.parentElement! as HTMLElement;

    search.init(fetchIndexText: () async => _sampleIndexJson);
    input.focus();
    input.dispatchEvent(FocusEvent('focus'));
    await Future<void>.delayed(Duration.zero);
    expect(wrapper.querySelectorAll('.tt-menu[role="listbox"]').length, 1);

    // Re-initializing against an already-hydrated input replaces the prior
    // listbox instead of stacking duplicate menus.
    search.init(fetchIndexText: () async => _sampleIndexJson);
    await Future<void>.delayed(Duration.zero);
    expect(wrapper.querySelectorAll('.tt-menu[role="listbox"]').length, 1);
  });
}
