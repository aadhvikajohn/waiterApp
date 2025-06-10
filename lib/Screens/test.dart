import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';



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

class OrderController extends GetxController {
  var tables = List.generate(5, (index) => 'Table \${index + 1}').obs;
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
    loadOrders();
  }

  void loadOrders() {
    for (var table in tables) {
      final rawList = orderBox.get(table, defaultValue: []);
      if (rawList != null && rawList is List) {
        orders[table] = RxList<OrderItem>.from(rawList.cast<OrderItem>());
      } else {
        orders[table] = <OrderItem>[].obs;
      }
      orders[table]!.refresh();
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
    orderBox.put(table, []);
    billRequested.remove(table);
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
}
