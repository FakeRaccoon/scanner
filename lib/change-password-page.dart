import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  SharedPreferences sharedPreferences;

  Future changePass(password) async {
    sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString('username');
    try {
      final response = await Dio().post('http://192.168.5.101:8000/api/changePassword', data: {
        'username': username,
        'password': password,
      });
      if (response.statusCode == 200) {
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ListTile(
              title: Text(
                'Berhasil!',
                style: GoogleFonts.sourceSansPro(color: Colors.white),
              ),
              subtitle: Text(
                'Berhasil mengubah kata sandi!',
                style: GoogleFonts.sourceSansPro(color: Colors.white),
              ),
            ),
          ),
        );
      }
    } on DioError catch (e) {
      print(e.response.data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: ListTile(
            title: Text(
              'Gagal!',
              style: GoogleFonts.sourceSansPro(color: Colors.white),
            ),
            subtitle: Text(
              'Gagal mengubah kata sandi',
              style: GoogleFonts.sourceSansPro(color: Colors.white),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Change Password', style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                validator: (String value) {
                  if (value.length < 6) {
                    return 'Minimal 6 karakter';
                  }
                  if (value != newPasswordController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              TextFormField(
                validator: (String value) {
                  if (value.length < 6) {
                    return 'Minimal 6 karakter';
                  }
                  if (value != newPasswordController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
                controller: confirmNewPasswordController,
                obscureText: true,
                onChanged: (String value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    suffixIcon: confirmNewPasswordController.text == newPasswordController.text &&
                            confirmNewPasswordController.text.isNotEmpty &&
                            newPasswordController.text.isNotEmpty &&
                            newPasswordController.text.length >= 6 &&
                            confirmNewPasswordController.text.length >= 6
                        ? Icon(Icons.check)
                        : SizedBox()),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: Get.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    primary: Colors.grey[900],
                  ),
                  onPressed: () {
                    if (_key.currentState.validate()) {
                      changePass(newPasswordController.text);
                    }
                  },
                  child: Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
