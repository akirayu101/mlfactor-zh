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

  var fontSize = "100";
  try {
    var savedFontSize = window.localStorage.getItem("mlfactor-zh-font-size");
    if (["90", "100", "110", "120", "130"].includes(savedFontSize)) {
      fontSize = savedFontSize;
    }
  } catch (error) {
    // The default size remains available when persistent storage is blocked.
  }

  document.documentElement.dataset.readerFontSize = fontSize;
})();
