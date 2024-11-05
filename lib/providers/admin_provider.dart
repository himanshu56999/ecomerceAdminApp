import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/db_service.dart';

class AdminProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot<Object?>> categories = [];
  StreamSubscription<QuerySnapshot<Object?>>? _categorySubscription;

  List<QueryDocumentSnapshot<Object?>> products = [];
  StreamSubscription<QuerySnapshot<Object?>>? _productsSubscription;

  List<QueryDocumentSnapshot<Object?>> orders = [];
  StreamSubscription<QuerySnapshot<Object?>>? _ordersSubscription;

  int totalCategories = 0;
  int totalProducts = 0;
  int totalOrders = 0;
  int ordersDelivered = 0;
  int ordersCancelled = 0;
  int ordersOnTheWay = 0;
  int orderPendingProcess = 0;

  AdminProvider() {
    // Fetch data when the provider is instantiated
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getCategories();
    await getProducts();
    await readOrders();
  }

  // GET all the categories
  Future<void> getCategories() async {
    _categorySubscription?.cancel(); // Cancel any existing subscription
    _categorySubscription = DbService().readCategories().listen(
          (snapshot) {
        categories = snapshot.docs;
        totalCategories = snapshot.docs.length;
        notifyListeners(); // Notify listeners for UI update
      },
      onError: (error) {
        print("Error fetching categories: $error");
      },
    );
  }

  // GET all the products
  Future<void> getProducts() async {
    _productsSubscription?.cancel(); // Cancel any existing subscription
    _productsSubscription = DbService().readProducts().listen(
          (snapshot) {
        products = snapshot.docs;
        totalProducts = snapshot.docs.length;
        notifyListeners(); // Notify listeners for UI update
      },
      onError: (error) {
        print("Error fetching products: $error");
      },
    );
  }

  // Read all the orders
  Future<void> readOrders() async {
    _ordersSubscription?.cancel(); // Cancel any existing subscription
    _ordersSubscription = DbService().readOrders().listen(
          (snapshot) {
        orders = snapshot.docs;
        totalOrders = snapshot.docs.length;
        setOrderStatusCount();
        notifyListeners(); // Notify listeners for UI update
      },
      onError: (error) {
        print("Error fetching orders: $error");
      },
    );
  }

  // To set the various order types
  void setOrderStatusCount() {
    ordersDelivered = 0;
    ordersCancelled = 0;
    ordersOnTheWay = 0;
    orderPendingProcess = 0;

    for (var order in orders) {
      switch (order["status"]) {
        case "DELIVERED":
          ordersDelivered++;
          break;
        case "CANCELLED":
          ordersCancelled++;
          break;
        case "ON_THE_WAY":
          ordersOnTheWay++;
          break;
        default:
          orderPendingProcess++;
          break;
      }
    }
    notifyListeners(); // Notify listeners for UI update
  }

  // Cancel all subscriptions
  void cancelProvider() {
    _ordersSubscription?.cancel();
    _productsSubscription?.cancel();
    _categorySubscription?.cancel();
  }

  @override
  void dispose() {
    cancelProvider();
    super.dispose();
  }
}
