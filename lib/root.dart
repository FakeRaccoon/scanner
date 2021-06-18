import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanner/home.dart';
import 'package:scanner/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  Future checkLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.getString('role') == null) {
      Get.offAll(() => Login());
    } else {
      Get.offAll(() => Home());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
