// lib/screens/preview_signature_screen.dart

import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';   // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PreviewSignatureScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final Uint8List signatureImage;
  final int initialPage;

  const PreviewSignatureScreen({
    Key? key,
    required this.pdfBytes,
    required this.signatureImage,
    required this.initialPage,
  }) : super(key: key);

  @override
  State<PreviewSignatureScreen> createState() => _PreviewSignatureScreenState();
}

class _PreviewSignatureScreenState extends State<PreviewSignatureScreen> {
  Offset _sigPos = const Offset(100, 100);
  double _sigWidth = 150, _sigHeight = 75;
  double _sigOpacity = 0.9;
  double _sigRotation = 0.0; // radianes
  int _currentPage = 1, _totalPages = 1;
  late PdfViewerController _pdfViewerController;
  late TextEditingController _jumpController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _jumpController = TextEditingController();
    _currentPage = widget.initialPage;

    // Carga total de páginas
    final doc = PdfDocument(inputBytes: widget.pdfBytes);
    _totalPages = doc.pages.count;
    doc.dispose();
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  Future<Uint8List> _renderSignedPdf() async {
    final doc = PdfDocument(inputBytes: widget.pdfBytes);
    final page = doc.pages[_currentPage - 1];
    final image = PdfBitmap(widget.signatureImage);

    const pw = 595.0, ph = 842.0;
    final sz = MediaQuery.of(context).size;
    final rx = _sigPos.dx / sz.width;
    final ry = _sigPos.dy / sz.height;

    page.graphics
      ..save()
      ..drawImage(
        image,
        Rect.fromLTWH(rx * pw, ry * ph, _sigWidth, _sigHeight),
      )
      ..restore();

    final bytes = Uint8List.fromList(doc.saveSync());
    doc.dispose();
    return bytes;
  }

  Future<void> _saveToDevice() async {
    final signed = await _renderSignedPdf();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/signed_page$_currentPage.pdf');
    await file.writeAsBytes(signed);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guardado en: ${file.path}')),
      );
    }
  }

  Future<void> _sharePdf() async {
    final signed = await _renderSignedPdf();
    if (kIsWeb) {
      final blob = XFile.fromData(signed, mimeType: 'application/pdf', name: 'signed.pdf');
      await Share.shareXFiles([blob], text: 'PDF firmado');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/signed_page$_currentPage.pdf');
      await file.writeAsBytes(signed);
      await Share.shareXFiles([XFile(file.path)], text: 'PDF firmado');
    }
  }

  void _changePage(bool fwd) {
    final next = _currentPage + (fwd ? 1 : -1);
    if (next >= 1 && next <= _totalPages) {
      setState(() {
        _currentPage = next;
        _pdfViewerController.jumpToPage(_currentPage);
      });
    }
  }

  void _jumpToPage() {
    final v = int.tryParse(_jumpController.text);
    if (v != null && v >= 1 && v <= _totalPages) {
      setState(() {
        _currentPage = v;
        _pdfViewerController.jumpToPage(v);
      });
    }
  }

  void _zoomIn() => _pdfViewerController.zoomLevel *= 1.2;
  void _zoomOut() => _pdfViewerController.zoomLevel /= 1.2;
  void _resetSignature() => setState(() {
        _sigPos = const Offset(100, 100);
        _sigWidth = 150;
        _sigHeight = 75;
        _sigOpacity = 0.9;
        _sigRotation = 0.0;
      });

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
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Image.asset('assets/images/logo.png', height: 32),
            ),
            const SizedBox(width: 8),
            const Text('Previsualizar Firma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Container(
        // 1) Asegura que cubre todo el espacio
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [green.withOpacity(0.3), yellow.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          // 2) Centra tu contenido limitado a 900px
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              children: [
                // PANEL IZQUIERDO...
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(icon: Icon(Icons.chevron_left, color: green), onPressed: () => _changePage(false)),
                              Text('$_currentPage / $_totalPages', style: theme.textTheme.titleMedium),
                              IconButton(icon: Icon(Icons.chevron_right, color: green), onPressed: () => _changePage(true)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                SfPdfViewer.memory(widget.pdfBytes, controller: _pdfViewerController),
                                Positioned(
                                  left: _sigPos.dx,
                                  top: _sigPos.dy,
                                  child: GestureDetector(
                                    onPanUpdate: (e) => setState(() => _sigPos += e.delta),
                                    child: Transform.rotate(
                                      angle: _sigRotation,
                                      child: Opacity(
                                        opacity: _sigOpacity,
                                        child: Image.memory(widget.signatureImage, width: _sigWidth, height: _sigHeight),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Tamaño de la firma', style: theme.textTheme.bodyMedium),
                              Slider(
                                value: _sigWidth,
                                min: 50,
                                max: 300,
                                divisions: 10,
                                label: '${_sigWidth.round()} px',
                                onChanged: (v) => setState(() {
                                  _sigWidth = v;
                                  _sigHeight = v * 0.5;
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // PANEL DERECHO...
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Información
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Información', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text('Páginas: $_totalPages'),
                                Text('Tamaño: ${widget.pdfBytes.lengthInBytes ~/ 1024} KB'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ir a página
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Ir a página', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _jumpController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(hintText: 'Número de página', isDense: true),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: green),
                                      onPressed: _jumpToPage,
                                      child: const Text('Ir'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Acciones rápidas
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text('Acciones', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(icon: Icon(Icons.zoom_in, color: green), tooltip: 'Zoom in', onPressed: _zoomIn),
                                    IconButton(icon: Icon(Icons.zoom_out, color: green), tooltip: 'Zoom out', onPressed: _zoomOut),
                                    IconButton(icon: Icon(Icons.refresh, color: green), tooltip: 'Reset firma', onPressed: _resetSignature),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ajustes de firma
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Ajustes de firma', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text('Opacidad: ${(_sigOpacity * 100).round()}%'),
                                Slider(
                                  value: _sigOpacity,
                                  min: 0.2,
                                  max: 1.0,
                                  divisions: 8,
                                  onChanged: (v) => setState(() => _sigOpacity = v),
                                ),
                                const SizedBox(height: 8),
                                Text('Rotación: ${( _sigRotation * 180 / 3.1416).round()}°'),
                                Slider(
                                  value: _sigRotation,
                                  min: -3.1416 / 4,
                                  max: 3.1416 / 4,
                                  divisions: 8,
                                  onChanged: (v) => setState(() => _sigRotation = v),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Exportar PDF
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Exportar PDF', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.download),
                                  label: const Text('Descargar'),
                                  style: ElevatedButton.styleFrom(backgroundColor: green),
                                  onPressed: _saveToDevice,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.share),
                                  label: const Text('Compartir'),
                                  style: ElevatedButton.styleFrom(backgroundColor: green),
                                  onPressed: _sharePdf,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
