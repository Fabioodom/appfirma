// lib/widgets/signature_canvas.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class SignatureCanvas extends StatelessWidget {
  final GlobalKey<SfSignaturePadState> signatureKey;
  final double height;

  const SignatureCanvas({
    Key? key,
    required this.signatureKey,
    this.height = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: height,
          color: Colors.white,
          child: SfSignaturePad(
            key: signatureKey,
            backgroundColor: Colors.transparent, // ← transparente
            strokeColor: Colors.black87,
            minimumStrokeWidth: 1.5,
            maximumStrokeWidth: 6.0,
          ),
        ),
      ),
    );
  }
}
