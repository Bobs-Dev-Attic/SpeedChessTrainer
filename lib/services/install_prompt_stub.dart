import 'package:flutter/foundation.dart';

/// Non-web stub: native platforms have their own install flow, so the
/// in-app install button is never shown.
class InstallController {
  final ValueNotifier<bool> available = ValueNotifier<bool>(false);

  bool get isStandalone => false;

  Future<void> prompt() async {}

  void dispose() => available.dispose();
}

final InstallController installController = InstallController();
