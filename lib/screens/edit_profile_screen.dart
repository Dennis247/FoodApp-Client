import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/providers/auth.dart';
import 'package:provider_pattern/providers/product.dart';
import 'package:provider_pattern/providers/products.dart';
import 'package:provider_pattern/providers/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = "/edit-profile";
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocustNode = FocusNode();

  final _fromKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInit = true;
  UserProfile _initValue = new UserProfile(
      address: "", phoneNumber: "", email: "", userId: "", id: "");
  var _editProfile = UserProfile(
      address: null, email: null, phoneNumber: null, userId: null, id: null);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _editProfile = ModalRoute.of(context).settings.arguments as UserProfile;
      if (_editProfile != null) {
        _initValue = _editProfile;
      } else {
        _editProfile = _initValue;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
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
    if (_editProfile.userId == null) {
      try {
        // await Provider.of<Auth>(context, listen: false).

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
      await Provider.of<Auth>(context, listen: false)
          .updateUserProfile(_editProfile);
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
    _phoneFocusNode.dispose();
    _addressFocustNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
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
                      initialValue: _initValue.phoneNumber,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_phoneFocusNode);
                      },
                      onSaved: (value) {
                        _editProfile = UserProfile(
                            address: _editProfile.address,
                            email: _editProfile.email,
                            phoneNumber: value,
                            userId: _editProfile.userId,
                            id: _editProfile.id);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Phone Number Cannot be empty';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue.address,
                      decoration: InputDecoration(
                        labelText: "Address",
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      focusNode: _addressFocustNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_addressFocustNode);
                      },
                      onSaved: (value) {
                        _editProfile = UserProfile(
                            address: value,
                            email: _editProfile.email,
                            phoneNumber: _editProfile.phoneNumber,
                            userId: _editProfile.userId,
                            id: _editProfile.id);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Address is too short';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
