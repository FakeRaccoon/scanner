import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanner/Screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool isObscured = true;
  void _toggle() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  var usernameController = TextEditingController();
  var passController = TextEditingController();

  String externalIds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.all(20),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Login', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 22)),
                  SizedBox(height: 20),
                  TextFormField(
                    cursorColor: Colors.grey[900],
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'username tidak boleh kosong';
                      }
                      return null;
                    },
                    controller: usernameController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'password tidak boleh kosong';
                      }
                      return null;
                    },
                    obscureText: isObscured,
                    controller: passController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: _toggle,
                          icon: isObscured == false ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                        )),
                  ),
                  SizedBox(height: 20),
                  // ButtonTheme(
                  //   minWidth: MediaQuery.of(context).size.width,
                  //   splashColor: Colors.transparent,
                  //   highlightColor: Colors.transparent,
                  //   height: 40,
                  //   child: FlatButton(
                  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  //     onPressed: () {
                  //       if (_key.currentState.validate()) {
                  //         loginTest(usernameController.text, passController.text);
                  //       }
                  //     },
                  //     color: Colors.grey[900],
                  //     child: Text(
                  //       'Login',
                  //       style: GoogleFonts.sourceSansPro(color: Colors.white, fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    width: Get.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.grey[900],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      onPressed: () {
                        if (_key.currentState.validate()) {
                          loginTest(usernameController.text, passController.text);
                        }
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.sourceSansPro(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // FlatButton(onPressed: () => Get.to(Register()), child: Text('Register'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  loginTest(String username, String password) async {
    // // String localUrl = 'http://192.168.5.80:8000/api/login';
    // String localUrl = apiUrl + 'api/login';
    try {
      final response = await Dio().post(apiUrl + 'api/login', data: {
        'username': username.trim(),
        'password': password.trim(),
      });
      if (response.statusCode == 200) {
        print(response.data['result']);
        final data = response.data['result'];
        setUserInfoPreference(
          data['id'],
          data['username'],
          data['name'],
          data['token'],
          data['role'],
        )
            .then(
          (value) => Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        )
            .whenComplete(() {
          Get.offAll(() => Home());
        });
      }
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content:
            Text('Username atau password anda salah', style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future setUserInfoPreference(int id, String username, String name, String token, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('userId', id);
    prefs.setString('username', username);
    prefs.setString('name', name);
    prefs.setString('token', token);
    prefs.setString('role', role);
  }
}
