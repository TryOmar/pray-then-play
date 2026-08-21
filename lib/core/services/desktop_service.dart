export 'desktop_service_io.dart'
    if (dart.library.js_interop) 'desktop_service_web.dart'
    if (dart.library.html) 'desktop_service_web.dart';
