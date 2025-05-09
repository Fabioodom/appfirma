// exporta la misma función pero con implementación IO o Web
export 'pdf_saver_io.dart' if (dart.library.html) 'pdf_saver_web.dart';
