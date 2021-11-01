import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scanner/Screens/home.dart';
import 'package:scanner/notification-page.dart';
import 'package:scanner/user-page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int selectedPage = 0;
  List<Widget> pageList = [];

  SharedPreferences sharedPreferences;

  Future getSharedPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final getUsername = sharedPreferences.getString('username');
    if (getUsername != null) {
      setState(() {
        username = getUsername;
      });
    }
  }

  String username;

  @override
  void initState() {
    pageList.add(Home());
    pageList.add(NotificationPage());
    pageList.add(UserPage());
    getSharedPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedPage,
        children: pageList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidBell),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidUser),
            label: 'User',
          ),
        ],
        currentIndex: selectedPage,
        selectedItemColor: Colors.blue,
        onTap: onItemTapped,
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedPage = index;
      // if (selectedPage == 0) {
      //   FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
      //   FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
      // }
      // if (selectedPage == 1) {
      //   FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
      //   FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
      // }
      // if (selectedPage == 2) {
      //   FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
      //   FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
      // }
    });
  }
}
