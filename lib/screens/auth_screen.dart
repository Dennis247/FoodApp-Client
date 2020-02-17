import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/models/http_exception.dart';
import 'package:provider_pattern/providers/auth.dart';
import 'package:provider_pattern/providers/user_profile.dart';
import 'package:provider_pattern/screens/auth/reset_password_screen.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final String background = "assets/images/homepage.jpg";
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'phoneNumber': ''
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Something Went Wrong"),
              content: Text(errorMessage),
              actions: <Widget>[
                FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    })
              ],
            ));
  }

  String _authToken = "";
  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        _authData['email'] = _authData['email'].trim();
        _authData['phoneNumber'] = _authData['phoneNumber'].trim();

        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email'], _authData['password']);
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
            _authData['email'],
            _authData['password'],
            _authData['phoneNumber']);
      }

      //load user profile
    } on HttpException catch (error) {
      var errorMessage = "AUthentication Failed";
      if (error.toString().contains("EMAIL_EXISTS"))
        errorMessage =
            "The user with Email ${_authData['email']}['email'] already exist";
      if (error.toString().contains("INVALID_EMAIL"))
        errorMessage = "The  Email ${_authData['email']}['email'] is not valid";
      if (error.toString().contains("WEAK_PASSWORD"))
        errorMessage = "The password is too weak, password mut be >= 6";
      if (error.toString().contains("EMAIL_NOT_FOUND"))
        errorMessage =
            "The user with Email ${_authData['email']} does not exist";
      if (error.toString().contains("INVALID_PASSWORD"))
        errorMessage = "The password is not Valid";
      _showErrorDialog(errorMessage);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      const errormessage = "could not authenticate the user";
      _showErrorDialog(errormessage);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          color: Constants.darkPrimary,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(background), fit: BoxFit.cover)),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                color: Colors.black.withOpacity(0.7),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        height: mediaQuery.height * 0.05,
                      ),
                      Text(
                        "Welcome Back",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      Text(
                        "Sign in to continue",
                        style: TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@')) {
                            return 'Invalid email!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['email'] = value;
                        },
                        decoration: InputDecoration(
                            hintText: "email",
                            hintStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54))),
                      ),
                      SizedBox(
                        height: mediaQuery.height * 0.02,
                      ),
                      if (_authMode == AuthMode.Signup)
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value.isEmpty || value.length < 8) {
                              return 'Invalid phone number';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _authData['phoneNumber'] = value;
                          },
                          decoration: InputDecoration(
                              hintText: "phone Number",
                              hintStyle: TextStyle(color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white54))),
                        ),
                      if (_authMode == AuthMode.Signup)
                        SizedBox(
                          height: mediaQuery.height * 0.02,
                        ),
                      TextFormField(
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        controller: _passwordController,
                        validator: (value) {
                          if (value.isEmpty || value.length < 5) {
                            return 'Password is too short!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['password'] = value;
                        },
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54))),
                      ),
                      SizedBox(
                        height: mediaQuery.height * 0.02,
                      ),
                      if (_authMode == AuthMode.Signup)
                        TextFormField(
                          obscureText: true,
                          enabled: _authMode == AuthMode.Signup,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                  return null;
                                }
                              : null,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "Confirm Password",
                              hintStyle: TextStyle(color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white54))),
                        ),
                      SizedBox(
                        height: mediaQuery.height * 0.03,
                      ),
                      SizedBox(
                        height: 40,
                        width: mediaQuery.width / 1.2,
                        child: RaisedButton(
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text(
                                  "${_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'} ",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                          color: Colors.white,
                          onPressed: _submit,
                        ),
                      ),
                      SizedBox(
                        height: mediaQuery.height * 0.03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _switchAuthMode();
                            },
                            child: Text(
                              _authMode == AuthMode.Login
                                  ? 'DO NOT HAVE AN ACCOUNT ?  SIGN UP'
                                  : 'ALREADY HAVE AN ACCOUNT : LOGIN',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ResetPasswordScreen.routeName);
                        },
                        child: Text(
                          "Forgot your password?",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
