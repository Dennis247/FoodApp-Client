import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/providers/auth.dart';
import 'package:provider_pattern/screens/edit_profile_screen.dart';
import 'package:provider_pattern/widgets/app_drawer.dart';

class ProfilePage extends StatefulWidget {
  static final String routeName = "ProfilePage";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget _buildprofileItem(String title, String subtitle, bool obscureText) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.deepOrange, fontSize: 8.0),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14.0, color: Colors.black),
      ),
    );
  }

  bool _isLoading = false;
  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Auth>(context, listen: false).getUserProfile().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });

    super.initState();
  }

  Widget _commonDivider() {
    return Divider(
      indent: 10.0,
      endIndent: 10.0,
      height: 0.5,
      color: Constants.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, EditProfileScreen.routeName,
                    arguments:
                        Provider.of<Auth>(context, listen: false).userProfile);
              })
        ],
        title: Text(
          "PROFILE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      Consumer<Auth>(
                        builder: (_, authData, ch) => _buildprofileItem(
                          "phone number",
                          (authData.userProfile == null ||
                                  authData.userProfile.phoneNumber == null)
                              ? 'phone not available'
                              : authData.userProfile.phoneNumber,
                          false,
                        ),
                      ),
                      _commonDivider(),
                      Consumer<Auth>(
                        builder: (_, authData, ch) => _buildprofileItem(
                          "address",
                          (authData.userProfile == null ||
                                  authData.userProfile.address == null)
                              ? ' address not available'
                              : authData.userProfile.address,
                          false,
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
