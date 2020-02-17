import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/models/http_exception.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories {
    return [..._categories];
  }

  final String authToken;
  final String userId;

  CategoryProvider(this._categories, {this.authToken, this.userId});

  Future<void> getCategories() async {
    List<Category> loadCategories = [];

    try {
      final response = await http.get(
          Constants.firebaseUrl  + "/categories.json?auth=$authToken");
      final extractedCatgories =
          json.decode(response.body) as Map<String, dynamic>;
      if (extractedCatgories != null) {
        extractedCatgories.forEach((categoryId, categoryData) {
          loadCategories.add(Category(
              id: categoryId,
              image: categoryData['image'],
              name: categoryData['name'],
              addedBy: categoryData['addedBy']));
        });
      }
      _categories = loadCategories.toList();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final response = await http.post(
          Constants.firebaseUrl  + "/categories.json?auth=$authToken",
          body: json.encode({
            'name': category.name,
            'image': category.image,
            'addedBy': userId,
          }));

      final newCategory = Category(
        id: json.decode(response.body)['name'],
        addedBy: category.addedBy,
        image: category.image,
        name: category.name,
      );

      _categories.add(newCategory);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateCategory(String categoryId, Category newCategory) async {
    final _updatebaseUrl =
        Constants.firebaseUrl  + "/categories/$categoryId.json?auth=$authToken";

    final int categoryIndex =
        _categories.indexWhere((cat) => cat.id == categoryId);
    if (categoryIndex >= 0) {
      try {
        await http.patch(_updatebaseUrl,
            body: json.encode({
              'name': newCategory.name,
              'image': newCategory.image,
              'addedBy': newCategory.addedBy,
            }));
      } catch (error) {
        print(error);
      }
      _categories[categoryIndex] = newCategory;
      notifyListeners();
    } else {
      print('newCategory update for $categoryId failed');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final url =
        Constants.firebaseUrl  + "/categories/$categoryId.json?auth=$authToken";
    ;
    Category existingCategory;
    int existingCategoryIndex =
        _categories.indexWhere((cat) => cat.id == categoryId);
    if (existingCategoryIndex >= 0) {
      existingCategory = _categories[existingCategoryIndex];
      _categories.removeAt(existingCategoryIndex);
      notifyListeners();

      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _categories.insert(existingCategoryIndex, existingCategory);
        notifyListeners();
        throw HttpException('product could not be deleted');
      } else {
        existingCategory = null;
      }
    }
  }
}

class Category with ChangeNotifier {
  final String id;
  final String name;
  final String image;
  final String addedBy;

  Category(
      {@required this.id,
      @required this.name,
      @required this.image,
      @required this.addedBy});
}
