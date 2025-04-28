// lib/screens/pdf_view_screen.dart

import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';        // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';         // RenderBox
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'signature_screen.dart';

class PdfViewScreen extends StatefulWidget {
  final File? pdfFile;       // Para Android/iOS
  final Uint8List? pdfBytes; // Para Web

  const PdfViewScreen({
    Key? key,
    this.pdfFile,
    this.pdfBytes,
  }) : super(key: key);

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey _pdfViewerKey = GlobalKey();
  Offset? _tapPosition;
  int _selectedPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final box = _pdfViewerKey.currentContext?.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);
    setState(() {
      _tapPosition = localPos;
      _selectedPage = _pdfViewerController.pageNumber;
    });
    _goToSignature();
  }

  void _goToSignature() {
    if (_tapPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doble-tap para elegir dónde firmar')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignatureScreen(
          pdfFile: kIsWeb ? null : widget.pdfFile,
          pdfBytes: kIsWeb ? widget.pdfBytes : null,
          position: _tapPosition!,
          page: _selectedPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = Colors.green.shade700;
    final yellow = Colors.yellow.shade600;

    return Scaffold(
      // AppBar con logo y color de empresa
      appBar: AppBar(
  backgroundColor: green,
  elevation: 2,
  centerTitle: true,
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
        'Vista previa PDF',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ],
  ),
),


      // Fondo degradado verde → amarillo
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [green.withOpacity(0.3), yellow.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // PDF Viewer
                  if (kIsWeb && widget.pdfBytes != null)
                    SfPdfViewer.memory(
                      widget.pdfBytes!,
                      controller: _pdfViewerController,
                      key: _pdfViewerKey,
                    )
                  else if (widget.pdfFile != null)
                    SfPdfViewer.file(
                      widget.pdfFile!,
                      controller: _pdfViewerController,
                      key: _pdfViewerKey,
                    )
                  else
                    const Center(child: Text('No se pudo cargar el PDF')),

                  // Capa para capturar doble-tap
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onDoubleTapDown: _onDoubleTapDown,
                    ),
                  ),

                  // Indicador de posición
                  if (_tapPosition != null)
                    Positioned(
                      left: _tapPosition!.dx - 15,
                      top: _tapPosition!.dy - 15,
                      child: Icon(
                        Icons.edit_location_alt,
                        color: green,
                        size: 30,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
