import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

// Defined in web/index.html. `flutterCanInstall` reports whether the browser
// has fired `beforeinstallprompt` (i.e. the app is installable but not yet
// installed); `flutterInstallApp` shows the native install dialog.
@JS('flutterCanInstall')
external bool _canInstall();

@JS('flutterInstallApp')
external JSPromise? _installApp();

/// Web implementation of the "Install app" (PWA / Add to Home Screen) flow.
class InstallController {
  final ValueNotifier<bool> available = ValueNotifier<bool>(false);

  InstallController() {
    _update();
    // The page dispatches this when `beforeinstallprompt` arrives.
    web.window.addEventListener(
      'pwa-install-available',
      ((web.Event _) => _update()).toJS,
    );
    web.window.addEventListener(
      'appinstalled',
      ((web.Event _) => available.value = false).toJS,
    );
  }

  void _update() {
    try {
      available.value = _canInstall();
    } catch (_) {
      available.value = false;
    }
  }

  bool get isStandalone {
    try {
      return web.window.matchMedia('(display-mode: standalone)').matches;
    } catch (_) {
      return false;
    }
  }

  Future<void> prompt() async {
    try {
      final p = _installApp();
      if (p != null) await p.toDart;
    } catch (_) {
      // ignore — user dismissed or the browser refused.
    }
    _update();
  }

  void dispose() => available.dispose();
}

final InstallController installController = InstallController();
