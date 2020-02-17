import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/providers/auth.dart';
import 'package:provider_pattern/providers/cart.dart';
import 'package:provider_pattern/providers/orders.dart';
import 'package:provider_pattern/screens/cart_screen.dart';
import 'package:provider_pattern/widgets/app_drawer.dart';
import 'package:provider_pattern/widgets/badge.dart';
import 'package:provider_pattern/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // var orderContainer = Provider.of<Orders>(context);
    final authData = Provider.of<Auth>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text("My Orders"),
          centerTitle: true,
          actions: <Widget>[
            Consumer<Cart>(
              builder: (_, cart, ch) => Badge(
                child: ch,
                value: cart.itemCount.toString(),
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, CartScreen.routeName);
                },
              ),
            )
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false)
              .fetchOrders(authData.token),
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapShot.error != null) {
                return Center(
                  child: Text("An Error has Occured"),
                );
              } else {
                return Consumer<Orders>(
                    builder: (ctx, orderData, child) => orderData
                                .orders.length >
                            0
                        ? ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return OrderItemWidget(orderData.orders[index]);
                            },
                            itemCount: orderData.orders.length,
                          )
                        : Center(
                            child: Text("You Currently do not have any Orders"),
                          ));
              }
            }
          },
        ));
  }
}
