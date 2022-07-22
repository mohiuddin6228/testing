import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';

const _redirectUrl = 'https://flipit.money/';

Future<String> getToken(String appId,BuildContext context) async {
  Stream<String> onCode = await webview2(context);

  // String url =
  //     "https://api.instagram.com/oauth/authorize?client_id=$appId&redirect_uri=http://localhost:8585&response_type=code";
  // final flutterWebviewPlugin = FlutterWebviewPlugin();
  // flutterWebviewPlugin.launch(url);

  print("Before getting code");
  final String code = await onCode.first;
  print("Code: "+code);
  return code;
  // final http.Response response = await http
  //     .post(Uri.parse("https://api.instagram.com/oauth/access_token"), body: {
  //   "client_id": appId,
  //   "redirect_uri": _redirectUrl,
  //   "client_secret": appSecret,
  //   "code": code,
  //   "grant_type": "authorization_code"
  // });
  // {"error_type": "OAuthException", "code": 400, "error_message": "Invalid scope: []"}
  // print("Response body: "+response.body);
  //
  // Token t = Token.fromMap(json.decode(response.body));
  // print("Token: " + t.access);
  // return Token();
}

Future<Stream<String>> webview2(BuildContext context)async{
  const _authUrl = 'https://api.instagram.com/oauth/authorize?client_id=${Constants.APP_ID}&redirect_uri=$_redirectUrl&scope=user_profile,user_media&response_type=code';
  final StreamController<String> onCode = StreamController();

  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SafeArea(
    child: Scaffold(
      body: WebView(
        initialUrl: _authUrl,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) async{
          // This can intercept any navigation within the WebView.
          if(request.url.startsWith(_redirectUrl)){
            final startIndex = request.url.indexOf('code=');
            final endIndex = request.url.lastIndexOf('#');
            final code = request.url.substring(startIndex + 5, endIndex);

            onCode.add(code);
            await onCode.close();

            print("Redirect Code: "+code);

            // return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ),
    ),
  )));
  return onCode.stream;
}

Future<Stream<String>> _server() async {
  final StreamController<String> onCode = StreamController();
  HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8585);
  print("Server running on IP : " +
      server.address.toString() +
      " On Port : " +
      server.port.toString());
  server.listen((HttpRequest request) async {
    final String code = request.uri.queryParameters["code"] ?? "";
    request.response
      ..statusCode = 200
      ..headers.set("Content-Type", ContentType.HTML.mimeType)
      ..write("<html><h1>You can now close this window</h1></html>");
    await request.response.close();
    await server.close(force: true);

  });
  return onCode.stream;
}

class Token {
  String access="";
  String user_id="";
  // String username;
  // String full_name;
  // String profile_picture;

  Token();

  Token.fromMap(Map json)
      : access = json['access_token'],
        user_id = json['user_id'];
}
