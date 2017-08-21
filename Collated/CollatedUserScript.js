(function(exports) {

  "use strict";

  if (!location.href.startsWith("https://app.collated.net/")) {
    return;
  }

  function getMainContainerElement() {
    return document.getElementsByClassName("main-container")[0];
  }

  exports.toggleSidebar = function() {
    getMainContainerElement().classList.toggle("move-right");
  };

  exports.showSidebar = function() {
    getMainContainerElement().classList.add("move-right");
  };

  exports.hideSidebar = function() {
    getMainContainerElement().classList.remove("move-right");
  };

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
