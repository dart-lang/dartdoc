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
  });

  test('defers index fetch until interaction and preserves focus and caret',
      () async {
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

    // Idle state does not fetch index.json.
    expect(fetchCount, 0);

    // Focusing starts one fetch, and typing while in flight preserves focus and
    // caret selection without triggering duplicate fetches.
    input.focus();
    input.dispatchEvent(FocusEvent('focus'));
    expect(fetchCount, 1);

    input.value = 'fetch';
    input.setSelectionRange(3, 3);
    input.dispatchEvent(Event('input'));
    expect(fetchCount, 1);
    expect(document.activeElement, equals(input));
    expect(input.selectionStart, 3);

    // Resolving index.json populates `.tt-menu` suggestions while keeping
    // focus, typed text, and caret position intact.
    indexCompleter.complete(_sampleIndexJson);
    await Future<void>.delayed(Duration.zero);

    expect(document.activeElement, equals(input));
    expect(input.value, 'fetch');
    expect(input.selectionStart, 3);

    var listBox =
        wrapper.querySelector('.tt-menu[role="listbox"]')! as HTMLElement;
    expect(listBox.style.display, 'block');
    expect(listBox.textContent, contains('fetchCount'));
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
    // and eagerly starts loading index.json.
    expect(rawInput.parentElement?.classList.contains('tt-wrapper'), isTrue);
    expect(document.activeElement, equals(rawInput));
    expect(rawInput.selectionStart, 2);

    var wrapper = rawInput.parentElement! as HTMLElement;
    indexCompleter.complete(_sampleIndexJson);
    await Future<void>.delayed(Duration.zero);

    var listBox =
        wrapper.querySelector('.tt-menu[role="listbox"]')! as HTMLElement;
    expect(listBox.style.display, 'block');
    expect(listBox.textContent, contains('Future'));
  });

  test('routes pre-load form submit to search.html?q=', () async {
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
    input.focus();
    input.dispatchEvent(FocusEvent('focus'));
    input.value = 'Future<int>';
    input.dispatchEvent(Event('input'));

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

    search.init(fetchIndexText: () async => _sampleIndexJson);
    await Future<void>.delayed(Duration.zero);
    expect(wrapper.querySelectorAll('.tt-menu[role="listbox"]').length, 1);
  });

  test('re-running init before load navigates once on form submit', () async {
    hostContainer.innerHtml = '''
<form class="search navbar-right" role="search">
  <div class="tt-wrapper">
    <input type="text" id="search-box" class="form-control typeahead tt-input" placeholder="Search API Docs">
  </div>
</form>
''';

    final navigatedUrls = <String>[];
    search.init(
      fetchIndexText: () => Completer<String?>().future,
      navigateTo: navigatedUrls.add,
    );
    search.init(
      fetchIndexText: () => Completer<String?>().future,
      navigateTo: navigatedUrls.add,
    );

    var input = document.getElementById('search-box')! as HTMLInputElement;
    input.value = 'Future';
    input.form!.dispatchEvent(
      SubmitEvent('submit', SubmitEventInit(cancelable: true)),
    );
    expect(navigatedUrls, ['search.html?q=Future']);
  });
}
