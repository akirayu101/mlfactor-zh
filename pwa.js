(function () {
  "use strict";

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

  function addInstallPrompt() {
    var installEvent = null;
    var button = document.createElement("button");
    button.type = "button";
    button.className = "pwa-install-button";
    button.textContent = "安装到手机";
    button.setAttribute("aria-label", "将本书安装到设备");
    document.body.appendChild(button);

    window.addEventListener("beforeinstallprompt", function (event) {
      event.preventDefault();
      installEvent = event;
      button.classList.add("is-visible");
    });

    button.addEventListener("click", async function () {
      if (!installEvent) return;
      button.classList.remove("is-visible");
      await installEvent.prompt();
      await installEvent.userChoice;
      installEvent = null;
    });

    window.addEventListener("appinstalled", function () {
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
    addReadingProgress();
    addNetworkStatus();
    addThemeToggle();
    addInstallPrompt();
    registerServiceWorker();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();
