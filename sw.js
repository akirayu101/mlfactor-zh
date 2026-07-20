const CACHE_VERSION = "mlfactor-zh-v14";
const PAGE_CACHE = `${CACHE_VERSION}-pages`;
const ASSET_CACHE = `${CACHE_VERSION}-assets`;

const CORE_ASSETS = [
  "./",
  "./index.html",
  "./404.html",
  "./backtest.html",
  "./bayes.html",
  "./causality.html",
  "./data-description.html",
  "./Data.html",
  "./ensemble.html",
  "./factor.html",
  "./interp.html",
  "./intro.html",
  "./lasso.html",
  "./NN.html",
  "./notdata.html",
  "./preface.html",
  "./python-notebooks.html",
  "./python.html",
  "./RL.html",
  "./solutions-to-exercises.html",
  "./svm.html",
  "./trees.html",
  "./unsup.html",
  "./valtune.html",
  "./offline.html",
  "./manifest.webmanifest",
  "./pwa.css",
  "./pwa.js",
  "./theme-init.js",
  "./images/pwa-icon-180.png",
  "./images/pwa-icon-192.png",
  "./images/pwa-icon-512.png",
  "./images/cover.png",
  "./libs/bootstrap-4.5.3/bootstrap.min.css",
  "./libs/bootstrap-4.5.3/bootstrap.bundle.min.js",
  "./libs/bootstrap-4.6.0/bootstrap.min.css",
  "./libs/bootstrap-4.6.0/bootstrap.bundle.min.js",
  "./libs/bs3compat-0.2.3.9000/tabs.js",
  "./libs/bs3compat-0.2.3.9000/bs3compat.js",
  "./libs/bs3compat-0.3.1/tabs.js",
  "./libs/bs3compat-0.3.1/transition.js",
  "./libs/bs3compat-0.3.1/bs3compat.js",
  "./libs/bs4_book-1.0.0/bs4_book.css",
  "./libs/bs4_book-1.0.0/bs4_book.js",
  "./libs/header-attrs-2.11/header-attrs.js",
  "./libs/header-attrs-2.8/header-attrs.js",
  "./libs/jquery-3.5.1/jquery-3.5.1.min.js",
  "./libs/jquery-3.6.0/jquery-3.6.0.min.js",
  "./libs/kePrint-0.0.1/kePrint.js",
  "./libs/lightable-0.0.1/lightable.css"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(PAGE_CACHE)
      .then((cache) => cache.addAll(CORE_ASSETS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys
          .filter((key) => key.startsWith("mlfactor-zh-") && ![PAGE_CACHE, ASSET_CACHE].includes(key))
          .map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("message", (event) => {
  if (event.data && event.data.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});

async function fetchWithTimeout(request, timeoutMs) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetch(request, { signal: controller.signal });
  } finally {
    clearTimeout(timer);
  }
}

async function networkFirstPage(request) {
  const cache = await caches.open(PAGE_CACHE);
  try {
    const response = await fetchWithTimeout(request, 4000);
    if (response.ok) cache.put(request, response.clone());
    return response;
  } catch (error) {
    return (await cache.match(request, { ignoreSearch: true })) ||
      (await cache.match(new URL("offline.html", self.registration.scope)));
  }
}

async function cacheFirstAsset(request) {
  const cached = await caches.match(request, { ignoreSearch: true });
  if (cached) return cached;

  const response = await fetch(request);
  if (response.ok || response.type === "opaque") {
    const cache = await caches.open(ASSET_CACHE);
    cache.put(request, response.clone());
  }
  return response;
}

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET" || request.headers.has("range")) return;

  const url = new URL(request.url);
  const scope = new URL(self.registration.scope);
  if (url.origin !== scope.origin) {
    if (["font", "image", "script", "style"].includes(request.destination)) {
      event.respondWith(cacheFirstAsset(request));
    }
    return;
  }

  if (!url.pathname.startsWith(scope.pathname)) return;

  if (request.mode === "navigate") {
    event.respondWith(networkFirstPage(request));
    return;
  }

  event.respondWith(cacheFirstAsset(request));
});
