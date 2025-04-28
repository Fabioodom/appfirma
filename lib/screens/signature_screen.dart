// lib/screens/signature_screen.dart

import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';            // kIsWeb
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../widgets/signature_canvas.dart';
import 'preview_signature_screen.dart';

class SignatureScreen extends StatefulWidget {
  final File? pdfFile;       // Android/iOS
  final Uint8List? pdfBytes; // Web
  final Offset position;
  final int page;

  const SignatureScreen({
    Key? key,
    this.pdfFile,
    this.pdfBytes,
    required this.position,
    required this.page,
  }) : super(key: key);

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  // Key para controlar el SfSignaturePad
  final _sigPadKey = GlobalKey<SfSignaturePadState>();

  Future<void> _goToPreview() async {
    // 1) Renderiza el pad a imagen a alta resolución
    final ui.Image img = await _sigPadKey.currentState!
        .toImage(pixelRatio: 3.0);
    final ByteData? data = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (data == null) return;
    final Uint8List signatureBytes = data.buffer.asUint8List();

    // 2) Comprueba que el usuario ha dibujado algo
    if (signatureBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, dibuja tu firma antes de continuar')),
      );
      return;
    }

    // 3) Prepara los bytes del PDF
    final Uint8List pdfData = kIsWeb
        ? widget.pdfBytes!
        : await widget.pdfFile!.readAsBytes();

    // 4) Navega a la pantalla de previsualización
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewSignatureScreen(
          pdfBytes: pdfData,
          signatureImage: signatureBytes,
          initialPage: widget.page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = Colors.green.shade700;
    final yellow = Colors.yellow.shade600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        centerTitle: true,
        elevation: 2,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Firma tu Documento',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [green.withOpacity(0.3), yellow.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título de página
                    Text(
                      'Página ${widget.page}',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coloca tu firma dentro del recuadro y pulsa “Continuar”.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Lienzo de firma
                    SignatureCanvas(
                      signatureKey: _sigPadKey,
                      height: 250,
                    ),
                    const SizedBox(height: 32),

                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Limpiar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: green,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _sigPadKey.currentState?.clear(),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Continuar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _goToPreview,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
