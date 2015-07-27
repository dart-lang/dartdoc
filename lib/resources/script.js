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

  var overlay = document.createElement('div');
  overlay.id = 'overlay-under-drawer';
  overlay.addEventListener('click', function(e) {
    if (leftDrawer) leftDrawer.classList.remove('active');
    document.body.removeChild(overlay);
  });

  if (leftNavToggle) {
    leftNavToggle.addEventListener('click', function(e) {
      if (leftDrawer) {
        leftDrawer.classList.toggle('active');
        document.body.appendChild(overlay);
      }
    });
  }
}

// Make sure the anchors scroll past the fixed page header (#648).
function shiftWindow() {
  scrollBy(0, -68);
}

document.addEventListener("DOMContentLoaded", function() {
  prettyPrint();
  initScroller();
  initSideNav();

  // Make sure the anchors scroll past the fixed page header (#648).
  if (location.hash) shiftWindow();
  window.addEventListener("hashchange", shiftWindow);
});
