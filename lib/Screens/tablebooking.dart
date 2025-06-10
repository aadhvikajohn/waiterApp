import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


import '../Controller/orderController.dart';
import 'OrderScreen.dart';

class TableListScreennew extends StatelessWidget {
  const TableListScreennew({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();
    final TextStyle textStyle = GoogleFonts.roboto();

    return Scaffold(
     // backgroundColor:  Color(0xffffffff),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png', // Your logo path
              height: 30, // Adjust as needed
            ),
            const SizedBox(width: 4),
            Text(
              'Dine-In Tables',
              style: textStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon:  Icon(Icons.exit_to_app,color:Colors.purple),
          onPressed: () {
            Get.offAll(() =>  TableListScreennew());
            controller.update(); // Also refresh when manually pressing back
            Get.back();
          },
        ),
        centerTitle: false,
        elevation: 0,
      ),

      body: CustomScrollView(
        slivers: [
          // Top banner
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: Colors.orange[50],
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: const Row(
                children: [
                  Icon(Icons.table_bar, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    "Spot free tables in a flash!",
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),

          // Spacing
          SliverToBoxAdapter(
            child: const SizedBox(height: 12),
          ),

          // Grid of tables
          Obx(() {
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final table = controller.tables[index];
                    final isOccupied = controller.hasActiveOrder(table);
                    final billRequested = controller.billRequested[table] ?? false;

                    return GestureDetector(
                      onTap: () {
                        if (!controller.orders.containsKey(table)) {
                          controller.orders[table] = <OrderItem>[].obs;
                        }
                        Get.offAll(() => OrderScreen(tableName: table))!
                            .then((_) => controller.update());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: billRequested
                              ? Colors.orange
                              : isOccupied
                              ? Colors.red[300]
                              : Colors.green[300],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.table_bar, size: 38, color: Colors.white),
                            const SizedBox(height: 12),
                            Text(
                              table,
                              style: textStyle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              billRequested
                                  ? 'Bill Requested'
                                  : isOccupied
                                  ? 'Occupied'
                                  : 'Free',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (isOccupied)
                              Obx(() => Text(
                                '⏱ ${controller.getElapsedTimeRx(table)?.value ?? '00:00'}',
                                style:
                                const TextStyle(color: Colors.white, fontSize: 14),
                              )),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: controller.tables.length,
                ),
              ),
            );
          }),
        ],
      ),


    );
  }
}