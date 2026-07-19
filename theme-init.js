(function () {
  "use strict";

  var theme = "light";
  try {
    var savedTheme = window.localStorage.getItem("mlfactor-zh-theme");
    if (savedTheme === "dark" || savedTheme === "light") {
      theme = savedTheme;
    } else if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
      theme = "dark";
    }
  } catch (error) {
    // Storage can be unavailable in strict privacy modes; system preference is
    // still applied when possible.
    if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
      theme = "dark";
    }
  }

  document.documentElement.dataset.theme = theme;
})();
