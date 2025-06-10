import 'dart:async';

import 'package:get/get.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/*class OrderController extends GetxController {
  var tables = List.generate(8, (index) => 'Table ${index + 1}').obs;
  var orders = <String, RxList<OrderItem>>{}.obs;
  RxMap<String, bool> billRequested = <String, bool>{}.obs;

  final Box<List> orderBox = Hive.box<List>('orders');

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }
  @override
  void onReady() {
    super.onReady();
    loadOrders();  // Call the doLogin method again to fetch data when the controller is ready
    //  update();  // Update the UI with the new data
  }

  void loadOrders() {
    for (var table in tables) {
      final rawList = orderBox.get(table, defaultValue: []);
      if (rawList != null && rawList is List) {
        orders[table] = RxList<OrderItem>.from(rawList.cast<OrderItem>());
      } else {
        orders[table] = <OrderItem>[].obs;
      }
      orders[table]!.refresh(); // Ensure UI reflects status
    }
  }


  void saveOrders() {
    for (var entry in orders.entries) {
      orderBox.put(entry.key, entry.value);
    }
  }

  bool hasActiveOrder(String table) => orders[table]?.isNotEmpty ?? false;

  void addItem(String table, OrderItem item) {
    if (!orders.containsKey(table)) {
      orders[table] = <OrderItem>[].obs;
    }

    final existingIndex = orders[table]!.indexWhere((e) => e.name == item.name);
    if (existingIndex != -1) {
      orders[table]![existingIndex].quantity += item.quantity;
    } else {
      orders[table]!.add(item);
    }

    orders[table]!.refresh();
    saveOrders();
  }

  void updateItemStatus(String table, int index, String status) {
    orders[table]![index].status = status;
    orders[table]!.refresh();
    saveOrders();
  }

  void completeOrder(String table) {
    orders[table]?.clear();
    orderBox.put(table, []); // Persist clear state
    billRequested.remove(table);
    orders[table]?.refresh();
    update(); // Force TableListScreen to rebuild immediately
  }



  void requestBill(String table) {
    billRequested[table] = true;
    update();
  }
  double getTotalBill(String table) {
    return orders[table]?.fold(0, (sum, item) => sum! + (item.quantity * item.price)) ?? 0.0;
  }
  List<OrderItem> getOrder(String table) => orders[table]?.toList() ?? [];
}*/
class OrderController extends GetxController {
  var tables = List.generate(8, (index) => 'Table ${index + 1}').obs;
  var orders = <String, RxList<OrderItem>>{}.obs;
  RxMap<String, bool> billRequested = <String, bool>{}.obs;
  RxMap<String, DateTime> occupiedSince = <String, DateTime>{}.obs;
  RxMap<String, RxString> tableTimers = <String, RxString>{}.obs;

  final Box<List> orderBox = Hive.box<List>('orders');
  final Box<String> occupiedTimeBox = Hive.box<String>('occupied_times');



  RxString? getElapsedTimeRx(String table) => tableTimers[table];

  @override
  void onInit() {
    super.onInit();
    loadOccupiedTimes();  // ← restore saved start times
    loadOrders();         // ← load orders without touching saved times
    updateTimers();

    Timer.periodic(const Duration(seconds: 1), (_) {
     // print('⏱ updateTimers() fired at ${DateTime.now()}');  // <— add this
      updateTimers();
    });
  }

  void loadOccupiedTimes() {
    for (var table in tables) {
      final saved = occupiedTimeBox.get(table);
      if (saved != null) {
        occupiedSince[table] = DateTime.parse(saved);
        tableTimers[table] = '00:00'.obs;  // just create the RxString
      }
    }
  }



