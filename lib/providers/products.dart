import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/models/http_exception.dart';
import 'package:provider_pattern/providers/product.dart';

class Products with ChangeNotifier {
  bool showFavouritesOnly = false;

  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this._items, {this.authToken, this.userId});

  final _baseUrl = Constants.firebaseUrl + "/products.json";

  List<Product> get items {
    return [..._items];
  }

  Future<void> getProducts() async {
    try {
      final String url =
          Constants.firebaseUrl + '/products.json?auth=$authToken';
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, product) {
        loadedProducts.add(Product(
            id: prodId,
            description: product['description'],
            imageUrl: product['imageUrl'],
            price: product['price'],
            title: product['title'],
            categoryId: product['categoryId'],
            isFavourite: true
            //  isFavourite: product['isFavourite']
            ));
      });
      _items = loadedProducts;
      notifyListeners();
      //   print(json.decode(response.body));
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(_baseUrl + "?auth=$authToken",
          body: json.encode({
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'title': product.title,
            'isFavourite': product.isFavourite,
            'creatorId': userId
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          title: product.title,
          isFavourite: product.isFavourite);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateproduct(String productId, Product newProduct) async {
    final _updatebaseUrl =
        Constants.firebaseUrl + "/products/$productId.json?auth=$authToken";

    final int productIndex =
        _items.indexWhere((product) => product.id == productId);
    if (productIndex >= 0) {
      try {
        await http.patch(_updatebaseUrl,
            body: json.encode({
              'price': newProduct.price,
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl
            }));
      } catch (error) {
        print(error);
      }
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('product update for $productId failed');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url = Constants.firebaseUrl + "/products.json?auth=$authToken";
    Product existingProduct;
    int existingProductIndex =
        _items.indexWhere((product) => product.id == productId);
    if (existingProductIndex >= 0) {
      existingProduct = _items[existingProductIndex];
      _items.removeAt(existingProductIndex);
      notifyListeners();

      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('product could not be deleted');
      } else {
        existingProduct = null;
      }
    }
  }

  Product getProduct(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void showFavourites() {
    showFavouritesOnly = true;
    notifyListeners();
  }

  void showAll() {
    showFavouritesOnly = false;
    notifyListeners();
  }
}
