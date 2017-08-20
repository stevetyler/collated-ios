(function(exports) {

  "use strict";

  if (!location.href.startsWith("https://app.collated.net/")) {
    return;
  }

  exports.toggleSidebar = function() {
    var elements = document.getElementsByClassName("main-container");
    for (var i = 0; i < elements.length; i++) {
      elements[i].classList.toggle("move-right");
    }
  }

  function injectStyle(style) {
    var styleElement = document.createElement("style");
    styleElement.innerHTML = style;
    document.body.appendChild(styleElement);
  }

  injectStyle(
    "header { display: none; }" +
    ".main-container { top: .3143rem; }"
  );

  document.querySelector("meta[name=viewport]").setAttribute("content",
    "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no");

}(this.CollatedUserScript = {}));
