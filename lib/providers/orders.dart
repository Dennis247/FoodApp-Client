import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem with ChangeNotifier {
  final String id;
  final String amount;
  final List<CartItem> products;
  final String status;
  final String userId;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.status,
      @required this.userId,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  final String authToken;
  final String userId;

  Orders(this._orders, {this.authToken, this.userId});

  Future<void> fetchOrders(String authToken) async {
    _orders.clear();
    List<OrderItem> loadedOrders = [];

    try {
      final response = await http
          .get(Constants.firebaseUrl + "/orders/$userId.json?auth=$authToken");
      final extractedOrders =
          json.decode(response.body) as Map<String, dynamic>;
      if (extractedOrders != null) {
        extractedOrders.forEach((orderedId, orderData) {
          loadedOrders.add(OrderItem(
              id: orderedId,
              amount: orderData['amount'].toString(),
              userId: userId,
              status: orderData['status'],
              dateTime: DateTime.parse(orderData['dateTime']),
              products: (orderData['products'] as List<dynamic>)
                  .map((item) => CartItem(
                      id: item['id'],
                      price: double.parse(item['price']),
                      quantity: int.parse(item['quantity']),
                      title: item['title'],
                      imgUrl: item['imgUrl'],
                      productId: item['title']))
                  .toList()));
        });
        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addOrder(
      List<CartItem> cartItems, double amount, String authToken) async {
    final _baseUrl =
        Constants.firebaseUrl + "/orders/$userId.json?auth=$authToken";
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(_baseUrl,
          body: json.encode({
            'amount': amount,
            'dateTime': timeStamp.toIso8601String(),
            'status': Constants.pendingStatus,
            'userId': userId,
            'products': cartItems
                .map((ct) => {
                      'id': ct.id,
                      'productId': ct.productId,
                      'title': ct.title,
                      'quantity': ct.quantity.toString(),
                      'price': ct.price.toString()
                    })
                .toList()
          }));

      await http.post(Constants.firebaseUrl + "/allorders.json?auth=$authToken",
          body: json.encode({
            'amount': amount,
            'dateTime': timeStamp.toIso8601String(),
            'status': Constants.pendingStatus,
            'userId': userId,
            'products': cartItems
                .map((ct) => {
                      'id': ct.id,
                      'productId': ct.productId,
                      'title': ct.title,
                      'quantity': ct.quantity.toString(),
                      'price': ct.price.toString()
                    })
                .toList()
          }));

//post all orders combined

      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: amount.toString(),
              userId: userId,
              dateTime: timeStamp,
              status: Constants.pendingStatus,
              products: cartItems));
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderItem orderItem) async {
    final _updatebaseUrl =
        Constants.firebaseUrl + "/orders/$orderId.json?auth=$authToken";

    final int orderIndex = _orders.indexWhere((ord) => ord.id == orderId);
    if (orderIndex >= 0) {
      try {
        await http.patch(_updatebaseUrl,
            body: json.encode({
              'status': orderItem.status,
            }));
      } catch (error) {
        print(error);
      }
      _orders[orderIndex] = orderItem;
      notifyListeners();
    } else {
      print('order  update for ${orderItem.id} failed');
    }
  }
}
