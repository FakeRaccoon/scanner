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

class Stock extends StatefulWidget {
  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {
  Future scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        List transactions = response.data['result'][0]['transactions'];
        if (response.data['result'][0]['status'] == 1 && !transactions.contains(0)) {
          final data = response.data['result'][0];
          updateForm(data['id'], data['task'], data['request_date'], data['pick_up_date']);
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

  // getForm() async {
  //   final response = await Dio().get('http://192.168.5.101:8000/api/form/status', queryParameters: {'status': 1});
  //   return formResultFromJson(jsonEncode(response.data['result']));
  // }

  getForm() async {
    final response = await Dio().get(apiUrl + 'api/form');
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  updateForm(id, task, requestDate, pickupDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'status': 2,
      'request_date': requestDate,
      'pick_up_date': pickupDate,
      'received_date': DateTime.now().toString(),
    });
    if (response.statusCode == 200) {
      setState(() {
        futureForm = getForm();
      });
    }
    print(response.data);
  }

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.offAll(() => Home());
            },
          ),
          title: Text(
            'Stock',
            style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
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
                            Get.to(() => StockPageDetail(), arguments: form);
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
                                      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                                      child: Text('Tambahkan surat jalan'),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                      child: Text('List surat jalan',
                                          style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
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
                                              if (form.transactions[i].selected == 0)
                                                Icon(Icons.check, color: Colors.red)
                                              else
                                                Icon(Icons.check, color: Colors.green),
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

class StockPageDetail extends StatefulWidget {
  @override
  _StockPageDetailState createState() => _StockPageDetailState();
}

class _StockPageDetailState extends State<StockPageDetail> {
  FormResult form = Get.arguments;

  Future scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (form.transactions.map((e) => e.name).contains(barcodeScanRes)) {
        int transactionIndex = form.transactions.indexWhere((element) => element.name == barcodeScanRes);
        setState(() {
          updateTransactions(form.transactions[transactionIndex].id, 1, null);
        });
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

  List<Map<String, dynamic>> type = [];
  List<Map<String, dynamic>> otherType = [];

  updateTransactions(int id, int selected, int type) async {
    final response = await Dio().post(apiUrl + 'api/transaction/update', data: {
      'id': id,
      'selected': selected,
      'selected2': 0,
      'type': type,
    });
    if (response.statusCode == 200) {
      setState(() {
        formFuture = getFormId(form.id);
      });
      final getResponse = await Dio().get(apiUrl + 'api/form/id', queryParameters: {
        'id': form.id,
      });
      List transactions = getResponse.data['result'][0]['transactions'];
      if (!transactions.map((e) => e['type']).contains(null)) {
        updateForm(form.id, form.task, form.otherTask, form.requestDate, form.pickUpDate, form.receivedDate);
      }
    }
    print(response.data);
  }

  updateOtherTransactions(int id, int selected, int type) async {
    final response = await Dio().post(apiUrl + 'api/otherTransaction/update', data: {
      'id': id,
      'selected': selected,
      'selected2': 0,
      'type': type,
    });
    if (response.statusCode == 200) {
      setState(() {
        formFuture = getFormId(form.id);
      });
      final getResponse = await Dio().get(apiUrl + 'api/form/id', queryParameters: {
        'id': form.id,
      });
      List transactions = getResponse.data['result'][0]['transactions'];
      List otherTransactions = getResponse.data['result'][0]['other_transactions'];
      if (!transactions.map((e) => e['type']).contains(null) && !otherTransactions.map((e) => e['type']).contains(null)) {
        updateForm(form.id, form.task, form.otherTask, form.requestDate, form.pickUpDate, form.receivedDate);
      }
    }
    print(response.data);
  }

  getFormId(int id) async {
    final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {
      'id': id,
    });
    print(response.data['result'][0]);
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  updateForm(int id, int task, otherTask, requestDate, pickupDate, receiveDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'other_task': otherTask,
      'status': 5,
      'request_date': requestDate.toString(),
      'pick_up_date': pickupDate.toString(),
      'received_date': receiveDate.toString(),
    });
    if (response.statusCode == 200) {
      Get.offAll(() => Home());
    }
    print(response.data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formFuture = getFormId(form.id);
  }

  Future formFuture;

  @override
  Widget build(BuildContext context) {
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
    return WillPopScope(
      onWillPop: () => Get.offAll(() => Home()),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Stock Detail",
            style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: FutureBuilder(
          future: formFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                return Text('Data tidak ditemukan');
              }
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
                              if (formResult.status == 3)
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
                                    if (formResult.transactions[i].type == null) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (formResult.status == 3)
                                            Row(
                                              children: [
                                                Text(formResult.transactions[i].name),
                                                Spacer(),
                                                if (formResult.transactions[i].selected == 0)
                                                  Icon(Icons.check, color: Colors.red)
                                                else
                                                  Icon(Icons.check, color: Colors.green),
                                                SizedBox(width: 10),
                                              ],
                                            )
                                          else
                                            Row(
                                              children: [
                                                Text(formResult.transactions[i].name),
                                                Spacer(),
                                                Checkbox(
                                                  activeColor: Colors.grey[900],
                                                  splashRadius: 1,
                                                  value: formResult.transactions[i].selected1,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      formResult.transactions[i].selected1 = value;
                                                      if (value == true) {
                                                        type.add({
                                                          "id": formResult.transactions[i].id,
                                                          "name": formResult.transactions[i].name,
                                                          "selected": formResult.transactions[i].selected,
                                                        });
                                                      } else if (value == false) {
                                                        type.removeWhere(
                                                            (element) => element.containsValue(formResult.transactions[i].name));
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      );
                                    }
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(formResult.transactions[i].name),
                                            Spacer(),
                                            if (formResult.transactions[i].type == 1) Text('Tax') else Text('Billing'),
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
                                    if (formResult.otherTransactions[i].type == null) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (formResult.status == 1)
                                            Row(
                                              children: [
                                                Text(formResult.otherTransactions[i].name),
                                                Spacer(),
                                                Checkbox(
                                                  activeColor: Colors.grey[900],
                                                  splashRadius: 1,
                                                  value: formResult.otherTransactions[i].selected == 0 ? false : true,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      formResult.otherTransactions[i].selected1 = value;
                                                      if (value == true) {
                                                        updateOtherTransactions(formResult.otherTransactions[i].id, 1, null);
                                                      } else if (value == false) {
                                                        updateOtherTransactions(formResult.otherTransactions[i].id, 0, null);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            )
                                          else
                                            Row(
                                              children: [
                                                Text(formResult.otherTransactions[i].name),
                                                Spacer(),
                                                Checkbox(
                                                  activeColor: Colors.grey[900],
                                                  splashRadius: 1,
                                                  value: formResult.otherTransactions[i].selected1,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      formResult.otherTransactions[i].selected1 = value;
                                                      if (value == true) {
                                                        otherType.add({
                                                          "id": formResult.otherTransactions[i].id,
                                                          "name": formResult.otherTransactions[i].name,
                                                          "selected": formResult.otherTransactions[i].selected,
                                                        });
                                                      } else if (value == false) {
                                                        otherType.removeWhere((element) =>
                                                            element.containsValue(formResult.otherTransactions[i].name));
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      );
                                    }
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(formResult.otherTransactions[i].name),
                                            Spacer(),
                                            if (formResult.otherTransactions[i].type == 1) Text('Tax') else Text('Billing'),
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
                        SizedBox(height: 10),
                        if (formResult.status == 3)
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
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      primary: Colors.grey[900],
                                    ),
                                    onPressed: () {
                                      type.forEach((element) {
                                        updateTransactions(element['id'], element['selected'], 1);
                                      });
                                      otherType.forEach((element) {
                                        updateOtherTransactions(element['id'], element['selected'], 1);
                                      });
                                      otherType.clear();
                                      type.clear();
                                    },
                                    child: Text('Tax'),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      primary: Colors.grey[900],
                                    ),
                                    onPressed: () {
                                      type.forEach((element) {
                                        updateTransactions(element['id'], element['selected'], 2);
                                      });
                                      otherType.forEach((element) {
                                        updateOtherTransactions(element['id'], element['selected'], 2);
                                      });
                                      otherType.clear();
                                      type.clear();
                                    },
                                    child: Text('Billing'),
                                  ),
                                ),
                              ),
                            ],
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
