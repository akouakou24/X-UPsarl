/* X-UPsarl — Service Worker (PWA : installation + hors-ligne) */
const CACHE = "xup-v1";
const CORE = [
  "/", "/index.html",
  "/assets/css/style.css", "/assets/css/responsive.css",
  "/assets/js/layout.js", "/assets/js/data.js",
  "/manifest.webmanifest",
  "/assets/img/icon-192.png", "/assets/img/icon-512.png",
  "/assets/img/logo-compact.svg", "/assets/img/logo.svg"
];

self.addEventListener("install", (e) => {
  e.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(CORE).catch(() => {})).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);

  // Le module de gestion (back-end) ne doit jamais être mis en cache
  if (url.pathname.startsWith("/cadastre")) return;

  // Pages (navigation) : réseau d'abord, puis cache, puis page d'accueil hors-ligne
  if (req.mode === "navigate") {
    e.respondWith(
      fetch(req).then((r) => { const cp = r.clone(); caches.open(CACHE).then((c) => c.put(req, cp)); return r; })
                .catch(() => caches.match(req).then((m) => m || caches.match("/index.html")))
    );
    return;
  }

  // Autres ressources : cache d'abord, sinon réseau (puis mise en cache)
  e.respondWith(
    caches.match(req).then((m) => m || fetch(req).then((r) => {
      if (r.ok && url.origin === location.origin) {
        const cp = r.clone(); caches.open(CACHE).then((c) => c.put(req, cp));
      }
      return r;
    }).catch(() => m))
  );
});
