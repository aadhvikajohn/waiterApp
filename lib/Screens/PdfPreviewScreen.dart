import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tablebooking/Screens/OrderScreen.dart';

class PdfPreviewScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String tableName;
  const PdfPreviewScreen({super.key, required this.pdfBytes,  required this.tableName});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late PdfViewerController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    // Optional: Set zoom after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pdfController.zoomLevel = 1.0; // 150% zoom
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.roboto(

    );
    return Scaffold(
        backgroundColor:  Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Invoice for -${widget.tableName}',style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600,color:Colors.purple),),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon:  Icon(Icons.arrow_back,color:Colors.purple),
            onPressed: () {
              Get.offAll(() =>  OrderScreen(tableName:  widget.tableName,));

            },
          ),
          actions: [
            IconButton(
              icon:  Icon(Icons.share,color:Colors.purple),
              onPressed: () async {
                // Share PDF
                await Share.shareXFiles([
                  XFile.fromData(widget.pdfBytes, name: 'bill.pdf', mimeType: 'application/pdf'),
                ]);
              },
            ),
            IconButton(
              icon: const Icon(Icons.print,color:Colors.purple),
              onPressed: () async {
                await Printing.layoutPdf(
                  onLayout: (_) => widget.pdfBytes,
                );
              },
            ),
          ],
        ),
      body: SfPdfViewer.memory(

        widget.pdfBytes,
        controller: _pdfController,
        pageLayoutMode: PdfPageLayoutMode.single, // Ensures one page at a time
        canShowScrollHead: false,
        canShowScrollStatus: false,
        onDocumentLoaded: (details) {
          _pdfController.zoomLevel = 1.0; // Fit-to-width logic after load
        },
      )

    );
  }
}

