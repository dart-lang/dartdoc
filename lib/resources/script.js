// Adds a shadow for the top nav when the masthead is scrolled off the top.
function initScroller() {
  var header = document.querySelector("header");
  var title = document.querySelector(".title-description");
  var selfName = document.querySelector('nav .self-name');

  window.addEventListener('scroll', function(e) {
    var position = window.pageYOffset || document.documentElement.scrollTop;

    if (header) {
      if (position >= 110) { // TODO: where did this num come from?
        header.classList.add("header-fixed");
      } else if (header.classList.contains("header-fixed")) {
        header.classList.remove("header-fixed");
      }
    }

    if (selfName) {
      if (position >= 80) { // TODO: is this too brittle ?
        selfName.classList.add('visible-xs-inline');
      } else {
        selfName.classList.remove('visible-xs-inline');
      }
    }
  });
}

function initSideNav() {
  var leftNavToggle = document.getElementById('sidenav-left-toggle');
  var leftDrawer = document.querySelector('.sidebar-offcanvas-left');
  var overlay = document.getElementById('overlay-under-drawer');

  function toggleBoth() {
    if (leftDrawer) {
      leftDrawer.classList.toggle('active');
    }

    if (overlay) {
      overlay.classList.toggle('active');
    }
  }

  if (overlay) {
    overlay.addEventListener('click', function(e) {
      toggleBoth();
    });
  }

  if (leftNavToggle) {
    leftNavToggle.addEventListener('click', function(e) {
      toggleBoth();
    });
  }
}

// Make sure the anchors scroll past the fixed page header (#648).
function shiftWindow() {
  scrollBy(0, -68);
}

function initSearch() {
  var index;

  function findMatches(q, cb) {
    var matches, substringRegex;

    // an array that will be populated with substring matches
    matches = [];

    // regex used to determine if a string contains the substring `q`
    substrRegex = new RegExp(q, 'i');

    // iterate through the pool of strings and for any string that
    // contains the substring `q`, add it to the `matches` array
    $.each(index, function(i, element) {
      if (substrRegex.test(element.name)) {
        matches.push(element.name);
      }
    });

    cb(matches);
  };

  function initTypeahead() {
    $('#search-box.typeahead').typeahead({
      hint: true,
      highlight: true,
      minLength: 3
    },
    {
      name: 'elements',
      source: findMatches
    });
  }

  var jsonReq = new XMLHttpRequest();
  jsonReq.open('GET', 'index.json', true);
  jsonReq.addEventListener('load', function() {
    index = JSON.parse(jsonReq.responseText);
    initTypeahead();
  });
  jsonReq.send();

}

document.addEventListener("DOMContentLoaded", function() {
  prettyPrint();
  initScroller();
  initSideNav();
  initSearch();

  // Make sure the anchors scroll past the fixed page header (#648).
  if (location.hash) shiftWindow();
  window.addEventListener("hashchange", shiftWindow);
});
