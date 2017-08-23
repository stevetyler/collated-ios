(function(exports) {

  "use strict";

  // Only run the user script on app.collated.net
  if (!location.href.startsWith("https://app.collated.net/")) {
    return;
  }

  exports.toggleSidebar = function() {
    var elements = document.getElementsByClassName("main-container");
    for (var i = 0; i < elements.length; i++) {
      elements[i].classList.toggle("move-right");
    }
  };

  function injectStyle(style) {
    var styleElement = document.createElement("style");
    styleElement.innerHTML = style;
    document.body.appendChild(styleElement);
  }

  function setup() {
    injectStyle(
      // Completely hide the navigation bar
      "header { display: none; }" +
      // Match .main-container top spacing to .is-bookmark
      ".main-container { top: .3143rem; }"
    );

    // Disable zooming
    document.querySelector("meta[name=viewport]").setAttribute("content",
      "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no");
  }

  setup();

}(this.CollatedUserScript = {}));
