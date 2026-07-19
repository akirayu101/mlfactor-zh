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
