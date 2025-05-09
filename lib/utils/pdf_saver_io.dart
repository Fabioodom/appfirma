// lib/utils/pdf_saver_io.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> savePdf(Uint8List bytes, String fileName) async {
  final safeName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';

  Directory targetDir;
  if (Platform.isAndroid) {
    // 1) Pedimos "All files access" en Android 11+
    if (!await Permission.manageExternalStorage.isGranted) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        await openAppSettings();
        throw Exception('Permiso MANAGE_EXTERNAL_STORAGE denegado');
      }
    }

    // 2) Carpeta pública Download
    final downloadPath = '/storage/emulated/0/Download';
    final downloadDir = Directory(downloadPath);
    if (!await downloadDir.exists()) {
      throw Exception('No se encontró la carpeta $downloadPath');
    }
    targetDir = downloadDir;
  } else {
    // iOS / Desktop: carpeta de documentos de la app
    targetDir = await getApplicationDocumentsDirectory();
  }

  // 3) Escribimos el fichero
  final path = '${targetDir.path}/$safeName';
  final file = File(path);
  await file.writeAsBytes(bytes);
  return path;
}
