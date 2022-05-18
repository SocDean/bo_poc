import 'dart:convert';

import 'package:bo_poc/views/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = true;
  String _message = '';
  bool _isLogin = true;
  late SharedPreferences sharedPreferences;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("accessToken") != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => QRScanner()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(36),
        child: ListView(
          children: <Widget>[
            emailInput(),
            passwordInput(),
            button(),
            validationMessage(),
            changeIsLoginStateButton(),
          ],
        ),
      ),
    );
  }

  Widget emailInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 128),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'Email',
          icon: Icon(Icons.email),
        ),
        validator: (text) {
          if (text!.isEmpty) {
            return ('Enter email.');
          }
          final regex = RegExp(
              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
          if (!regex.hasMatch(text)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget passwordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: TextFormField(
        controller: passwordController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Password',
          icon: Icon(Icons.password),
        ),
        validator: (password) {
          if (password!.isEmpty) {
            return ('Enter password.');
          }
          final regex = RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!-\/:-@\[-{-~]).{7,}$');
          if (!regex.hasMatch(password)) {
            return 'Enter a valid password';
          }
          return null;
        },
      ),
    );
  }

  Widget button() {
    String text = _isLogin ? 'Log in' : 'Sign up';
    return Padding(
      padding: const EdgeInsets.only(top: 128),
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.black),
              ),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          onPressed: () {
            signIn(emailController.text, passwordController.text);
          },
        ),
      ),
    );
  }

  Widget changeIsLoginStateButton() {
    String text = _isLogin ? 'Sign up' : 'Log in';
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.black),
      ),
      child: Text(text),
    );
  }

  Widget validationMessage() {
    return Text(
      _message,
      style: TextStyle(
          fontSize: 30,
          color: Theme.of(context).primaryColorDark,
          fontWeight: FontWeight.bold),
    );
  }

  signIn(String email, pass) async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': email, 'password': pass};
    var jsonResponse;
    var response = await http.post(
        Uri.parse('https://refactor.api.bopaq.com/auth/login'),
        body: data);
    if (response.statusCode == 201) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("accessToken", jsonResponse['accessToken']);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => QRScanner()));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
