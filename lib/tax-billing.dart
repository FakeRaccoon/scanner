import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanner/form-model.dart';
import 'package:scanner/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaxAndBilling extends StatefulWidget {
  @override
  _TaxAndBillingState createState() => _TaxAndBillingState();
}

class _TaxAndBillingState extends State<TaxAndBilling> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureForm = getForm();
  }

  updateForm(id, task, requestDate, pickupDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'status': 3,
      'request_date': requestDate,
      'pick_up_date': pickupDate,
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {
      setState(() {
        futureForm = getForm();
      });
    }
    print(response.data);
  }

  Future scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        if (response.data['result'][0]['status'] == 2) {
          final data = response.data['result'][0];
          updateForm(data['id'], data['task'], data['request_date'], data['pick_up_date'], data['received_date']);
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

  Future futureForm;

  getForm() async {
    final response = await Dio().get(apiUrl + 'api/form');
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Get.offAll(() => Home()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.offAll(() => Home());
            },
          ),
          title: Text(
            'Tax & Billing',
            style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            scanQR();
          },
          child: Icon(Icons.qr_code_scanner),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: FutureBuilder(
                future: futureForm,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.isEmpty) {
                      return Text('data kosong');
                    }
                    return ListView.builder(
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
                          default:
                            finalStatus = 'Selesai';
                        }
                        return InkWell(
                          onTap: () {
                            Get.to(() => TaxAndBillingDetail(), arguments: form);
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
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: Icon(Icons.more_vert),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(thickness: 1),
                                  SizedBox(height: 10),
                                  if (form.transactions.length == 0)
                                    Text('Tambahkan surat jalan')
                                  else
                                    Text('List surat jalan',
                                        style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(10),
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
                                              form.transactions[i].selected == 0 ? SizedBox() : Icon(Icons.check),
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
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaxAndBillingDetail extends StatefulWidget {
  @override
  _TaxAndBillingDetailState createState() => _TaxAndBillingDetailState();
}

class _TaxAndBillingDetailState extends State<TaxAndBillingDetail> {
  FormResult form = Get.arguments;

  SharedPreferences sharedPreferences;

  Future scanQR() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var role = sharedPreferences.getString('role');
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (form.transactions.map((e) => e.name).contains(barcodeScanRes)) {
        String roleResult;
        int transactionIndex = form.transactions.indexWhere((element) => element.name == barcodeScanRes);
        if (form.transactions[transactionIndex].type == 1) {
          roleResult = "Tax";
          if (role == roleResult || role == 'Admin') {
            updateTransactions(form.transactions[transactionIndex].id, form.transactions[transactionIndex].type, 1, 1);
          }
        } else if (form.transactions[transactionIndex].type == 2) {
          roleResult = "Billing";
          if (role == roleResult || role == 'Admin') {
            updateTransactions(form.transactions[transactionIndex].id, form.transactions[transactionIndex].type, 1, 1);
          }
        }
        setState(() {});
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

  getFormId(int id) async {
    final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {
      'id': id,
    });
    print(response.data['result'][0]);
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  updateTransactions(int id, type, int selected, int selected2) async {
    final response = await Dio().post(apiUrl + 'api/transaction/update', data: {
      'id': id,
      'type': type,
      'selected': selected,
      'selected2': selected2,
    });
    setState(() {
      formFuture = getFormId(form.id);
    });
    print(response.data);
  }

  updateOtherTransactions(int id, type, int selected, int selected2) async {
    final response = await Dio().post(apiUrl + 'api/otherTransaction/update', data: {
      'id': id,
      'type': type,
      'selected': selected,
      'selected2': selected2,
    });
    setState(() {
      formFuture = getFormId(form.id);
    });
    print(response.data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formFuture = getFormId(form.id);
    getRole();
  }

  Future<void> getRole() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      role = sharedPreferences.getString('role');
    });
  }

  Future formFuture;

  String role;

  @override
  Widget build(BuildContext context) {
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
    return WillPopScope(
      onWillPop: () => Get.offAll(() => Home()),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Tax & Billing Detail",
            style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: FutureBuilder(
          future: formFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              FormResult formResult = snapshot.data[0];
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                                  Text(DateFormat('d MMM y').format(formResult.requestDate)),
                                ],
                              ),
                              Spacer(),
                              if (formResult.transactions.map((e) => e.selected2).contains(0) ||
                                  formResult.otherTransactions.map((e) => e.selected2).contains(0))
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(Icons.qr_code_scanner_rounded),
                                  onPressed: () {
                                    scanQR();
                                  },
                                ),
                            ],
                          ),
                        ),
                        Divider(thickness: 1),
                        if (formResult.transactions.isNotEmpty)
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
                                  itemCount: formResult.transactions.length,
                                  itemBuilder: (ctx, i) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(formResult.transactions[i].name),
                                            Spacer(),
                                            if (formResult.transactions[i].type == 1)
                                              Text('Tax',
                                                  style: TextStyle(
                                                      color:
                                                          formResult.transactions[i].selected2 == 1 ? Colors.green : Colors.red))
                                            else
                                              Text('Billing',
                                                  style: TextStyle(
                                                      color:
                                                          formResult.transactions[i].selected2 == 1 ? Colors.green : Colors.red)),
                                            SizedBox(width: 10),
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
                        if (formResult.otherTransactions.isNotEmpty)
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
                                  itemCount: formResult.otherTransactions.length,
                                  itemBuilder: (ctx, i) {
                                    var roleCheck = formResult.otherTransactions[i].type == 1 ? 'Tax' : 'Billing';
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(formResult.otherTransactions[i].name),
                                            Spacer(),
                                            if (role == roleCheck || role == 'Admin')
                                              Checkbox(
                                                activeColor: Colors.grey[900],
                                                splashRadius: 1,
                                                value: formResult.otherTransactions[i].selected2 == 0 ? false : true,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    if (value == false) {
                                                      updateOtherTransactions(
                                                        formResult.otherTransactions[i].id,
                                                        formResult.otherTransactions[i].type,
                                                        1,
                                                        0,
                                                      );
                                                    } else if (value == true) {
                                                      updateOtherTransactions(
                                                        formResult.otherTransactions[i].id,
                                                        formResult.otherTransactions[i].type,
                                                        1,
                                                        1,
                                                      );
                                                    }
                                                  });
                                                },
                                              )
                                            else if (formResult.otherTransactions[i].type == 1)
                                              Text(
                                                'Tax',
                                                style: TextStyle(
                                                    color: formResult.otherTransactions[i].selected2 == 1
                                                        ? Colors.green
                                                        : Colors.red),
                                              )
                                            else if (formResult.otherTransactions[i].type == 2)
                                              Text('Billing',
                                                  style: TextStyle(
                                                      color: formResult.otherTransactions[i].selected2 == 1
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
                        // if (formResult.transactions.map((e) => e.selected2).contains(0) &&
                        //     formResult.otherTransactions.map((e) => e.selected2).contains(0))
                        SizedBox(
                          width: Get.width,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              primary: Colors.grey[900],
                            ),
                            onPressed: () {
                              Get.offAll(() => Home());
                            },
                            child: Text('Selesai'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