  void loadOrders() {
    for (var table in tables) {
      final rawList = orderBox.get(table, defaultValue: []);
      orders[table] = RxList<OrderItem>.from(
          (rawList is List) ? rawList.cast<OrderItem>() : []
      );

      // 🔍 Only auto-mark occupied if there is an order *and* no saved time in Hive
      if (orders[table]!.isNotEmpty && !occupiedTimeBox.containsKey(table)) {
        final now = DateTime.now();
        occupiedSince[table] = now;
        occupiedTimeBox.put(table, now.toIso8601String());
        tableTimers[table] = '00:00'.obs;
        updateTimers();
      }

      orders[table]!.refresh();
    }
  }


  void updateTimers() {
    occupiedSince.forEach((table, startTime) {
      final duration = DateTime.now().difference(startTime);
      final minutes = duration.inMinutes.toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      final formatted = '$minutes:$seconds';

      if (!tableTimers.containsKey(table)) {
        tableTimers[table] = formatted.obs;
      } else {
        tableTimers[table]!.value = formatted;
      }
    });
  }

  void saveOrders() {
    for (var entry in orders.entries) {
      orderBox.put(entry.key, entry.value);
    }
  }
  bool allItemsServed(String table) {
    final items = orders[table];
    if (items == null || items.isEmpty) return false;
    return items.every((item) => item.status == 'Served');
  }

  bool hasActiveOrder(String table) => orders[table]?.isNotEmpty ?? false;

  void addItem(String table, OrderItem item) {
    if (!orders.containsKey(table)) {
      orders[table] = <OrderItem>[].obs;
    }

    final existingIndex = orders[table]!.indexWhere((e) => e.name == item.name);
    if (existingIndex != -1) {
      orders[table]![existingIndex].quantity += item.quantity;
    } else {
      orders[table]!.add(item);
    }

    // ✅ Save initial time if table is newly occupied
    if (!occupiedSince.containsKey(table)) {
      final now = DateTime.now();
      occupiedSince[table] = now;
      occupiedTimeBox.put(table, now.toIso8601String()); // <-- SAVE here
      tableTimers[table] = '00:00'.obs;
      updateTimers();
    }

    orders[table]!.refresh();
    saveOrders();
  }


  void updateItemStatus(String table, int index, String status) {
    orders[table]![index].status = status;
    orders[table]!.refresh();
    saveOrders();
  }

  void completeOrder(String table) {
    orders[table]?.clear();
    orderBox.put(table, []);
    billRequested.remove(table);
    occupiedSince.remove(table);
    occupiedTimeBox.delete(table);
    tableTimers.remove(table);
    orders[table]?.refresh();
    update();
  }

  void requestBill(String table) {
    billRequested[table] = true;
    update();
  }

  double getTotalBill(String table) {
    return orders[table]?.fold(0, (sum, item) => sum! + (item.quantity * item.price)) ?? 0.0;
  }

  List<OrderItem> getOrder(String table) => orders[table]?.toList() ?? [];

  /// Returns elapsed time in mm:ss (just for legacy or other use)
  String getElapsedTime(String table) {
    final start = occupiedSince[table];
    if (start == null) return '';
    final duration = DateTime.now().difference(start);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}



@HiveType(typeId: 0)
class OrderItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  String status;

  @HiveField(3)
  double price;

  OrderItem({required this.name, this.quantity = 1, this.status = 'Pending', required this.price});
}

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final typeId = 0;

  @override
  OrderItem read(BinaryReader reader) {
    return OrderItem(
      name: reader.readString(),
      quantity: reader.readInt(),
      status: reader.readString(),
      price: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.quantity);
    writer.writeString(obj.status);
    writer.writeDouble(obj.price);
  }
}

/*
@HiveType(typeId: 0)
class OrderItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  String status;

  OrderItem({required this.name, this.quantity = 1, this.status = 'Pending'});
}

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final typeId = 0;

  @override
  OrderItem read(BinaryReader reader) {
    return OrderItem(
      name: reader.readString(),
      quantity: reader.readInt(),
      status: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.quantity);
    writer.writeString(obj.status);
  }
}*/
