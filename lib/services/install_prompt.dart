// Exposes `installController` backed by a web implementation (PWA install
// prompt) on the web, and a no-op stub everywhere else.
export 'install_prompt_stub.dart'
    if (dart.library.js_interop) 'install_prompt_web.dart';
