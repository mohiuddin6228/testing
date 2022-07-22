import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:insta_auth_test/instagram.dart' as insta;
import 'package:insta_auth_test/constants.dart';

abstract class LoginViewContract {
  void onLoginScuccess(String code);
  void onLoginError(String message);
}

class LoginPresenter {
  LoginViewContract _view;
  LoginPresenter(this._view);

  void perform_login(BuildContext context) {
    assert(_view != null);
    insta.getToken(Constants.APP_ID,context).then((token) {
      if (token != null) {
        _view.onLoginScuccess(token);
      } else {
        _view.onLoginError('Error');
      }
    }).onError((error, stackTrace) {
      print("Error:"+error.toString());
      _view.onLoginError('Error');
    });
  }
}
