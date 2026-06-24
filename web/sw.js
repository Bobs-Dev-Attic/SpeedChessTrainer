// Custom service worker for offline support.
//
// Flutter's generated service worker no longer caches assets (it just
// unregisters itself), so the app provides its own: the entry points are
// precached on install, and every same-origin GET is cached as it is fetched.
// Navigations are network-first (so updates are picked up online) and fall
// back to the cached shell when offline; all other assets are cache-first.

// The cache name carries a build id (replaced at build time by
// vercel_build.sh). A new build => new cache name => the activate handler
// clears the old cache and fresh assets are fetched, so users always get the
// latest deploy instead of a stale cached one.
const CACHE = 'speed-chess-trainer-__BUILD_ID__';
const PRECACHE = [
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE).then((cache) =>
      cache
        .addAll(PRECACHE.map((u) => new Request(u, { cache: 'reload' })))
        .catch(() => {})
    )
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)));
      await self.clients.claim();
    })()
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return; // leave cross-origin alone

  // Navigations: network-first, fall back to the cached app shell.
  if (req.mode === 'navigate') {
    event.respondWith(
      (async () => {
        try {
          const res = await fetch(req);
          const cache = await caches.open(CACHE);
          cache.put('index.html', res.clone());
          return res;
        } catch (_) {
          return (await caches.match('index.html')) || Response.error();
        }
      })()
    );
    return;
  }

  // Everything else: cache-first, populating the cache on a miss.
  event.respondWith(
    (async () => {
      const cached = await caches.match(req);
      if (cached) return cached;
      try {
        const res = await fetch(req);
        if (res && res.status === 200 && res.type === 'basic') {
          const cache = await caches.open(CACHE);
          cache.put(req, res.clone());
        }
        return res;
      } catch (_) {
        return cached || Response.error();
      }
    })()
  );
});
