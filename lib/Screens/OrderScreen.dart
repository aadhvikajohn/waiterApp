import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tablebooking/Screens/tablebooking.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;

import '../Controller/orderController.dart';
import 'PdfPreviewScreen.dart';

class OrderScreen extends StatelessWidget {
  final String tableName;
  OrderScreen({super.key, required this.tableName});

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();
    final textStyle = GoogleFonts.roboto(

    );
    return SafeArea(child:
    Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(title: Text('Orders - $tableName',style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600,color:Colors.purple),),
          backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back,color:Colors.purple),
          onPressed: () {
          Get.offAll(() =>  TableListScreennew());
            controller.update(); // Also refresh when manually pressing back
            Get.back();
          },
        ),),
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            SizedBox.expand(
              child: Image.asset(
                'assets/bg.png', // Replace with your asset path
                fit: BoxFit.cover,
              ),
            ),

            // Opacity overlay
            Container(
              color: Colors.white54.withOpacity(0.9),
            ),

            // Foreground content
            Column(
              children: [
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: itemNameController,
                          decoration: InputDecoration(
                            labelText: 'Item Name',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Qty',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,size: 30, color:Colors.blue),
                        onPressed: () {
                          if (itemNameController.text.isNotEmpty &&
                              priceController.text.isNotEmpty) {
                            controller.addItem(
                              tableName,
                              OrderItem(
                                name: itemNameController.text,
                                quantity: int.tryParse(quantityController.text) ?? 1,
                                price: double.tryParse(priceController.text) ?? 0.0,
                              ),
                            );
                            itemNameController.clear();
                            quantityController.text = '1';
                            priceController.clear();
                          }
                        },
                      )
                    ],
                  ),

                ),
                // ... your existing Expanded (ListView) and button row remain unchanged ...
                Expanded(
                  child: Obx(() {
                    final items = controller.getOrder(tableName);
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        Color textColor;
                        switch (item.status) {
                          case 'Served':
                            textColor = Colors.grey;
                            break;
                          case 'Preparing':
                            textColor = Colors.orange;
                            break;
                          default:
                            textColor = Colors.black;
                        }

                        final textStyle = GoogleFonts.roboto(
                          color: textColor,
                        );

                        return Card(
                          color: Colors.white,
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item.name} x${item.quantity} @ ₹${item.price.toStringAsFixed(2)}',
                                            style: textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Total: ₹${(item.quantity * item.price).toStringAsFixed(2)}',
                                            style: textStyle,
                                          ),
                                          Text(
                                            'Status: ${item.status}',
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: item.status,
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.updateItemStatus(tableName, index, value);
                                        }
                                      },
                                      items: ['Pending', 'Preparing', 'Served']
                                          .map((status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(
                                          status,
                                          style: GoogleFonts.roboto(),
                                        ),
                                      ))
                                          .toList(),
                                    ),
                                    const SizedBox(width: 18),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: -10,
                                top: -60,
                                bottom: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                                  tooltip: 'Remove Item',
                                  onPressed: () {
                                    controller.orders[tableName]?.removeAt(index);
                                    controller.orders[tableName]?.refresh();
                                    controller.saveOrders();
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),


             /*   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          controller.requestBill(tableName);

                          final items = controller.getOrder(tableName);
                          final total = controller.getTotalBill(tableName);

                          print('Generating PDF...');
                          final pdfBytes = await generateBillPdf(tableName, items, total);

                          Get.to(() => PdfPreviewScreen(pdfBytes: pdfBytes));
                          print('PDF shared successfully.');
                        } catch (e) {
                          print('Error while generating/sharing PDF: $e');
                          Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },

                      icon: const Icon(Icons.receipt_long,color: Colors.white,size: 25,),
                      label: const Text('Generate Bill'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Background color for Generate Bill
                        foregroundColor: Colors.white, // Text and icon color
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.completeOrder(tableName);
                        Get.back();
                      },
                      icon: const Icon(Icons.check_circle,color: Colors.white,size: 25,),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color for Generate Bill
                        foregroundColor: Colors.white, // Text and icon color
                      ),
                    ),
                  ],
                ),*/

                Obx(() {
                  final allServed = controller.allItemsServed(tableName);
                  final itemsExist = controller.getOrder(tableName).isNotEmpty;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: (allServed && itemsExist)
                            ? () async {
                          // Generate bill
                          try {
                            controller.requestBill(tableName);
                            final items = controller.getOrder(tableName);
                            final total = controller.getTotalBill(tableName);
                            final pdfBytes = await generateBillPdf(tableName, items, total);
                            Get.to(() => PdfPreviewScreen(pdfBytes: pdfBytes,tableName: tableName));
                          } catch (e) {
                            Get.snackbar("Error", e.toString(),
                                backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        }
                            : null, // disabled if not all served or empty
                        icon:  Icon(Icons.receipt_long, size: 25,color: allServed ? Colors.white : Colors.grey,),
                        label:  Text('Generate Bill',style: TextStyle(color: allServed ? Colors.white : Colors.grey,),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: allServed ? Colors.blue : Colors.grey,
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: allServed
                            ? () {
                          controller.completeOrder(tableName);
                          Get.back();
                        }
                            : null,
                        icon:  Icon(Icons.check_circle,color: allServed ? Colors.white : Colors.grey,size: 25,),
                        label:  Text('Complete',style: TextStyle(color: allServed ? Colors.white : Colors.grey,),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: allServed ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  );
                })


              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        //  height: 150,
        // width: 300,
        color: Colors.purple.shade500,
        //alignment: Alignment.bottomCenter,
          child:
      Obx(() {
        final total = controller.getTotalBill(controller.tables.firstWhereOrNull((table) => controller.orders[table]?.isNotEmpty ?? false) ?? '');
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Bill: ₹${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      })),


    ));
  }



  /*Future<Uint8List> generateBillPdf(String tableName, List<OrderItem> items, double total) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Bill for $tableName', style: pw.TextStyle(font: font, fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return pw.Text('${item.name} x${item.quantity} - ₹${(item.quantity * item.price).toStringAsFixed(2)}', style: pw.TextStyle(font: font));
              },
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total: ₹${total.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 18)),
          ],
        ),
      ),
    );

    return await pdf.save();
  }
*/
  Future<Uint8List> generateBillPdf(String tableName, List<OrderItem> items, double total) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Astroblack Technologies ', style: pw.TextStyle(font: font, fontSize: 20)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [

                      pw.Text(' Waiter Name:John David ', style: pw.TextStyle(font: font)),
                      pw.Text(' Second Floor, Lakshmi complex, 85', style: pw.TextStyle(font: font)),
                      pw.Text('Kunju Mariamman, Tiruchengode,', style: pw.TextStyle(font: font)),
                      pw.Text('Tiruchengode, Tamil Nadu, 637211', style: pw.TextStyle(font: font)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Invoice Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice For:', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                      pw.Text('M.Saranya', style: pw.TextStyle(font: font)),
                      pw.Text('9944118627', style: pw.TextStyle(font: font)),
                    //  pw.Text('Address Line 2', style: pw.TextStyle(font: font)),
                    //  pw.Text('City, State, Zip Code', style: pw.TextStyle(font: font)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice ID: 123456', style: pw.TextStyle(font: font)),
                      pw.Text('Issue Date: $formattedDate', style: pw.TextStyle(font: font)),
                      pw.Text('PO Number: PO7890', style: pw.TextStyle(font: font)),
                      pw.Text('Inv Date: $formattedDate', style: pw.TextStyle(font: font)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Subject
              pw.Text('Subject', style: pw.TextStyle(font: font, fontSize: 16)),
              pw.SizedBox(height: 10),

              // Table Header
              pw.Table.fromTextArray(
                headers: ['Description', 'Quantity', 'Unit Price', 'Amount'],
                data: items.map((item) {
                  return [
                    item.name,
                    item.quantity.toString(),
                    item.price.toStringAsFixed(2),
                    (item.quantity * item.price).toStringAsFixed(2),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: font),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                border: pw.TableBorder.all(),
              ),
              pw.SizedBox(height: 10),

              // Subtotal and Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Subtotal: ₹${total.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
                      pw.Text('Discount (0.25 = 25%): 0%', style: pw.TextStyle(font: font)),
                      pw.SizedBox(height: 5),
                      pw.Text('Net Amount: ₹${total.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text('Notes', style: pw.TextStyle(font: font, fontSize: 14)),
              pw.Text('Your satisfaction is our success!', style: pw.TextStyle(font: font)),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  Future<void> generateAndShareBillPdf(String tableName, List<OrderItem> items, double totalAmount) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Restaurant Bill', style: pw.TextStyle(fontSize: 24, font: ttf, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Table: $tableName\nDate: ${DateTime.now()}', style: pw.TextStyle(font: ttf)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              cellStyle: pw.TextStyle(font: ttf),
              headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
              data: <List<String>>[
                ['Item', 'Qty', 'Price', 'Status', 'Total'],
                ...items.map((item) => [
                  item.name,
                  '${item.quantity}',
                  '₹${item.price.toStringAsFixed(2)}',
                  item.status,
                  '₹${(item.quantity * item.price).toStringAsFixed(2)}'
                ])
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: ₹${totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 18, font: ttf, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );


    final output = await getTemporaryDirectory();
    final file = File("${output.path}/bill_$tableName.pdf");
    await file.writeAsBytes(await pdf.save());

    // Share via WhatsApp or any available apps
    //await Share.shareXFiles([XFile(file.path)], text: 'Here is your bill for $tableName');
  }

}

/*   ElevatedButton(
                      onPressed: () {
                        final summary = controller.getOrder(tableName)
                            .map((item) => '${item.name} x${item.quantity} - ${item.status}')
                            .join('\n');
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Order'),
                            content: Text(summary),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  final summary = controller.getOrder(tableName)
                                      .map((item) =>
                                  '${item.name} x${item.quantity} @ ₹${item.price.toStringAsFixed(2)} - ${item.status}')
                                      .join('\n');
                                  final total = controller.getTotalBill(tableName);
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Order Summary'),
                                      content: Text('$summary\n\nTotal: ₹${total.toStringAsFixed(2)}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Close'),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Close'),
                              )
                            ],
                          ),
                        );
                      },
                      child: const Text('View'),
                    ),*/