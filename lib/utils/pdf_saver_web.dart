// solo se importa en web
import 'dart:html' as html;
import 'dart:typed_data';

Future<String> savePdf(Uint8List bytes, String fileName) async {
  final safeName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', safeName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return safeName; // en web devolvemos el nombre
}
