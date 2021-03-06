import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner/change-password-page.dart';
import 'package:scanner/main.dart';
import 'package:scanner/root.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    getUser();
    checkUpdate();
    getAppVersion();
  }

  SharedPreferences sharedPreferences;

  Future getUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final uname = sharedPreferences.getString('name');
    final urole = sharedPreferences.getString('role');
    if (uname != null && urole != null) {
      setState(() {
        name = uname;
        role = urole;
      });
    }
  }

  String name;
  String role;

  Future<void> logout() async {
    sharedPreferences = await SharedPreferences.getInstance();
    // await FirebaseMessaging.instance.unsubscribeFromTopic(sharedPreferences.getString('role').toLowerCase().replaceAll(' ', ''));
    // await FirebaseMessaging.instance.deleteToken().whenComplete(() => print('token deleted'));
    // final role = sharedPreferences.getString('role');
    // await OneSignal.shared.deleteTag('userRole');
    // await OneSignal.shared.deleteTags([
    //   'Admin',
    //   'Direktur',
    //   'Manager Marketing',
    //   'Manager Service',
    //   'Kepala Gudang Barang Demo',
    //   'Kepala Gudang Lainnya',
    //   'Sales',
    //   'Teknisi',
    //   'Kasir',
    // ]);
    // await OneSignal.shared.getTags();
    // await OneSignal.shared.setSubscription(false);
    sharedPreferences.clear();
    sharedPreferences.commit();
    Get.offAll(Root());
  }

  OtaEvent currentEvent;

  Future<void> tryOtaUpdate(link) async {
    try {
      OtaUpdate().execute(link, destinationFilename: 'scanner1.0.5.apk').listen(
        (OtaEvent event) {
          setState(() => currentEvent = event);
          print(currentEvent.status);
        },
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

  String currentVersion;

  Future firebase;

  Future checkUpdate() async {
    firebase = FirebaseFirestore.instance.collection('appversion').doc('version').get();
  }

  Future getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
    print(packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark ,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User Info',
                                style: GoogleFonts.openSans(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person),
                                ],
                              ),
                              title: Text(name ?? "", style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                              subtitle: Text(role ?? "", style: GoogleFonts.openSans()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Keamanan',
                                style: GoogleFonts.openSans(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ListTile(
                              onTap: () => Get.to(() => ChangePassword()),
                              contentPadding: EdgeInsets.zero,
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock),
                                ],
                              ),
                              title: Text("Ubah Kata Sandi", style: GoogleFonts.openSans()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (role == 'Superuser' || role == 'Direktur')
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fitur Tambahan',
                                      style: GoogleFonts.openSans(color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ListTile(
                                    // onTap: () => Get.to(Log()),
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.list),
                                    title: Text("Log", style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                    trailing: Icon(Icons.arrow_forward_ios, size: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    FutureBuilder(
                      future: firebase,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int version = int.tryParse(currentVersion.replaceAll(".", ""));
                          Map<String, dynamic> data = snapshot.data.data();
                          // print(version + data['version']);
                          return Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('App Update',
                                          style: GoogleFonts.openSans(color: Colors.grey, fontWeight: FontWeight.bold)),
                                      if (version >= data['version'])
                                        ListTile(
                                          onTap: () {},
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(Icons.update_rounded),
                                          title: Text("No Update Available", style: GoogleFonts.openSans()),
                                        )
                                      else
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(Icons.update_rounded),
                                          title: Text("New Update Available", style: GoogleFonts.openSans()),
                                          trailing: IconButton(
                                            onPressed: () {
                                              // appDownload(data['link']);
                                              tryOtaUpdate(data['link']);
                                            },
                                            icon: Icon(Icons.download_rounded),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.black,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                    Center(child: Text("App Version $currentVersion", style: GoogleFonts.openSans())),
                    SizedBox(height: 20),
                    SizedBox(
                      width: Get.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[900],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          Get.defaultDialog(
                            cancel: OutlineButton(
                              borderSide: BorderSide(color: Colors.red),
                              onPressed: () => Navigator.pop(context),
                              child: Text('Batal', style: TextStyle(color: Colors.red)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            confirm: FlatButton(
                              color: Colors.grey[900],
                              onPressed: () {
                                Navigator.pop(context);
                                logout();
                              },
                              child: Text('Ya', style: TextStyle(color: Colors.white)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            title: 'Peringatan',
                            middleText: 'Apakah anda yakin ingin logout?',
                          );
                        },
                        child: Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
