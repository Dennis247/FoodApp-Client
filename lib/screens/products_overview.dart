import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/providers/auth.dart';
import 'package:provider_pattern/providers/cart.dart';
import 'package:provider_pattern/providers/category.dart';
import 'package:provider_pattern/providers/products.dart';
import 'package:provider_pattern/screens/cart_screen.dart';
import 'package:provider_pattern/screens/category_screen.dart';
import 'package:provider_pattern/widgets/app_drawer.dart';
import 'package:provider_pattern/widgets/badge.dart';
import 'package:provider_pattern/widgets/category_item.dart';

import 'package:provider_pattern/widgets/product_item.dart';

enum FilteredOptions { favourites, all }

class ProductOverviewScreen extends StatefulWidget {
  static final String routeName = "/product-overview-screen";
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
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
          elevation: 6.0,
          title: Text(
            "BUTTER FISH & BREAD",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Favourite",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        FlatButton(
                          child: Consumer<Products>(
                              builder: (ctx, productData, child) => Text(
                                    "See all food items ${productData.items.length}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).accentColor,
                                    ),
                                  )),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryPage(
                                    category: Category(name: "All FOOD ITEMS"),
                                    isallCategories: true,
                                  ),
                                ));
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0),

                    //Horizontal List here
                    Container(
                        height: MediaQuery.of(context).size.height / 2.4,
                        width: MediaQuery.of(context).size.width,
                        child: FutureBuilder(
                          future: Provider.of<Products>(context, listen: false)
                              .getProducts(),
                          builder: (ctx, dataSnapShot) {
                            if (dataSnapShot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              if (dataSnapShot.error != null) {
                                return Center(
                                  child: Text("An Error has Occured"),
                                );
                              } else {
                                return Consumer<Products>(
                                    builder: (ctx, pdoductData, child) =>
                                        pdoductData.items.length > 0
                                            ? ListView.builder(
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    pdoductData.items.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return ProductItem(
                                                      pdoductData.items[index]);
                                                })
                                            : Center(
                                                child: Text(
                                                    "You Currently do not have any Orders"),
                                              ));
                              }
                            }
                          },
                        )),

                    SizedBox(height: 30.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Category",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0),

                    Container(
                        height: MediaQuery.of(context).size.height / 6,
                        child: FutureBuilder(
                          future: Provider.of<CategoryProvider>(context,
                                  listen: false)
                              .getCategories(),
                          builder: (ctx, dataSnapShot) {
                            if (dataSnapShot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              if (dataSnapShot.error != null) {
                                return Center(
                                  child: Text("An Error has Occured"),
                                );
                              } else {
                                return Consumer<CategoryProvider>(
                                    builder: (ctx, categoryData, child) =>
                                        categoryData.categories.length > 0
                                            ? ListView.builder(
                                                primary: false,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: categoryData
                                                    .categories.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return CategoryItem(
                                                      categoryData
                                                          .categories[index]);
                                                },
                                              )
                                            : Center(
                                                child: Text(
                                                    "You Currently do not have any Orders"),
                                              ));
                              }
                            }
                          },
                        )),

                    // SizedBox(height: 20.0),
                  ],
                ),
              ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // final productsContainer = Provider.of<Products>(context);
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: Text("TEA TARTS AND TINGS"),
  //         actions: <Widget>[
  //           PopupMenuButton(
  //             onSelected: (FilteredOptions selectedvalue) {
  //               setState(() {
  //                 if (selectedvalue == FilteredOptions.favourites) {
  //                   //   productsContainer.showFavourites();
  //                   _showOnlyFavourite = true;
  //                 } else {
  //                   //    productsContainer.showAll();
  //                   _showOnlyFavourite = false;
  //                 }
  //                 print(selectedvalue);
  //               });
  //             },
  //             icon: Icon(Icons.more_vert),
  //             itemBuilder: (_) => [
  //               PopupMenuItem(
  //                 child: Text('Only Favourites'),
  //                 value: FilteredOptions.favourites,
  //               ),
  //               PopupMenuItem(
  //                 child: Text('Show All'),
  //                 value: FilteredOptions.all,
  //               ),
  //             ],
  //           ),
  //           Consumer<Cart>(
  //             builder: (_, cart, ch) => Badge(
  //               child: ch,
  //               value: cart.itemCount.toString(),
  //             ),
  //             child: IconButton(
  //               icon: Icon(Icons.shopping_cart),
  //               onPressed: () {
  //                 Navigator.pushNamed(context, CartScreen.routeName);
  //               },
  //             ),
  //           )
  //         ],
  //       ),
  //       drawer: AppDrawer(),
  //       body: _isLoading
  //           ? Center(
  //               child: CircularProgressIndicator(),
  //             )
  //           : ProductGrid(_showOnlyFavourite));
  // }
}
