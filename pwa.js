(function () {
  "use strict";

  var readingPositionStorageKey = "mlfactor-zh-reading-position-v1";

  function getPageName() {
    var page = window.location.pathname.split("/").pop();
    return page || "index.html";
  }

  function isBookPage(page) {
    return /^[A-Za-z0-9._-]+\.html$/.test(page) && page !== "404.html" && page !== "offline.html";
  }

  function readSavedPosition() {
    try {
      var saved = JSON.parse(window.localStorage.getItem(readingPositionStorageKey));
      if (!saved || !isBookPage(saved.page) || !Number.isFinite(saved.scrollY)) return null;
      return saved;
    } catch (error) {
      return null;
    }
  }

  function readingAnchorAtViewportTop() {
    if (!document.elementFromPoint) return null;
    var x = Math.max(1, Math.min(window.innerWidth / 2, window.innerWidth - 1));
    var y = Math.max(1, Math.min(96, window.innerHeight - 1));
    var element = document.elementFromPoint(x, y);
    if (!element || !element.closest) return null;
    return element.closest(".section[id], h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]");
  }

  function saveReadingPosition() {
    var page = getPageName();
    if (!isBookPage(page)) return;

    var anchor = readingAnchorAtViewportTop();
    var scrollY = Math.max(0, window.scrollY || window.pageYOffset || 0);
    var scrollable = Math.max(0, document.documentElement.scrollHeight - window.innerHeight);
    var position = {
      page: page,
      hash: window.location.hash || "",
      scrollY: Math.round(scrollY),
      progress: scrollable > 0 ? scrollY / scrollable : 0,
      updatedAt: Date.now()
    };

    if (anchor && anchor.id) {
      position.anchor = anchor.id;
      position.anchorOffset = Math.round(scrollY - (anchor.getBoundingClientRect().top + scrollY));
    }

    try {
      window.localStorage.setItem(readingPositionStorageKey, JSON.stringify(position));
    } catch (error) {
      // Reading still works normally when persistent storage is unavailable.
    }
  }

  function cleanResumeParameters() {
    if (!window.history || !window.history.replaceState) return;
    var url = new URL(window.location.href);
    url.searchParams.delete("pwa-launch");
    url.searchParams.delete("pwa-resume");
    window.history.replaceState(window.history.state, "", url.pathname + url.search + url.hash);
  }

  function isStandaloneApp() {
    var displayModeStandalone = window.matchMedia &&
      window.matchMedia("(display-mode: standalone)").matches;
    return displayModeStandalone || navigator.standalone === true;
  }

  function hasSameOriginReferrer() {
    if (!document.referrer) return false;
    try {
      return new URL(document.referrer).origin === window.location.origin;
    } catch (error) {
      return false;
    }
  }

  function addReadingPositionMemory() {
    var saved = readSavedPosition();
    var params = new URLSearchParams(window.location.search);
    var resumedFromLaunch = params.get("pwa-resume") === "1";
    var currentPage = getPageName();
    var legacyStandaloneLaunch = currentPage === "index.html" &&
      isStandaloneApp() && !hasSameOriginReferrer();
    var launchedAsApp = params.get("pwa-launch") === "1" || legacyStandaloneLaunch;

    if (launchedAsApp && saved && saved.page !== currentPage) {
      var destination = new URL(saved.page, window.location.href);
      destination.searchParams.set("pwa-resume", "1");
      if (saved.hash) destination.hash = saved.hash;
      window.location.replace(destination.href);
      return true;
    }

    var shouldRestore = saved && saved.page === currentPage &&
      (resumedFromLaunch || launchedAsApp || !window.location.hash);
    cleanResumeParameters();

    var restoreCancelled = false;
    var previousScrollRestoration = null;
    var restoreTimers = [];

    function cancelRestore() {
      restoreCancelled = true;
      restoreTimers.forEach(window.clearTimeout);
      restoreTimers = [];
      window.removeEventListener("keydown", cancelRestoreOnKey);
      if (previousScrollRestoration !== null) {
        window.history.scrollRestoration = previousScrollRestoration;
        previousScrollRestoration = null;
      }
    }

    function cancelRestoreOnKey(event) {
      if (["ArrowUp", "ArrowDown", "PageUp", "PageDown", "Home", "End", " "].includes(event.key)) {
        cancelRestore();
      }
    }

    function restore() {
      if (!shouldRestore || restoreCancelled) return;
      var top = saved.scrollY;
      if (saved.anchor) {
        var anchor = document.getElementById(saved.anchor);
        if (anchor) {
          top = anchor.getBoundingClientRect().top + window.scrollY + (saved.anchorOffset || 0);
        }
      }
      var maxScroll = Math.max(0, document.documentElement.scrollHeight - window.innerHeight);
      window.scrollTo(0, Math.min(maxScroll, Math.max(0, top)));
    }

    if (shouldRestore) {
      if ("scrollRestoration" in window.history) {
        previousScrollRestoration = window.history.scrollRestoration;
        window.history.scrollRestoration = "manual";
      }
      restore();
      window.addEventListener("load", restore, { once: true });
      [250, 750, 1500].forEach(function (delay) {
        restoreTimers.push(window.setTimeout(restore, delay));
      });
      restoreTimers.push(window.setTimeout(function () {
        if (resumedFromLaunch || launchedAsApp || saved.scrollY > 40) {
          showToast("已回到上次阅读位置");
        }
        cancelRestore();
      }, 1650));

      ["wheel", "touchstart", "pointerdown"].forEach(function (eventName) {
        window.addEventListener(eventName, cancelRestore, { once: true, passive: true });
      });
      window.addEventListener("keydown", cancelRestoreOnKey);
    }

    var saveTimer = null;
    function scheduleSave() {
      window.clearTimeout(saveTimer);
      saveTimer = window.setTimeout(saveReadingPosition, 250);
    }

    window.addEventListener("scroll", scheduleSave, { passive: true });
    window.addEventListener("pagehide", saveReadingPosition);
    document.addEventListener("visibilitychange", function () {
      if (document.visibilityState === "hidden") saveReadingPosition();
    });
    return false;
  }

  function addReadingProgress() {
    var bar = document.createElement("div");
    bar.className = "pwa-reading-progress";
    bar.setAttribute("aria-hidden", "true");
    document.body.appendChild(bar);

    var scheduled = false;
    function update() {
      var root = document.documentElement;
      var scrollable = root.scrollHeight - window.innerHeight;
      var progress = scrollable > 0 ? (window.scrollY / scrollable) * 100 : 0;
      bar.style.width = Math.min(100, Math.max(0, progress)) + "%";
      scheduled = false;
    }

    function requestUpdate() {
      if (!scheduled) {
        scheduled = true;
        window.requestAnimationFrame(update);
      }
    }

    window.addEventListener("scroll", requestUpdate, { passive: true });
    window.addEventListener("resize", requestUpdate, { passive: true });
    update();
  }

  var toastTimer;
  function showToast(message, actionLabel, action) {
    var toast = document.getElementById("pwa-toast");
    if (!toast) {
      toast = document.createElement("div");
      toast.id = "pwa-toast";
      toast.className = "pwa-toast";
      toast.setAttribute("role", "status");
      toast.setAttribute("aria-live", "polite");
      document.body.appendChild(toast);
    }

    toast.replaceChildren();
    var text = document.createElement("span");
    text.textContent = message;
    toast.appendChild(text);

    if (actionLabel && action) {
      var button = document.createElement("button");
      button.type = "button";
      button.textContent = actionLabel;
      button.addEventListener("click", action);
      toast.appendChild(button);
    }

    window.clearTimeout(toastTimer);
    window.requestAnimationFrame(function () {
      toast.classList.add("is-visible");
    });
    if (!actionLabel) {
      toastTimer = window.setTimeout(function () {
        toast.classList.remove("is-visible");
      }, 2600);
    }
  }

  function addNetworkStatus() {
    window.addEventListener("offline", function () {
      showToast("已进入离线阅读模式");
    });
    window.addEventListener("online", function () {
      showToast("网络已恢复");
    });
  }

  function addThemeToggle() {
    var storageKey = "mlfactor-zh-theme";
    var button = document.createElement("button");
    button.type = "button";
    button.className = "btn btn-outline-secondary pwa-theme-toggle";

    var icon = document.createElement("span");
    icon.className = "pwa-theme-icon";
    icon.setAttribute("aria-hidden", "true");
    var label = document.createElement("span");
    label.className = "pwa-theme-label";
    button.append(icon, label);

    var header = document.querySelector(".sidebar-book .d-flex.align-items-start");
    var menuButton = header && header.querySelector('button[data-target="#main-nav"]');
    if (header) {
      var actions = document.createElement("div");
      actions.className = "pwa-header-actions";
      header.insertBefore(actions, menuButton || null);
      actions.appendChild(button);
      if (menuButton) actions.appendChild(menuButton);
    } else {
      button.classList.add("pwa-theme-toggle-fallback");
      document.body.appendChild(button);
    }

    function storedTheme() {
      try {
        var value = window.localStorage.getItem(storageKey);
        return value === "dark" || value === "light" ? value : null;
      } catch (error) {
        return null;
      }
    }

    function reflectTheme(theme) {
      var isDark = theme === "dark";
      icon.textContent = isDark ? "☀" : "☾";
      label.textContent = isDark ? "浅色" : "深色";
      button.setAttribute("aria-pressed", String(isDark));
      button.setAttribute("aria-label", isDark ? "切换到浅色模式" : "切换到深色模式");
      button.title = isDark ? "切换到浅色模式" : "切换到深色模式";
      document.querySelectorAll('meta[name="theme-color"]').forEach(function (meta) {
        meta.content = isDark ? "#0b1117" : "#173f5f";
      });
    }

    function applyTheme(theme, persist) {
      document.documentElement.dataset.theme = theme;
      if (persist) {
        try {
          window.localStorage.setItem(storageKey, theme);
        } catch (error) {
          // The visual toggle still works when storage is unavailable.
        }
      }
      reflectTheme(theme);
    }

    var initialTheme = document.documentElement.dataset.theme === "dark" ? "dark" : "light";
    applyTheme(initialTheme, false);

    button.addEventListener("click", function () {
      applyTheme(document.documentElement.dataset.theme === "dark" ? "light" : "dark", true);
    });

    if (window.matchMedia) {
      var colorScheme = window.matchMedia("(prefers-color-scheme: dark)");
      var syncWithSystem = function (event) {
        if (!storedTheme()) applyTheme(event.matches ? "dark" : "light", false);
      };
      if (colorScheme.addEventListener) colorScheme.addEventListener("change", syncWithSystem);
    }
  }

  function addFontSizeControl() {
    var storageKey = "mlfactor-zh-font-size";
    var sizes = [90, 100, 110, 120, 130];
    var wrapper = document.createElement("div");
    wrapper.className = "pwa-font-control";

    var toggle = document.createElement("button");
    toggle.type = "button";
    toggle.className = "btn btn-outline-secondary pwa-font-toggle";
    toggle.textContent = "Aa";
    toggle.setAttribute("aria-controls", "pwa-font-menu");
    toggle.setAttribute("aria-expanded", "false");
    toggle.title = "调整字号";

    var panel = document.createElement("div");
    panel.id = "pwa-font-menu";
    panel.className = "pwa-font-menu";
    panel.setAttribute("role", "group");
    panel.setAttribute("aria-label", "字体大小");
    panel.hidden = true;

    var decrease = document.createElement("button");
    decrease.type = "button";
    decrease.className = "pwa-font-step";
    decrease.textContent = "A−";
    decrease.setAttribute("aria-label", "减小字体");

    var reset = document.createElement("button");
    reset.type = "button";
    reset.className = "pwa-font-reset";
    reset.title = "恢复默认字号";

    var increase = document.createElement("button");
    increase.type = "button";
    increase.className = "pwa-font-step";
    increase.textContent = "A+";
    increase.setAttribute("aria-label", "增大字体");

    panel.append(decrease, reset, increase);
    wrapper.append(toggle, panel);

    var actions = document.querySelector(".pwa-header-actions");
    var themeButton = actions && actions.querySelector(".pwa-theme-toggle");
    if (actions) {
      actions.insertBefore(wrapper, themeButton || actions.firstChild);
    } else {
      wrapper.classList.add("pwa-font-control-fallback");
      document.body.appendChild(wrapper);
    }

    function normalizeSize(value) {
      var parsed = Number.parseInt(value, 10);
      return sizes.includes(parsed) ? parsed : 100;
    }

    function currentSize() {
      return normalizeSize(document.documentElement.dataset.readerFontSize);
    }

    function reflectSize(size) {
      var index = sizes.indexOf(size);
      reset.textContent = size + "%";
      reset.setAttribute("aria-label", "恢复默认字号，当前字号 " + size + "%");
      toggle.setAttribute("aria-label", "调整字体大小，当前字号 " + size + "%");
      decrease.disabled = index === 0;
      increase.disabled = index === sizes.length - 1;
    }

    function applySize(size, persist, preservePosition) {
      var normalized = normalizeSize(size);
      var anchor = preservePosition ? readingAnchorAtViewportTop() : null;
      var anchorTop = anchor ? anchor.getBoundingClientRect().top : null;
      document.documentElement.dataset.readerFontSize = String(normalized);

      if (persist) {
        try {
          window.localStorage.setItem(storageKey, String(normalized));
        } catch (error) {
          // Font controls still work when persistent storage is unavailable.
        }
      }

      reflectSize(normalized);
      window.requestAnimationFrame(function () {
        if (anchor && anchorTop !== null) {
          window.scrollBy(0, anchor.getBoundingClientRect().top - anchorTop);
        }
        window.dispatchEvent(new Event("resize"));
        if (persist) saveReadingPosition();
      });
    }

    function closePanel() {
      panel.hidden = true;
      wrapper.classList.remove("is-open");
      toggle.setAttribute("aria-expanded", "false");
    }

    function openPanel() {
      panel.hidden = false;
      wrapper.classList.add("is-open");
      toggle.setAttribute("aria-expanded", "true");
    }

    toggle.addEventListener("click", function () {
      if (panel.hidden) openPanel();
      else closePanel();
    });

    decrease.addEventListener("click", function () {
      var index = sizes.indexOf(currentSize());
      if (index > 0) applySize(sizes[index - 1], true, true);
    });

    reset.addEventListener("click", function () {
      applySize(100, true, true);
    });

    increase.addEventListener("click", function () {
      var index = sizes.indexOf(currentSize());
      if (index < sizes.length - 1) applySize(sizes[index + 1], true, true);
    });

    document.addEventListener("click", function (event) {
      if (!wrapper.contains(event.target)) closePanel();
    });

    document.addEventListener("keydown", function (event) {
      if (event.key !== "Escape" || panel.hidden) return;
      closePanel();
      toggle.focus();
    });

    applySize(currentSize(), false, false);
  }

  function addInstallPrompt() {
    var installEvent = null;
    var isIos = /iPad|iPhone|iPod/.test(navigator.userAgent) ||
      (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);
    var isStandalone = window.matchMedia("(display-mode: standalone)").matches ||
      navigator.standalone === true;

    if (isStandalone) return;

    var button = document.createElement("button");
    button.type = "button";
    button.className = "pwa-install-button";
    button.textContent = isIos ? "添加到主屏幕" : "安装到手机";
    button.setAttribute("aria-label", "将本书安装到设备");
    document.body.appendChild(button);

    var dialog = null;
    var dialogCloseButton = null;

    function closeIosInstructions() {
      if (!dialog) return;
      dialog.classList.remove("is-visible");
      dialog.setAttribute("aria-hidden", "true");
      document.body.classList.remove("pwa-dialog-open");
      button.focus();
    }

    function showIosInstructions() {
      if (!dialog) {
        dialog = document.createElement("div");
        dialog.className = "pwa-install-dialog";
        dialog.setAttribute("aria-hidden", "true");

        var panel = document.createElement("section");
        panel.className = "pwa-install-panel";
        panel.setAttribute("role", "dialog");
        panel.setAttribute("aria-modal", "true");
        panel.setAttribute("aria-labelledby", "pwa-install-title");

        var handle = document.createElement("div");
        handle.className = "pwa-install-handle";
        handle.setAttribute("aria-hidden", "true");

        var heading = document.createElement("h2");
        heading.id = "pwa-install-title";
        heading.textContent = "添加到 iPhone 主屏幕";

        var intro = document.createElement("p");
        intro.textContent = "iPhone 不会弹出自动安装窗口，请按下面三步操作：";

        var steps = document.createElement("ol");
        [
          "点击浏览器底部或顶部的“分享”按钮（方框上箭头）。",
          "在分享菜单中向上滑，选择“添加到主屏幕”。",
          "确认名称后点击右上角的“添加”。"
        ].forEach(function (instruction) {
          var item = document.createElement("li");
          item.textContent = instruction;
          steps.appendChild(item);
        });

        var note = document.createElement("p");
        note.className = "pwa-install-note";
        note.textContent = "如果菜单中没有“添加到主屏幕”，请复制当前链接并改用 Safari 打开。";

        dialogCloseButton = document.createElement("button");
        dialogCloseButton.type = "button";
        dialogCloseButton.className = "pwa-install-confirm";
        dialogCloseButton.textContent = "知道了";
        dialogCloseButton.addEventListener("click", closeIosInstructions);

        panel.append(handle, heading, intro, steps, note, dialogCloseButton);
        dialog.appendChild(panel);
        dialog.addEventListener("click", function (event) {
          if (event.target === dialog) closeIosInstructions();
        });
        document.body.appendChild(dialog);
      }

      dialog.classList.add("is-visible");
      dialog.setAttribute("aria-hidden", "false");
      document.body.classList.add("pwa-dialog-open");
      dialogCloseButton.focus();
    }

    if (isIos) button.classList.add("is-visible");

    window.addEventListener("beforeinstallprompt", function (event) {
      event.preventDefault();
      installEvent = event;
      button.classList.add("is-visible");
    });

    button.addEventListener("click", async function () {
      if (isIos) {
        showIosInstructions();
        return;
      }
      if (!installEvent) return;
      button.classList.remove("is-visible");
      await installEvent.prompt();
      await installEvent.userChoice;
      installEvent = null;
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape" && dialog && dialog.classList.contains("is-visible")) {
        closeIosInstructions();
      }
    });

    window.addEventListener("appinstalled", function () {
      if (dialog) dialog.remove();
      button.remove();
      showToast("安装完成，现在可以离线阅读");
    });
  }

  function registerServiceWorker() {
    if (!("serviceWorker" in navigator)) {
      document.documentElement.dataset.pwaServiceWorker = "unsupported";
      return;
    }

    document.documentElement.dataset.pwaServiceWorker = "registering";

    navigator.serviceWorker.register("./sw.js", { scope: "./" }).then(function (registration) {
      document.documentElement.dataset.pwaServiceWorker = "registered";
      var lifecycleWorker = registration.installing || registration.waiting || registration.active;
      if (lifecycleWorker) {
        document.documentElement.dataset.pwaServiceWorker = lifecycleWorker.state;
        lifecycleWorker.addEventListener("statechange", function () {
          document.documentElement.dataset.pwaServiceWorker = lifecycleWorker.state;
        });
      }
      function offerUpdate(worker) {
        showToast("发现新版本", "立即更新", function () {
          worker.postMessage({ type: "SKIP_WAITING" });
        });
      }

      if (registration.waiting) offerUpdate(registration.waiting);

      registration.addEventListener("updatefound", function () {
        var worker = registration.installing;
        if (!worker) return;
        worker.addEventListener("statechange", function () {
          if (worker.state === "installed" && navigator.serviceWorker.controller) {
            offerUpdate(worker);
          }
        });
      });
    }).catch(function (error) {
      document.documentElement.dataset.pwaServiceWorker = "failed";
      console.warn("Service Worker 注册失败：", error);
    });

    navigator.serviceWorker.ready.then(function () {
      document.documentElement.dataset.pwaServiceWorker = "ready";
    });

    var reloading = false;
    navigator.serviceWorker.addEventListener("controllerchange", function () {
      if (reloading) return;
      reloading = true;
      window.location.reload();
    });
  }

  function init() {
    if (addReadingPositionMemory()) return;
    addReadingProgress();
    addNetworkStatus();
    addThemeToggle();
    addFontSizeControl();
    addInstallPrompt();
    registerServiceWorker();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();
