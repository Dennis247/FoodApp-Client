import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/providers/product.dart';
import 'package:provider_pattern/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = "/edit-product";
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final FocusNode _imageUrlFocusNode = FocusNode();
  final _fromKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInit = true;
  Product _initValue = new Product(
    id: null,
    description: '',
    title: '',
    imageUrl: '',
    price: 0,
  );
  var _editProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _editProduct = ModalRoute.of(context).settings.arguments as Product;
      if (_editProduct != null) {
        _initValue = _editProduct;
        _imageUrlController.text = _editProduct.imageUrl;
      } else {
        _editProduct = _initValue;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          !_imageUrlController.text.startsWith('http')) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> _saveProduct() async {
    bool isValid = _fromKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _fromKey.currentState.save();

    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text("Something went wrong"),
                content: Text(error.toString()),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      } finally {
        // setState(() {
        //   _isLoading = false;
        // });
        // Navigator.of(context).pop();
      }
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateproduct(_editProduct.id, _editProduct);
      // setState(() {
      //   _isLoading = false;
      // });
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pushNamed(context, "/"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProduct,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                autovalidate: true,
                key: _fromKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValue.title,
                      decoration: InputDecoration(
                        labelText: "Title",
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: value,
                            description: _editProduct.description,
                            imageUrl: _editProduct.imageUrl,
                            price: _editProduct.price,
                            isFavourite: _editProduct.isFavourite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue.price.toString(),
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: _editProduct.description,
                            imageUrl: _editProduct.imageUrl,
                            price: double.parse(value),
                            isFavourite: _editProduct.isFavourite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'price cannot be empty';
                        }
                        if (double.tryParse(value) == null) {
                          return 'please neter a valid price';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue.description,
                      decoration: InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            description: value,
                            imageUrl: _editProduct.imageUrl,
                            price: _editProduct.price,
                            isFavourite: _editProduct.isFavourite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'product description cannot be empty';
                        }
                        if (value.length < 5) {
                          return 'product description is too short';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter a Url")
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            //   initialValue: _initValue.imageUrl,
                            decoration: InputDecoration(labelText: 'Image Url'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) => _saveProduct,
                            onSaved: (value) {
                              _editProduct = Product(
                                  id: _editProduct.id,
                                  title: _editProduct.title,
                                  description: _editProduct.description,
                                  imageUrl: value,
                                  price: _editProduct.price,
                                  isFavourite: _editProduct.isFavourite);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'image Url Cannot be empty';
                              }
                              if (!value.startsWith('http')) {
                                return 'enter a valid url';
                              }

                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
