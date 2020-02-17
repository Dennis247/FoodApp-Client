import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/helpers/custom_route.dart';
import 'package:provider_pattern/providers/auth.dart';
import 'package:provider_pattern/screens/orders_screen.dart';
import 'package:provider_pattern/screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(""),
            accountEmail: Text(
              authData.email != null ? authData.email : "",
            ),
            currentAccountPicture: new CircleAvatar(
              backgroundImage: new AssetImage(Constants.logoUrl),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            title: Text("Home"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
              leading: Icon(
                Icons.payment,
                color: Colors.green,
              ),
              title: Text(
                "My Orders",
              ),
              onTap: () {
                // Navigator.of(context)
                //     .pushReplacementNamed(OrdersScreen.routeName);
                Navigator.of(context).pushReplacement(
                    CustomRoute(builder: (ctx) => OrdersScreen()));
              }),
          Divider(),
          ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Colors.purple,
              ),
              title: Text(
                "My Profile",
              ),
              onTap: () {
                // Navigator.of(context)
                //     .pushReplacementNamed(OrdersScreen.routeName);
                Navigator.of(context).pushReplacement(
                    CustomRoute(builder: (ctx) => ProfilePage()));
              }),
          // Divider(),
          // ListTile(
          //     leading: Icon(Icons.edit),
          //     title: Text("Manage Product"),
          //     onTap: () {
          //       Navigator.of(context)
          //           .pushReplacementNamed(UserProductScreen.routeName);
          //     }),
          Divider(),
          ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              title: Text("Log Out"),
              onTap: () {
                //
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Auth>(context, listen: false).logout();
              }),
        ],
      ),
    );
  }
}
