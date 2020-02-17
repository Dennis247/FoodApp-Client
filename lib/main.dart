import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/helpers/custom_route.dart';
import 'package:provider_pattern/providers/auth.dart';
import 'package:provider_pattern/providers/cart.dart';
import 'package:provider_pattern/providers/category.dart';
import 'package:provider_pattern/providers/orders.dart';
import 'package:provider_pattern/providers/products.dart';
import 'package:provider_pattern/providers/user_profile.dart';
import 'package:provider_pattern/screens/auth/reset_password_screen.dart';
import 'package:provider_pattern/screens/auth_screen.dart';
import 'package:provider_pattern/screens/cart_screen.dart';
import 'package:provider_pattern/screens/category_screen.dart';
import 'package:provider_pattern/screens/edit_product_screen.dart';
import 'package:provider_pattern/screens/edit_profile_screen.dart';
import 'package:provider_pattern/screens/orders_screen.dart';
import 'package:provider_pattern/screens/product_details_screen.dart';
import 'package:provider_pattern/screens/products_overview.dart';
import 'package:provider_pattern/screens/profile_screen.dart';
import 'package:provider_pattern/screens/splash_screen.dart';
import 'package:provider_pattern/screens/user_product_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, UserProfileProvider>(
            create: (_) => UserProfileProvider([]),
            update: (_, Auth value, UserProfileProvider previousData) =>
                UserProfileProvider(previousData.userProfiles,
                    authToken: value.token, userId: value.userId),
          ),
          ChangeNotifierProxyProvider<Auth, CategoryProvider>(
            create: (_) => CategoryProvider([]),
            update: (_, Auth value, CategoryProvider previous) =>
                CategoryProvider(previous.categories,
                    authToken: value.token, userId: value.userId),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products([]),
            update: (_, Auth value, Products previous) => Products(
                previous.items,
                authToken: value.token,
                userId: value.userId),
          ),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders([]),
            update: (_, Auth value, Orders previous) => Orders(previous.orders,
                authToken: value.token, userId: value.userId),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, authData, _) {
            return MaterialApp(
                title: 'Butter Bread & Fish',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                    primaryColor: Constants.primaryColor,
                    accentColor: Colors.deepOrange,
                    fontFamily: 'Lato',
                    pageTransitionsTheme: PageTransitionsTheme(builders: {
                      TargetPlatform.iOS: CustomPageTransitionBuilder(),
                      TargetPlatform.android: CustomPageTransitionBuilder(),
                    })),
                home: authData.isAuth
                    ? ProductOverviewScreen()
                    : FutureBuilder(
                        future: authData.tryAutoLogin(),
                        builder: (ctx, authDataResultSnapShot) =>
                            authDataResultSnapShot.connectionState ==
                                    ConnectionState.waiting
                                ? SpalshScreen()
                                : AuthScreen(),
                      ),
                routes: {
                  ProductDetailsScreen.routeName: (context) =>
                      ProductDetailsScreen(),
                  CartScreen.routeName: (context) => CartScreen(),
                  OrdersScreen.routeName: (context) => OrdersScreen(),
                  UserProductScreen.routeName: (context) => UserProductScreen(),
                  EditProductScreen.routeName: (context) => EditProductScreen(),
                  AuthScreen.routeName: (context) => AuthScreen(),
                  ProductOverviewScreen.routeName: (context) =>
                      ProductOverviewScreen(),
                  CategoryPage.routeName: (context) => CategoryPage(),
                  ProfilePage.routeName: (context) => ProfilePage(),
                  ResetPasswordScreen.routeName: (context) =>
                      ResetPasswordScreen(),
                  EditProfileScreen.routeName: (context) => EditProfileScreen()
                });
          },
        ));
  }
}
