import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CreateUser extends StatefulWidget {
  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  bool isObscured = true;
  void _toggle() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  createUser(String name, String username, String role, String password) async {
    // String localUrl = 'http://192.168.5.101:8000/api/register';
    String localUrl = 'http://kurir.angkasamulyatrading.com/api/register';
    try {
      final response = await Dio().post(localUrl, data: {
        'name': name,
        'username': username,
        'role': role,
        'password': password,
        'selected': 0,
      });
      if (response.statusCode == 200) {
        nameController.clear();
        usernameController.clear();
        roleController.clear();
        passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ListTile(
              title: Text(
                'Success',
                style: GoogleFonts.sourceSansPro(color: Colors.white),
              ),
              subtitle: Text(
                'Berhasil membuat user baru!',
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
              'Gagal',
              style: GoogleFonts.sourceSansPro(color: Colors.white),
            ),
            subtitle: Text(
              e.response.statusMessage,
              style: GoogleFonts.sourceSansPro(color: Colors.white),
            ),
          ),
        ),
      );
    }
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<String> role = ['Warehouse', 'Courier', 'Stock', 'Tax', 'Billing'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        title: Text('Create User', style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            TextFormField(
              readOnly: true,
              onTap: () {
                showMaterialModalBottomSheet(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                            child: Text(
                              'Role',
                              style: GoogleFonts.sourceSansPro(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        ListView.separated(
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          shrinkWrap: true,
                          itemCount: role.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  roleController.text = role[index];
                                  Get.back();
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              title: Text(role[index]),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(thickness: 1);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              controller: roleController,
              decoration: InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.person_pin_circle_rounded),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: isObscured,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: isObscured == true ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                  onPressed: _toggle,
                ),
              ),
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
                  createUser(nameController.text, usernameController.text, roleController.text, passwordController.text);
                },
                child: Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
