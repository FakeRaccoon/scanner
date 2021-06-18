import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanner/courier.dart';
import 'package:scanner/create-user.dart';
import 'package:scanner/form-model.dart';
import 'package:scanner/login.dart';
import 'package:scanner/stock.dart';
import 'package:scanner/tax-billing.dart';
import 'package:scanner/user-page.dart';
import 'package:scanner/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const apiUrl = 'http://192.168.0.41:8000/';
const apiUrl = 'http://kurir.angkasamulyatrading.com/';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  getFormStatus(int status) async {
    final response = await Dio().get(apiUrl + 'api/form/status', queryParameters: {'status': status});
    List dateList = response.data['result'].map((e) => e['request_date']).toList();
    dateList.sort();
    smallestDateToFilter = DateTime.parse(dateList.first);
    fromDate.text = DateFormat('d MMM y').format(smallestDateToFilter);
    toDate.text = DateFormat('d MMM y').format(DateTime.now());
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  getFormStatus2(int status1, int status2) async {
    final response = await Dio().get(
      apiUrl + 'api/form/status2',
      queryParameters: {
        'status1': status1,
        'status2': status2,
      },
    );
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  getUser() async {
    final response = await Dio().get(apiUrl + 'api/user');
    print(response.data);
    return userResultFromJson(jsonEncode(response.data['result']));
  }

  DateTime smallestDateToFilter;

  Future formFuture;
  Future userFuture;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    selectedRadio = 1;
    userFuture = getUser();
    tabChange();
    dateController.text = DateFormat('d MMMM y').format(date);
    checkLoginStatus();
    firebaseMessaging.getToken().then((String token) => print(token));
    _tabController = TabController(vsync: this, length: 6, initialIndex: initialTabIndex);
  }

  int initialTabIndex = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  int tabIndex = 0;
  List<Widget> pageList = [];

  TabController _tabController;

  void tabChange() {
    setState(() {
      if (tabIndex == 0) {
        formFuture = getFormStatus2(0, 1);
      } else if (tabIndex == 1) {
        formFuture = getFormStatus2(2, 2);
      } else if (tabIndex == 2) {
        formFuture = getFormStatus2(0, 3);
      } else if (tabIndex == 3) {
        formFuture = getFormStatus2(3, 5);
      } else if (tabIndex == 4) {
        formFuture = getFormStatus2(5, 5);
      } else if (tabIndex == 5) {
        formFuture = getFormStatus(6);
      }
    });
  }

  DateTime date = DateTime.now();
  TextEditingController dateController = TextEditingController();
  TextEditingController taskController = TextEditingController();
  TextEditingController otherTaskController = TextEditingController();
  TextEditingController userController = TextEditingController();

  createSJForm(status, task, otherTask, toId) async {
    sharedPreferences = await SharedPreferences.getInstance();
    final response = await Dio().post(apiUrl + 'api/form/create', data: {
      'status': status,
      'task': task,
      'from_id': sharedPreferences.getInt('userId'),
      'to_id': toId,
      'other_task': otherTask,
      'request_date': date.toString(),
    });
    if (response.statusCode == 200) {
      Get.offAll(() => Home());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 10),
          content: ListTile(
            title: Text('Berhasil menambahkan surat jalan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Silahkan cek tab warehouse', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }
    print(response.data);
  }

  createSLForm(status, task, otherTask, toId) async {
    sharedPreferences = await SharedPreferences.getInstance();
    final response = await Dio().post(apiUrl + 'api/form/create', data: {
      'status': status,
      'task': task,
      'from_id': sharedPreferences.getInt('userId'),
      'to_id': toId,
      'other_task': otherTask,
      'request_date': date.toString(),
    });
    if (response.statusCode == 200) {
      Get.offAll(() => Home());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 10),
          content: ListTile(
            title: Text('Berhasil menambahkan surat lain',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Silahkan refresh tab request bila diperlukan', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
      setState(() {
        formFuture = getFormStatus2(0, 0);
      });
    }
    print(response.data);
  }

  updateFormSL(id, task, otherTask, status, requestDate, pickUpDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'other_task': otherTask,
      'status': status,
      'request_date': requestDate,
      'pick_up_date': pickUpDate,
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {
      setState(() {
        tabIndex = 2;
        formFuture = getFormStatus2(0, 3);
      });
    }
    print(response.data);
  }

  updateFormSL2(id, task, otherTask, status, requestDate, pickUpDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'other_task': otherTask,
      'status': status,
      'request_date': requestDate,
      'pick_up_date': pickUpDate,
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {
      setState(() {
        tabIndex = 0;
        formFuture = getFormStatus2(0, 1);
      });
    }
    print(response.data);
  }

  updateFormSJ(id, task, otherTask, status, requestDate, pickUpDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'other_task': otherTask,
      'status': status,
      'request_date': requestDate,
      'pick_up_date': pickUpDate,
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {
      setState(() {
        tabIndex = 2;
        formFuture = getFormStatus2(0, 3);
      });
    }
    print(response.data);
  }

  updateForm2(id, task, requestDate, pickUpDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'status': 4,
      'request_date': requestDate,
      'pick_up_date': pickUpDate,
      'received_date': DateTime.now().toString(),
    });
    if (response.statusCode == 200) {
      setState(() {
        tabIndex = 3;
        formFuture = getFormStatus2(3, 5);
      });
    }
    print(response.data);
  }

  updateFormFinal(id, task, tax, billing, requestDate, pickUpDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'status': 5,
      'tax': tax,
      'billing': billing,
      'request_date': requestDate,
      'pick_up_date': pickUpDate,
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {
      final getResponse = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': id});
      int tax = getResponse.data['result'][0]['tax'];
      int billing = getResponse.data['result'][0]['billing'];
      if (tax != null && billing != null) {
        if (tax + billing == 2) {
          updateFormFinalFinal(id, task, 6, 1, 1, requestDate, pickUpDate, receivedDate);
        } else if (tax == null || billing == null) {
          setState(() {
            tabIndex = 4;
            formFuture = getFormStatus2(5, 5);
          });
        }
      }
      print(response.data);
    }
    print('TAX UPDATE SUCCESS');
  }

  updateFormFinal2(id, task, tax, billing, requestDate, pickUpDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'status': 5,
      'tax': tax,
      'billing': billing,
      'request_date': requestDate,
      'pick_up_date': pickUpDate,
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {
      final getResponse = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': id});
      int tax = getResponse.data['result'][0]['tax'];
      int billing = getResponse.data['result'][0]['billing'];
      if (tax != null && billing != null) {
        if (tax + billing == 2) {
          updateFormFinalFinal(id, task, 6, 1, 1, requestDate, pickUpDate, receivedDate);
        } else if (tax == null || billing == null) {
          setState(() {
            tabIndex = 4;
            formFuture = getFormStatus2(5, 5);
          });
        }
      }
      print(response.data);
    }
    print('BILLING UPDATE SUCCESS');
  }

  updateFormFinalFinal(id, task, status, tax, billing, requestDate, pickUpDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'status': status,
      'tax': tax,
      'billing': billing,
      'request_date': requestDate,
      'pick_up_date': pickUpDate,
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {
      setState(() {
        tabIndex = 3;
        formFuture = getFormStatus2(3, 3);
      });
    }
    print(response.data);
  }

  deleteFormRequest(id) async {
    final response = await Dio().post(apiUrl + 'api/form/delete', data: {
      'id': id,
    });
    if (response.statusCode == 200) {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil dihapus')));
      setState(() {
        formFuture = getFormStatus2(0, 1);
      });
    }
    print(response.data);
  }

  deleteFormWarehouse(id) async {
    final response = await Dio().post(apiUrl + 'api/form/delete', data: {
      'id': id,
    });
    if (response.statusCode == 200) {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil dihapus')));
      setState(() {
        formFuture = getFormStatus2(2, 2);
      });
    }
    print(response.data);
  }

  Future finalScanQRCourier() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        if (response.data['result'][0]['status'] == 0) {
          final data = response.data['result'][0];
          updateFormSL(
            data['id'],
            data['task'],
            data['other_task'],
            1,
            data['request_date'],
            DateTime.now().toString(),
            data['received_date'],
          );
        }
        if (response.data['result'][0]['status'] == 1) {
          final data = response.data['result'][0];
          updateFormSL2(
            data['id'],
            data['task'],
            data['other_task'],
            6,
            data['request_date'],
            data['pick_up_date'],
            DateTime.now().toString(),
          );
        }
        if (response.data['result'][0]['status'] == 2) {
          final data = response.data['result'][0];
          updateFormSJ(
            data['id'],
            data['task'],
            data['other_task'],
            3,
            data['request_date'],
            DateTime.now().toString(),
            data['received_date'],
          );
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {});
  }

  Future finalScanRequest() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        if (response.data['result'][0]['status'] == 0) {
          final data = response.data['result'][0];
          updateFormSL(
            data['id'],
            data['task'],
            data['other_task'],
            4,
            data['request_date'],
            DateTime.now().toString(),
            data['received_date'],
          );
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {});
  }

  Future finalScanQRStock() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        if (response.data['result'][0]['status'] == 3) {
          final data = response.data['result'][0];
          updateForm2(data['id'], data['task'], data['request_date'], data['pick_up_date']);
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {});
  }

  Future finalScanQRTax() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        final data = response.data['result'][0];
        List transactions = data['transactions'];
        List otherTransactions = data['other_transactions'];
        if (userRole == 'Admin') {
          if (data['tax'] == null && data['billing'] == null && !transactions.map((e) => e['type']).contains(2)) {
            updateFormFinal(
              data['id'],
              data['task'],
              1,
              1,
              data['request_date'],
              data['pick_up_date'],
              data['received_date'],
            );
          } else if (data['tax'] == null &&
              data['billing'] == null &&
              !transactions.map((e) => e['type']).contains(1)) {
            updateFormFinal(
              data['id'],
              data['task'],
              1,
              1,
              data['request_date'],
              data['pick_up_date'],
              data['received_date'],
            );
          } else if (data['tax'] == null &&
              data['billing'] == null &&
              transactions.map((e) => e['type']).contains(1) &&
              transactions.map((e) => e['type']).contains(2)) {
            updateFormFinal(
              data['id'],
              data['task'],
              1,
              1,
              data['request_date'],
              data['pick_up_date'],
              data['received_date'],
            );
          }
        }
        if (userRole == 'Tax') {
          if (!transactions.map((e) => e['type']).contains(2)) {
            updateFormFinal(
              data['id'],
              data['task'],
              1,
              1,
              data['request_date'],
              data['pick_up_date'],
              data['received_date'],
            );
          } else {
            updateFormFinal(
              data['id'],
              data['task'],
              1,
              data['billing'],
              data['request_date'],
              data['pick_up_date'],
              data['received_date'],
            );
          }
        } else if (userRole == 'Billing') {
          if (!transactions.map((e) => e['type']).contains(1)) {
            updateFormFinal2(
              data['id'],
              data['task'],
              1,
              1,
              data['request_date'],
              data['pick_up_date'],
              data['received_date'],
            );
          } else {
            updateFormFinal2(
              data['id'],
              data['task'],
              data['tax'],
              1,
              data['request_date'],
              data['pick_up_date'],
              data['received_date'],
            );
          }
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {});
  }

  SharedPreferences sharedPreferences;

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Login()), (Route<dynamic> route) => false);
    } else {
      setState(() {
        userRole = sharedPreferences.getString('role');
        userName = sharedPreferences.getString('name');
        username = sharedPreferences.getString('username');
        print(userRole);
      });
    }
    if (userRole == 'Courier') {
      firebaseMessaging.subscribeToTopic('Courier').whenComplete(() => print('$userRole subscribed'));
    }
  }

  String userRole;
  String userName;
  String username;

  int userId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName ?? '', style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, color: Colors.black)),
            Text(userRole ?? '', style: GoogleFonts.sourceSansPro(color: Colors.grey, fontSize: 15)),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.grey[700]),
        actions: [
          Visibility(
            visible: userRole == 'Admin' ? true : false,
            child: IconButton(
              tooltip: 'Add new user',
              icon: Icon(Icons.person_add_rounded),
              onPressed: () => Get.to(() => CreateUser()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.person_outline_rounded),
            onPressed: () {
              Get.to(() => UserPage());
            },
          ),
        ],
      ),
      floatingActionButton: tabIndex == 0 && userRole != 'Courier'
          ? FloatingActionButton(
              backgroundColor: Colors.grey[900],
              onPressed: () {
                showMaterialModalBottomSheet(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  context: context,
                  builder: (context) {
                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Request',
                                style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            ListTile(
                              enabled: userRole == 'Admin' || userRole == 'Warehouse' ? true : false,
                              onTap: () {
                                suratJalanRequestBottomSheet(context);
                              },
                              contentPadding: EdgeInsets.zero,
                              title: Text('Surat Jalan'),
                            ),
                            Divider(thickness: 1),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                suratLainRequestBottomSheet(context);
                              },
                              title: Text('Surat Lain'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            )
          : SizedBox(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            onTap: (int value) {
              tabIndex = value;
              tabChange();
            },
            isScrollable: true,
            indicatorColor: Colors.transparent,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.grey[900],
            labelStyle: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 18),
            tabs: [
              Tab(
                child: Text('Request'),
              ),
              Tab(
                child: Text('Warehouse'),
              ),
              Tab(
                child: Text('Courier'),
              ),
              Tab(
                child: Text('Stock'),
              ),
              Tab(
                child: Text('Tax & Billing'),
              ),
              Tab(
                child: Text('History'),
              ),
            ],
          ),
          // Visibility(
          //   visible: tabIndex == 5 ? true : false,
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         border: Border.all(color: Colors.grey),
          //         borderRadius: BorderRadius.circular(Get.width),
          //         color: Colors.white,
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [Text('Semua Tanggal'), Icon(Icons.keyboard_arrow_down_outlined)],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Visibility(
            visible: tabIndex == 0 ? true : false,
            child: userRole == 'Courier' ? Expanded(child: Center(child: Text('Not Authorized'))) : requestUI(),
          ),
          Visibility(
            visible: tabIndex == 1 ? true : false,
            child: warehouseUI(),
          ),
          Visibility(
            visible: tabIndex == 2 ? true : false,
            child: courierUI(),
          ),
          Visibility(
            visible: tabIndex == 3 ? true : false,
            child: stockUI(),
          ),
          Visibility(
            visible: tabIndex == 4 ? true : false,
            child: taxBillingUI(),
          ),
          Visibility(
            visible: tabIndex == 5 ? true : false,
            child: history(),
          ),
        ],
      ),
    );
  }

  suratJalanRequestBottomSheet(BuildContext context) {
    return showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setModalState) {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Surat Jalan',
                            style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        TextFormField(
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Isi jumlah surat jalan';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: taskController,
                          decoration: InputDecoration(labelText: 'Banyak Surat Jalan'),
                        ),
                        TextFormField(
                          onTap: () {
                            DatePicker.showDatePicker(
                              context,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2023, 1, 1),
                              locale: LocaleType.id,
                              onConfirm: (DateTime value) {
                                if (value != null) {
                                  date = value;
                                  dateController.text = DateFormat('d MMMM y').format(date);
                                }
                              },
                            );
                          },
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Tanggal Pengambilan'),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: Get.width,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey[900],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                createSJForm(2, taskController.text, otherTaskController.text, userId);
                                taskController.clear();
                                otherTaskController.clear();
                                dateController.text = DateFormat('d MMMM y').format(DateTime.now());
                                Get.back();
                              }
                            },
                            child: Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  suratLainRequestBottomSheet(BuildContext context) {
    return showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setModalState) {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Surat Lain', style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        TextFormField(
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Isi jumlah surat jalan';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: otherTaskController,
                          decoration: InputDecoration(labelText: 'Banyak Surat Lain / Non Barcode'),
                        ),
                        TextFormField(
                          readOnly: true,
                          onTap: () {
                            buildShowMaterialModalBottomSheet(context);
                          },
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Isi tujuan pengiriman';
                            }
                            return null;
                          },
                          controller: userController,
                          decoration: InputDecoration(labelText: 'Tujuan Pengiriman'),
                        ),
                        TextFormField(
                          onTap: () {
                            DatePicker.showDatePicker(
                              context,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2023, 1, 1),
                              locale: LocaleType.id,
                              onConfirm: (DateTime value) {
                                if (value != null) {
                                  date = value;
                                  dateController.text = DateFormat('d MMMM y').format(date);
                                }
                              },
                            );
                          },
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Tanggal Pengambilan'),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: Get.width,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey[900],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                createSLForm(0, taskController.text, otherTaskController.text, userId);
                                taskController.clear();
                                otherTaskController.clear();
                                dateController.text = DateFormat('d MMMM y').format(DateTime.now());
                                Get.back();
                              }
                            },
                            child: Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  buildShowMaterialModalBottomSheet(BuildContext context) {
    return showMaterialModalBottomSheet(
      expand: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: userFuture,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 20, bottom: 20),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(Icons.clear),
                          ),
                          Text(
                            'Tujuan Pengiriman',
                            style: GoogleFonts.sourceSansPro(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        UserResult user = snapshot.data[index];
                        if (user.role != 'Admin') {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              setState(() {
                                userController.text = user.name;
                                userId = user.id;
                              });
                              Get.back();
                            },
                            title: Text(user.name),
                            subtitle: Text(user.username),
                          );
                        }
                        return SizedBox();
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        UserResult user = snapshot.data[index];
                        if (user.role != 'Admin') {
                          return Divider(thickness: 1);
                        }
                        return SizedBox();
                      },
                    ),
                  ),
                ],
              );
            }
            return CircularProgressIndicator();
          },
        );
      },
    );
  }

  int selectedRadio;
  DateTime smallestMinDate;
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  Widget history() {
    return Expanded(
      child: FutureBuilder(
        future: formFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(child: Text('Tidak ada data'));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                //   child: InkWell(
                //     onTap: () {
                //       selectedRadio = 1;
                //       showMaterialModalBottomSheet(
                //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                //         context: context,
                //         builder: (BuildContext context) {
                //           return StatefulBuilder(
                //             builder: (BuildContext context, void Function(void Function()) setModalState) {
                //               return Container(
                //                 child: Padding(
                //                   padding: const EdgeInsets.symmetric(horizontal: 10),
                //                   child: Column(
                //                     mainAxisSize: MainAxisSize.min,
                //                     crossAxisAlignment: CrossAxisAlignment.start,
                //                     children: [
                //                       SafeArea(
                //                         child: Row(
                //                           children: [
                //                             IconButton(
                //                               onPressed: () {
                //                                 Get.back();
                //                               },
                //                               icon: Icon(Icons.clear),
                //                             ),
                //                             Text(
                //                               'Pilih Tanggal',
                //                               style:
                //                                   GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 18),
                //                             ),
                //                           ],
                //                         ),
                //                       ),
                //                       SizedBox(height: 20),
                //                       RadioListTile(
                //                         contentPadding: EdgeInsets.symmetric(horizontal: 10),
                //                         value: 1,
                //                         groupValue: selectedRadio,
                //                         onChanged: (newValue) {
                //                           setModalState(() {
                //                             selectedRadio = newValue;
                //                           });
                //                         },
                //                         title: Text('Semua Tanggal Transaksi'),
                //                         controlAffinity: ListTileControlAffinity.trailing,
                //                       ),
                //                       Divider(thickness: 1),
                //                       RadioListTile(
                //                         contentPadding: EdgeInsets.symmetric(horizontal: 10),
                //                         value: 2,
                //                         groupValue: selectedRadio,
                //                         onChanged: (newValue) {
                //                           setModalState(() {
                //                             selectedRadio = newValue;
                //                           });
                //                         },
                //                         title: Text('Pilih Tanggal'),
                //                         controlAffinity: ListTileControlAffinity.trailing,
                //                       ),
                //                       Divider(thickness: 1),
                //                       Visibility(
                //                         visible: selectedRadio == 1 ? false : true,
                //                         child: Padding(
                //                           padding: const EdgeInsets.all(10),
                //                           child: Row(
                //                             children: [
                //                               Expanded(
                //                                 child: TextFormField(
                //                                   decoration: InputDecoration(labelText: 'Mulai dari'),
                //                                   controller: fromDate,
                //                                   readOnly: true,
                //                                   onTap: () {
                //                                     DatePicker.showDatePicker(
                //                                       context,
                //                                       minTime: smallestDateToFilter,
                //                                       maxTime: DateTime.now(),
                //                                       locale: LocaleType.id,
                //                                       onConfirm: (DateTime value) {
                //                                         smallestMinDate = value;
                //                                         if (value != null) {
                //                                           fromDate.text = DateFormat('d MMMM y').format(value);
                //                                         }
                //                                       },
                //                                     );
                //                                   },
                //                                 ),
                //                               ),
                //                               SizedBox(width: 20),
                //                               Expanded(
                //                                 child: TextFormField(
                //                                   decoration: InputDecoration(labelText: 'Sampai'),
                //                                   controller: toDate,
                //                                   readOnly: true,
                //                                   onTap: () {
                //                                     DatePicker.showDatePicker(
                //                                       context,
                //                                       minTime: smallestMinDate,
                //                                       maxTime: DateTime.now(),
                //                                       locale: LocaleType.id,
                //                                       onConfirm: (DateTime value) {
                //                                         if (value != null) {
                //                                           toDate.text = DateFormat('d MMMM y').format(value);
                //                                         }
                //                                       },
                //                                     );
                //                                   },
                //                                 ),
                //                               ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                       SizedBox(height: 10),
                //                       Padding(
                //                         padding: const EdgeInsets.all(10),
                //                         child: SizedBox(
                //                           width: Get.width,
                //                           child: ElevatedButton(
                //                             onPressed: () {
                //                               Get.back();
                //                             },
                //                             child: Text('Terapkan'),
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               );
                //             },
                //           );
                //         },
                //       );
                //     },
                //     child: Container(
                //       decoration: BoxDecoration(
                //         border: Border.all(color: Colors.grey),
                //         borderRadius: BorderRadius.circular(Get.width),
                //         color: Colors.white,
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Text('Semua Tanggal'),
                //             Icon(Icons.keyboard_arrow_down_outlined),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      FormResult form = snapshot.data[index];
                      var finalStatus;
                      var status = form.status;
                      switch (status) {
                        case 6:
                          finalStatus = 'Selesai';
                      }
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.boxOpen),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          finalStatus,
                                          style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold),
                                        ),
                                        Text(DateFormat('d MMM y').format(form.updatedAt)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(thickness: 1),
                              if (form.transactions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'List Surat Jalan',
                                        style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                      ),
                                      SizedBox(height: 10),
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: form.transactions.length,
                                        itemBuilder: (ctx, i) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(form.transactions[i].name),
                                                  Spacer(),
                                                  Text(form.transactions[i].type == 1 ? 'Tax' : 'Billing',
                                                      style: TextStyle(color: Colors.green)),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              if (form.task == null)
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'List Surat Lain / Non Barcode',
                                        style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                      ),
                                      SizedBox(height: 10),
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: form.otherTransactions.length,
                                        itemBuilder: (ctx, i) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(form.otherTransactions[i].name),
                                              SizedBox(height: 10),
                                            ],
                                          );
                                        },
                                      ),
                                      Divider(thickness: 1),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('From',
                                                  style: GoogleFonts.sourceSansPro(fontSize: 17, color: Colors.grey)),
                                              Text(form.fromUser.name,
                                                  style: GoogleFonts.sourceSansPro(
                                                      fontWeight: FontWeight.bold, fontSize: 17)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('To',
                                                  style: GoogleFonts.sourceSansPro(fontSize: 17, color: Colors.grey)),
                                              Text(form.toUser.name,
                                                  style: GoogleFonts.sourceSansPro(
                                                      fontWeight: FontWeight.bold, fontSize: 17)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget taxBillingUI() {
    return Expanded(
      child: FutureBuilder(
        future: formFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(child: Text('Tidak ada data'));
            }
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                FormResult form = snapshot.data[index];
                var finalStatus;
                var status = form.status;
                switch (status) {
                  case 2:
                    finalStatus = 'Menunggu Diproses';
                    break;
                  case 3:
                    finalStatus = 'Diproses';
                    break;
                  case 4:
                    finalStatus = 'Proses Validasi';
                    break;
                  case 5:
                    finalStatus = 'Proses Validasi 2';
                    break;
                  case 6:
                    finalStatus = 'Selesai';
                }
                return InkWell(
                  onTap: () {
                    if (userRole == 'Tax' || userRole == 'Billing' || userRole == 'Admin') {
                      Get.to(() => TaxAndBillingDetail(), arguments: form);
                    }
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.boxOpen),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      finalStatus,
                                      style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold),
                                    ),
                                    Text(DateFormat('d MMM y').format(form.requestDate)),
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    if (form.tax == 1)
                                      Container(
                                        color: Colors.green[100],
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text('Tax',
                                              style: GoogleFonts.sourceSansPro(
                                                  color: Colors.green, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    if (form.billing == 1)
                                      Container(
                                        color: Colors.green[100],
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text('Billing',
                                              style: GoogleFonts.sourceSansPro(
                                                  color: Colors.green, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 1),
                          if (form.transactions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'List Surat Jalan',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: form.transactions.length,
                                    itemBuilder: (ctx, i) {
                                      if (form.transactions[i].type == null) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(form.transactions[i].name),
                                                Spacer(),
                                                if (form.transactions[i].selected == 0)
                                                  Icon(Icons.check, color: Colors.red)
                                                else
                                                  Icon(Icons.check, color: Colors.green),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(form.transactions[i].name),
                                              Spacer(),
                                              if (form.transactions[i].type == 1)
                                                Text('Tax',
                                                    style: TextStyle(
                                                        color: form.transactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red))
                                              else
                                                Text('Billing',
                                                    style: TextStyle(
                                                        color: form.transactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red)),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          if (form.otherTransactions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'List Surat Lain / Non Barcode',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: form.otherTransactions.length,
                                    itemBuilder: (ctx, i) {
                                      if (form.otherTransactions[i].type == null) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(form.otherTransactions[i].name),
                                                Spacer(),
                                                if (form.otherTransactions[i].selected == 0)
                                                  Icon(Icons.check, color: Colors.red)
                                                else
                                                  Icon(Icons.check, color: Colors.green),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(form.otherTransactions[i].name),
                                              Spacer(),
                                              if (form.otherTransactions[i].type == 1)
                                                Text('Tax',
                                                    style: TextStyle(
                                                        color: form.otherTransactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red))
                                              else
                                                Text('Billing',
                                                    style: TextStyle(
                                                        color: form.otherTransactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red)),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          if (userRole != 'Courier' &&
                              userRole != 'Warehouse' &&
                              userRole != 'Stock' &&
                              form.transactions.isNotEmpty &&
                              form.otherTransactions.isEmpty &&
                              !form.transactions.map((e) => e.selected2).contains(0))
                            Center(
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      icon: Icon(Icons.qr_code_scanner),
                                      onPressed: () {
                                        finalScanQRTax();
                                      },
                                    ),
                                  ),
                                  // Text('Scan QR'),
                                  SizedBox(height: 5),
                                ],
                              ),
                            )
                          else if (userRole != 'Courier' &&
                              userRole != 'Warehouse' &&
                              userRole != 'Stock' &&
                              form.otherTransactions.isNotEmpty &&
                              form.transactions.isEmpty &&
                              !form.otherTransactions.map((e) => e.selected2).contains(0))
                            Center(
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      icon: Icon(Icons.qr_code_scanner),
                                      onPressed: () {
                                        finalScanQRTax();
                                      },
                                    ),
                                  ),
                                  // Text('Scan QR'),
                                  SizedBox(height: 5),
                                ],
                              ),
                            )
                          else if (userRole != 'Courier' &&
                              userRole != 'Warehouse' &&
                              userRole != 'Stock' &&
                              !form.transactions.map((e) => e.selected2).contains(0) &&
                              !form.otherTransactions.map((e) => e.selected2).contains(0))
                            Center(
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      icon: Icon(Icons.qr_code_scanner),
                                      onPressed: () {
                                        finalScanQRTax();
                                      },
                                    ),
                                  ),
                                  // Text('Scan QR'),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget stockUI() {
    return Expanded(
      child: FutureBuilder(
        future: formFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(child: Text('Tidak ada data'));
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                FormResult form = snapshot.data[index];
                var finalStatus;
                var status = form.status;
                switch (status) {
                  case 2:
                    finalStatus = 'Menunggu Diproses';
                    break;
                  case 3:
                    finalStatus = 'Diproses';
                    break;
                  case 4:
                    finalStatus = 'Proses Validasi';
                    break;
                  case 5:
                    finalStatus = 'Proses Validasi 2';
                    break;
                  case 6:
                    finalStatus = 'Selesai';
                }
                return InkWell(
                  onTap: () {
                    if (userRole == 'Stock' || userRole == 'Admin') {
                      Get.to(() => StockPageDetail(), arguments: form);
                    }
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.boxOpen),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      finalStatus,
                                      style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold),
                                    ),
                                    Text(DateFormat('d MMM y').format(form.requestDate)),
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    if (form.tax == 1)
                                      Container(
                                        color: Colors.green[100],
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text('Tax',
                                              style: GoogleFonts.sourceSansPro(
                                                  color: Colors.green, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    if (form.billing == 1)
                                      Container(
                                        color: Colors.green[100],
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text('Billing',
                                              style: GoogleFonts.sourceSansPro(
                                                  color: Colors.green, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 1),
                          if (form.transactions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'List Surat Jalan',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: form.transactions.length,
                                    itemBuilder: (ctx, i) {
                                      if (form.transactions[i].type == null) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(form.transactions[i].name),
                                                Spacer(),
                                                if (form.transactions[i].selected == 0)
                                                  Icon(Icons.check, color: Colors.red)
                                                else
                                                  Icon(Icons.check, color: Colors.green),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(form.transactions[i].name),
                                              Spacer(),
                                              if (form.transactions[i].type == 1)
                                                Text('Tax',
                                                    style: TextStyle(
                                                        color: form.transactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red))
                                              else
                                                Text('Billing',
                                                    style: TextStyle(
                                                        color: form.transactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red)),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          if (form.otherTransactions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'List Surat Lain / Non Barcode',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: form.otherTransactions.length,
                                    itemBuilder: (ctx, i) {
                                      if (form.otherTransactions[i].type == null) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(form.otherTransactions[i].name),
                                                Spacer(),
                                                if (form.otherTransactions[i].selected == 0)
                                                  Icon(Icons.check, color: Colors.red)
                                                else
                                                  Icon(Icons.check, color: Colors.green),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(form.otherTransactions[i].name),
                                              Spacer(),
                                              if (form.otherTransactions[i].type == 1)
                                                Text('Tax',
                                                    style: TextStyle(
                                                        color: form.otherTransactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red))
                                              else
                                                Text('Billing',
                                                    style: TextStyle(
                                                        color: form.otherTransactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red)),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (userRole != 'Courier' &&
                                    userRole != 'Warehouse' &&
                                    userRole != 'Tax' &&
                                    userRole != 'Billing' &&
                                    form.status == 3 &&
                                    form.transactions.isNotEmpty &&
                                    !form.transactions.map((e) => e.selected).contains(0))
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        finalScanQRStock();
                                      },
                                      icon: Icon(Icons.qr_code_scanner_rounded),
                                    ),
                                  )
                                else if (userRole != 'Courier' &&
                                    userRole != 'Warehouse' &&
                                    userRole != 'Tax' &&
                                    userRole != 'Billing' &&
                                    form.status == 3 &&
                                    form.otherTransactions.isNotEmpty &&
                                    !form.otherTransactions.map((e) => e.selected).contains(0))
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        finalScanQRStock();
                                      },
                                      icon: Icon(Icons.qr_code_scanner_rounded),
                                    ),
                                  )
                                else if (userRole != 'Courier' &&
                                    userRole != 'Warehouse' &&
                                    userRole != 'Tax' &&
                                    userRole != 'Billing' &&
                                    form.status == 5 &&
                                    form.transactions.isNotEmpty &&
                                    !form.transactions.map((e) => e.type).contains(null) &&
                                    !form.transactions.map((e) => e.selected2).contains(0))
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              height: Get.height * .60,
                                              child: Center(
                                                child: QrImage(
                                                  data: 'FORM-ID-${form.id}',
                                                  size: Get.width * .80,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.qr_code_rounded),
                                    ),
                                  )
                                else if (userRole != 'Courier' &&
                                    userRole != 'Warehouse' &&
                                    userRole != 'Tax' &&
                                    userRole != 'Billing' &&
                                    form.status == 5 &&
                                    form.otherTransactions.isNotEmpty &&
                                    !form.otherTransactions.map((e) => e.type).contains(null) &&
                                    !form.otherTransactions.map((e) => e.selected2).contains(0))
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              height: Get.height * .60,
                                              child: Center(
                                                child: QrImage(
                                                  data: 'FORM-ID-${form.id}',
                                                  size: Get.width * .80,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.qr_code_rounded),
                                    ),
                                  ),
                                // if (form.status == 1 && !form.transactions.map((e) => e.selected).contains(0))
                                //   Text('Scan QR')
                                // else if (form.status == 3 &&
                                //     !form.transactions.map((e) => e.type).contains(null) &&
                                //     !form.transactions.map((e) => e.selected2).contains(0))
                                //   Text('Show QR'),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget courierUI() {
    return Expanded(
      child: FutureBuilder(
        future: formFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(child: Text('Tidak ada data'));
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                FormResult form = snapshot.data[index];
                var finalStatus;
                var status = form.status;
                switch (status) {
                  case 2:
                    finalStatus = 'Menunggu Diproses';
                    break;
                  case 3:
                    finalStatus = 'Diproses';
                    break;
                  case 4:
                    finalStatus = 'Proses Validasi';
                    break;
                  case 5:
                    finalStatus = 'Proses Validasi 2';
                    break;
                  case 6:
                    finalStatus = 'Selesai';
                }
                return InkWell(
                  onTap: () {
                    if (userRole == 'Courier' || userRole == 'Admin') {
                      Get.to(() => CourierPageDetail(), arguments: form);
                    }
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.boxOpen),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (form.task == null && form.status == 0)
                                      Text(
                                        'Menunggu Diproses',
                                        style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold),
                                      ),
                                    if (form.task == null && form.status == 1)
                                      Text(
                                        'Diproses',
                                        style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold),
                                      ),
                                    if (form.task != null)
                                      Text(
                                        finalStatus,
                                        style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold),
                                      ),
                                    Text(DateFormat('d MMM y').format(form.requestDate)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 1),
                          if (form.task != null)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Surat Jalan',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  Text('Surat jalan yang harus diambil ${form.task}'),
                                ],
                              ),
                            ),
                          if (form.otherTask != null)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Surat Lain / Non Barcode',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  Text('Surat lain yang harus diambil ${form.otherTask}'),
                                ],
                              ),
                            ),
                          if (form.transactions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'List Surat Jalan',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: form.transactions.length,
                                    itemBuilder: (ctx, i) {
                                      if (form.transactions[i].type == null) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(form.transactions[i].name),
                                                Spacer(),
                                                if (form.transactions[i].selected == 1)
                                                  Icon(Icons.check, color: Colors.green)
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(form.transactions[i].name),
                                              Spacer(),
                                              if (form.transactions[i].type == 1)
                                                Text('Tax',
                                                    style: TextStyle(
                                                        color: form.transactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red))
                                              else
                                                Text('Billing',
                                                    style: TextStyle(
                                                        color: form.transactions[i].selected2 == 1
                                                            ? Colors.green
                                                            : Colors.red)),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Total ${form.transactions.length}',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          if (form.otherTransactions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'List Surat Lain / Non Barcode',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: form.otherTransactions.length,
                                    itemBuilder: (ctx, i) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(form.otherTransactions[i].name),
                                              Spacer(),
                                              if (form.otherTransactions[i].selected == 1)
                                                Icon(Icons.check, color: Colors.green)
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Total ${form.otherTransactions.length}',
                                    style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          if (form.task == null)
                            Column(
                              children: [
                                Divider(thickness: 1),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('From',
                                              style: GoogleFonts.sourceSansPro(fontSize: 17, color: Colors.grey)),
                                          Text(form.fromUser.name,
                                              style:
                                                  GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('To',
                                              style: GoogleFonts.sourceSansPro(fontSize: 17, color: Colors.grey)),
                                          Text(form.toUser.name,
                                              style:
                                                  GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (form.task == null &&
                              form.status == 0 &&
                              form.otherTask == form.otherTransactions.length &&
                              userRole != 'Stock' &&
                              userRole != 'Warehouse' &&
                              userRole != 'Tax' &&
                              userRole != 'Billing')
                            Center(
                              child: Card(
                                elevation: 4,
                                child: IconButton(
                                  onPressed: () {
                                    finalScanQRCourier();
                                  },
                                  icon: Icon(Icons.qr_code_scanner_rounded),
                                ),
                              ),
                            )
                          else if (form.task == null &&
                              form.status == 1 &&
                              userRole != 'Stock' &&
                              userRole != 'Warehouse' &&
                              userRole != 'Tax' &&
                              userRole != 'Billing')
                            Center(
                              child: Card(
                                elevation: 4,
                                child: IconButton(
                                  onPressed: () {
                                    showMaterialModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          color: Colors.white,
                                          height: Get.height * .60,
                                          child: Center(
                                            child: QrImage(
                                              data: 'FORM-ID-${form.id}',
                                              size: Get.width * .80,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.qr_code_rounded),
                                ),
                              ),
                            ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (userRole != 'Stock' &&
                                    userRole != 'Warehouse' &&
                                    userRole != 'Tax' &&
                                    userRole != 'Billing' &&
                                    form.status == 2 &&
                                    form.task == form.transactions.length &&
                                    form.task != null)
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        finalScanQRCourier();
                                      },
                                      icon: Icon(Icons.qr_code_scanner),
                                    ),
                                  )
                                else if (userRole != 'Stock' &&
                                    userRole != 'Warehouse' &&
                                    userRole != 'Tax' &&
                                    userRole != 'Billing' &&
                                    form.status == 3 &&
                                    !form.transactions.map((e) => e.selected).contains(0))
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              height: Get.height * .60,
                                              child: Center(
                                                child: QrImage(
                                                  data: 'FORM-ID-${form.id}',
                                                  size: Get.width * .80,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.qr_code_rounded),
                                    ),
                                  )
                                else if (userRole != 'Stock' &&
                                    userRole != 'Warehouse' &&
                                    userRole != 'Tax' &&
                                    userRole != 'Billing' &&
                                    form.status == 3 &&
                                    !form.otherTransactions.map((e) => e.selected).contains(0) &&
                                    form.transactions.length == 0)
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              height: Get.height * .60,
                                              child: Center(
                                                child: QrImage(
                                                  data: 'FORM-ID-${form.id}',
                                                  size: Get.width * .80,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.qr_code_rounded),
                                    ),
                                  )
                                else if (userRole != 'Stock' &&
                                    userRole != 'Warehouse' &&
                                    userRole != 'Tax' &&
                                    userRole != 'Billing' &&
                                    form.status == 3 &&
                                    !form.transactions.map((e) => e.selected).contains(0) &&
                                    !form.otherTransactions.map((e) => e.selected).contains(0))
                                  Card(
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              height: Get.height * .60,
                                              child: Center(
                                                child: QrImage(
                                                  data: 'FORM-ID-${form.id}',
                                                  size: Get.width * .80,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.qr_code_rounded),
                                    ),
                                  ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget warehouseUI() {
    return Expanded(
      child: FutureBuilder(
        future: formFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(
                child: Text('Tidak ada data'),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                FormResult form = snapshot.data[index];
                var finalStatus;
                var status = form.status;
                switch (status) {
                  case 2:
                    finalStatus = 'Menunggu Diproses';
                    break;
                  case 3:
                    finalStatus = 'Diproses';
                    break;
                  case 4:
                    finalStatus = 'Proses Validasi';
                    break;
                  case 5:
                    finalStatus = 'Proses Validasi 2';
                    break;
                  case 6:
                    finalStatus = 'Selesai';
                }
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.boxOpen),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(finalStatus, style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold)),
                                      Text(DateFormat('d MMM y').format(form.requestDate)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            if (userRole == 'Admin' || userRole == 'Warehouse')
                              IconButton(
                                onPressed: () {
                                  showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: SizedBox(
                                              width: Get.width,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (form.transactions.length > 0) {
                                                    Get.back();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        backgroundColor: Colors.red,
                                                        duration: Duration(seconds: 5),
                                                        content: ListTile(
                                                          title: Text('Gagal hapus surat jalan',
                                                              style: TextStyle(
                                                                  color: Colors.white, fontWeight: FontWeight.bold)),
                                                          subtitle: Text(
                                                              'Tidak bisa menghapus surat jalan yang sudah diproses',
                                                              style: TextStyle(color: Colors.white)),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    deleteFormWarehouse(form.id);
                                                  }
                                                },
                                                child: Text('Hapus'),
                                                style: ElevatedButton.styleFrom(primary: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.more_vert),
                              ),
                          ],
                        ),
                        Divider(thickness: 1),
                        if (form.task != null)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Surat Jalan',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                                Text('Surat jalan yang harus diambil ${form.task}'),
                              ],
                            ),
                          ),
                        if (form.otherTask != null)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Surat Lain / Non Barcode',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                                Text('Surat lain yang harus diambil ${form.otherTask}'),
                              ],
                            ),
                          ),
                        if (form.transactions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'List Surat Jalan',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                                SizedBox(height: 10),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: form.transactions.length,
                                  itemBuilder: (ctx, i) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(form.transactions[i].name),
                                            Spacer(),
                                            if (form.transactions[i].selected == 1) Icon(Icons.check),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Total ${form.transactions.length}',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        if (form.otherTransactions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'List Surat Lain / Non Barcode',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                                SizedBox(height: 10),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: form.otherTransactions.length,
                                  itemBuilder: (ctx, i) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(form.otherTransactions[i].name),
                                            Spacer(),
                                            if (form.otherTransactions[i].selected == 1) Icon(Icons.check),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Total ${form.otherTransactions.length}',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        if (userRole != 'Stock' &&
                            userRole != 'Courier' &&
                            userRole != 'Tax' &&
                            userRole != 'Billing' &&
                            form.task == form.transactions.length &&
                            form.task != 0)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  elevation: 4,
                                  child: IconButton(
                                    onPressed: () {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            color: Colors.white,
                                            height: Get.height * .60,
                                            child: Center(
                                              child: QrImage(
                                                data: 'FORM-ID-${form.id}',
                                                size: Get.width * .80,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.qr_code_rounded),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget requestUI() {
    return Expanded(
      child: FutureBuilder(
        future: formFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return Center(
                child: Text('Tidak ada data'),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                FormResult form = snapshot.data[index];
                var finalStatus;
                var status = form.status;
                switch (status) {
                  case 0:
                    finalStatus = 'Menunggu Diproses';
                    break;
                  case 1:
                    finalStatus = 'Diproses';
                    break;
                  case 2:
                    finalStatus = 'Proses Validasi';
                    break;
                  case 3:
                    finalStatus = 'Proses Validasi 2';
                    break;
                  default:
                    finalStatus = 'Selesai';
                }
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.boxOpen),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(finalStatus, style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold)),
                                Text(DateFormat('d MMM y').format(form.requestDate)),
                              ],
                            ),
                            Spacer(),
                            if (form.fromUser.username == username || userRole == 'Admin')
                              IconButton(
                                onPressed: () {
                                  showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: SizedBox(
                                              width: Get.width,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (form.otherTransactions.length > 0) {
                                                    Get.back();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        backgroundColor: Colors.red,
                                                        duration: Duration(seconds: 5),
                                                        content: ListTile(
                                                          title: Text('Gagal hapus surat lain',
                                                              style: TextStyle(
                                                                  color: Colors.white, fontWeight: FontWeight.bold)),
                                                          subtitle: Text(
                                                              'Tidak bisa menghapus surat lain yang sudah diproses',
                                                              style: TextStyle(color: Colors.white)),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    deleteFormRequest(form.id);
                                                  }
                                                },
                                                child: Text('Hapus'),
                                                style: ElevatedButton.styleFrom(primary: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.more_vert),
                              ),
                          ],
                        ),
                        Divider(thickness: 1),
                        // Padding(
                        //   padding: const EdgeInsets.all(10),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text(
                        //         'Surat Jalan',
                        //         style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                        //       ),
                        //       Text('Surat jalan yang harus diambil ${form.task}'),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Surat Lain / Non Barcode',
                                style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Text('Surat lain yang harus diambil ${form.otherTask}'),
                            ],
                          ),
                        ),
                        // if (form.transactions.isNotEmpty)
                        //   Padding(
                        //     padding: const EdgeInsets.all(10),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text(
                        //           'List Surat Jalan',
                        //           style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                        //         ),
                        //         SizedBox(height: 10),
                        //         ListView.builder(
                        //           physics: NeverScrollableScrollPhysics(),
                        //           shrinkWrap: true,
                        //           itemCount: form.transactions.length,
                        //           itemBuilder: (ctx, i) {
                        //             return Column(
                        //               crossAxisAlignment: CrossAxisAlignment.start,
                        //               children: [
                        //                 Row(
                        //                   children: [
                        //                     Text(form.transactions[i].name),
                        //                     Spacer(),
                        //                     if (form.transactions[i].selected == 1) Icon(Icons.check),
                        //                   ],
                        //                 ),
                        //                 SizedBox(height: 10),
                        //               ],
                        //             );
                        //           },
                        //         ),
                        //         SizedBox(height: 10),
                        //         Text(
                        //           'Total ${form.transactions.length}',
                        //           style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        if (form.otherTransactions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'List Surat Lain / Non Barcode',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                                SizedBox(height: 10),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: form.otherTransactions.length,
                                  itemBuilder: (ctx, i) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(form.otherTransactions[i].name),
                                            Spacer(),
                                            if (form.otherTransactions[i].selected == 1) Icon(Icons.check),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Total ${form.otherTransactions.length}',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        Divider(thickness: 1),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('From', style: GoogleFonts.sourceSansPro(fontSize: 17, color: Colors.grey)),
                                  Text(form.fromUser.name,
                                      style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('To', style: GoogleFonts.sourceSansPro(fontSize: 17, color: Colors.grey)),
                                  Text(form.toUser.name,
                                      style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (form.otherTask == form.otherTransactions.length &&
                            form.status == 0 &&
                            form.fromUser.username == username)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  elevation: 4,
                                  child: IconButton(
                                    onPressed: () {
                                      if (username == form.fromUser.username) {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              height: Get.height * .60,
                                              child: Center(
                                                child: QrImage(
                                                  data: 'FORM-ID-${form.id}',
                                                  size: Get.width * .80,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Not Authorized'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.qr_code_rounded),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (form.otherTask == form.otherTransactions.length &&
                            form.status == 0 &&
                            form.fromUser.role == 'Admin')
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  elevation: 4,
                                  child: IconButton(
                                    onPressed: () {
                                      if (username == form.fromUser.username || userRole == 'Admin') {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              color: Colors.white,
                                              height: Get.height * .60,
                                              child: Center(
                                                child: QrImage(
                                                  data: 'FORM-ID-${form.id}',
                                                  size: Get.width * .80,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Not Authorized'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.qr_code_rounded),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (form.status == 1 && form.toUser.username == username)
                          Center(
                            child: Card(
                              elevation: 4,
                              child: IconButton(
                                onPressed: () {
                                  finalScanQRCourier();
                                },
                                icon: Icon(Icons.qr_code_scanner),
                              ),
                            ),
                          )
                        else if (form.status == 1 && userRole == 'Admin')
                          Center(
                            child: Card(
                              elevation: 4,
                              child: IconButton(
                                onPressed: () {
                                  finalScanQRCourier();
                                },
                                icon: Icon(Icons.qr_code_scanner),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
