// The browser's language: intl_browser on the web (intl 0.20 uses dart:js_interop), intl_standalone elsewhere.
export 'system_locale_io.dart' if (dart.library.js_interop) 'system_locale_web.dart';
