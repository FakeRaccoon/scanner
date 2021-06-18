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
import 'package:scanner/temp-transactions-model.dart';

class Courier extends StatefulWidget {
  @override
  _CourierState createState() => _CourierState();
}

class _CourierState extends State<Courier> {
  getForm() async {
    final response = await Dio().get(apiUrl + 'api/form');
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  Future futureForm;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureForm = getForm();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Get.offAll(() => Home()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Courier',
            style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: SingleChildScrollView(
            //       scrollDirection: Axis.horizontal,
            //       child: Row(
            //         children: [
            //           Container(
            //             decoration: BoxDecoration(
            //               border: Border.all(width: 1),
            //               borderRadius: BorderRadius.circular(20),
            //             ),
            //             child: Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Row(
            //                 children: [
            //                   Text('Semua Status'),
            //                   Icon(Icons.keyboard_arrow_down),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           SizedBox(width: 10),
            //           Container(
            //             decoration: BoxDecoration(
            //               border: Border.all(width: 1),
            //               borderRadius: BorderRadius.circular(20),
            //             ),
            //             child: Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: Row(
            //                 children: [
            //                   Text('Semua Tanggal'),
            //                   Icon(Icons.keyboard_arrow_down),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
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
                            Get.to(() => CourierPageDetail(), arguments: form);
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
                                          icon: Icon(Icons.qr_code),
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
                                  if (form.transactions.length == 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                      child: Text('Tambahkan surat jalan'),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                      child: Text('List surat jalan', style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
                                    ),
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

class CourierPageDetail extends StatefulWidget {
  @override
  _CourierPageDetailState createState() => _CourierPageDetailState();
}

class _CourierPageDetailState extends State<CourierPageDetail> {
  FormResult form = Get.arguments;

  List<Map<String, dynamic>> transactions = [];

  GlobalKey<FormState> _key = GlobalKey<FormState>();

  List temp = [];

  addTransaction() {
    form.transactions.forEach((element) {
      transactions.add({
        "form_id": element.id,
        "name": element.name,
        "selected": 0,
      });
    });
  }

  Future scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {
        'id': form.id,
      });
      List transactions = response.data['result'][0]['transactions'];
      print(transactions);
      if (transactions.map((e) => e['name']).contains(barcodeScanRes) || barcodeScanRes == "-1") {
        return;
      } else {
        createTransactions(form.id, barcodeScanRes);
        // transactions.add({
        //   "form_id": form.id,
        //   "name": barcodeScanRes,
        //   "selected": 0,
        // });
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

  getTransactions() async {
    return temporaryTransactionsFromJson(jsonEncode(transactions));
  }

  getFormId(int id) async {
    final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {
      'id': id,
    });
    print(response.data['result'][0]);
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  createTransactions(formId, name) async {
    final response = await Dio().post(apiUrl + 'api/transaction/create', data: {
      'form_id': formId,
      'name': name,
      'selected': 0,
      'selected2': 0,
    });
    print(response.data);
    setState(() {
      formFuture = getFormId(form.id);
    });
  }

  createOtherTransactions(formId, name) async {
    final response = await Dio().post(apiUrl + 'api/otherTransaction/create', data: {
      'form_id': formId,
      'name': name,
      'selected': 0,
      'selected2': 0,
    });
    print(response.data);
    setState(() {
      formFuture = getFormId(form.id);
    });
  }

  static updateForm(id, task, requestDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'status': 1,
      'request_date': requestDate,
      'pick_up_date': DateTime.now().toString(),
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {}
    print(response.data);
  }

  static Future finalScanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        if (response.data['result'][0]['status'] == 0) {
          // transactions.forEach((element) {
          //   if (form.transactions.map((e) => e.name).contains(element['name'])) {
          //     return;
          //   } else {
          //     createTransactions(form.id, element['name'], 0);
          //   }
          // });
          // Get.off(() => Home());
          // transactions.clear();
          final data = response.data['result'][0];
          updateForm(data['id'], data['task'], data['request_date'], data['received_date']);
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;
    // setState(() {});
  }

  Future formFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formFuture = getFormId(form.id);
  }

  TextEditingController otherTransactionController = TextEditingController();

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
            "Courier Detail",
            style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: FutureBuilder(
          future: formFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              FormResult formResult = snapshot.data[0];
              return Padding(
                padding: const EdgeInsets.all(8.0),
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
                              if (formResult.task != null && formResult.task != formResult.transactions.length)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    // scanQR();
                                    moreBottomSheet(context);
                                  },
                                ),
                              if (formResult.task == null && formResult.otherTask != formResult.otherTransactions.length)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    // scanQR();
                                    moreBottomSheet(context);
                                  },
                                ),
                            ],
                          ),
                        ),
                        Divider(thickness: 1),
                        if (formResult.task != null)
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
                        if (formResult.otherTask != null)
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
                                            if (formResult.transactions[i].selected == 1) Icon(Icons.check),
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
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(formResult.otherTransactions[i].name),
                                            Spacer(),
                                            if (formResult.otherTransactions[i].selected == 1) Icon(Icons.check),
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
                        SizedBox(height: 10),
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

  moreBottomSheet(BuildContext context) {
    return showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      context: context,
      builder: (context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('More', style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                ListTile(
                  enabled: form.task != form.transactions.length && form.task != null ? true : false,
                  onTap: () {
                    Get.back();
                    scanQR();
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text('Scan surat jalan'),
                ),
                Divider(thickness: 1),
                ListTile(
                  enabled: form.otherTask != form.otherTransactions.length && form.otherTask != null ? true : false,
                  onTap: () {
                    Get.back();
                    addNonBarcode(context);
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text('Tambah surat non barcode'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  addNonBarcode(BuildContext context) {
    return showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Surat Non Barcode', style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: otherTransactionController,
                    decoration: InputDecoration(labelText: 'Surat jalan'),
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
                        createOtherTransactions(form.id, otherTransactionController.text);
                        Get.back();
                        otherTransactionController.clear();
                      },
                      child: Text('Tambah'),
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
}
