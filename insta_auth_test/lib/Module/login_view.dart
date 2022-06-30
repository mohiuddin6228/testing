import 'dart:async';

import 'package:flutter/material.dart';
import 'package:insta_auth_test/Module/login_presenter.dart';
import 'package:insta_auth_test/constants.dart';
import 'package:insta_auth_test/instagram.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text("Flutter Auth"),
          ),
          body: LoginScreen(_scaffoldKey)
      ),
    );
  }

}


///
///   Contact List
///

class LoginScreen extends StatefulWidget{
  final GlobalKey<ScaffoldState> skey;

  const LoginScreen(this.skey, { Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState(skey);
}


class _LoginScreenState extends State<LoginScreen> implements LoginViewContract {
  LoginPresenter? _presenter;
  bool? _IsLoading;
  Token? token;

  GlobalKey<ScaffoldState> _scaffoldKey;


  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value)
    ));
  }

  _LoginScreenState(GlobalKey<ScaffoldState> skey):_scaffoldKey=skey {
    _presenter = LoginPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    _IsLoading = false;
  }


  @override
  void onLoginError(String msg) {
    setState(() {
      _IsLoading = false;
    });

    print("Login error: " + msg);
    showInSnackBar(msg);
  }

  @override
  void onLoginScuccess(Token t) {
    setState(() {
      _IsLoading = false;
      token = t;
    });
    showInSnackBar('Login successful');
  }


  @override
  Widget build(BuildContext context) {
    var widget;
    if(_IsLoading??false) {
      widget = const Center(
          child: Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: CircularProgressIndicator()
          )
      );
    } else if(token != null){
      widget = Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  token?.access??"NULL",
                  style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),),
                Text(token?.user_id??"NULL"),
                // Center(
                //   child: CircleAvatar(
                //     backgroundImage: NetworkImage(token?.profile_picture??"NULL"),
                //     radius: 50.0,
                //   ),
                // ),
              ]
          )
      );
    }
    else {
      widget = Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Welcome to FlutterAuth,',
                  style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),),
                const Text('Login to continue'),
                Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 160.0),
                      child:
                      InkWell(child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Image.asset(
                            'assets/instagram.png',
                            height: 50.0,
                            fit: BoxFit.cover,
                          ),
                          const Text('Continue with Instagram')
                        ],
                      ),onTap: _login,)
                  ),
                ),
              ]
          )
      );
    }
    return widget;
  }


  void _login(){
    setState(() {
      _IsLoading = true;
    });

    _presenter?.perform_login(context);
  }
}
