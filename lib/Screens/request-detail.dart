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
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';
import 'package:scanner/Screens/home.dart';
import 'package:scanner/temp-transactions-model.dart';

class RequestDetail extends StatefulWidget {
  @override
  _RequestDetailState createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
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
    find.getDetail(form.id);
    find.getHttp();
  }

  createOtherTransactions(formId, name) async {
    final response = await Dio().post(apiUrl + 'api/otherTransaction/create', data: {
      'form_id': formId,
      'name': name,
      'selected': 0,
      'selected2': 0,
    });
    print(response.data);
    find.getDetail(form.id);
    find.getHttp();
  }

  Future updateForm(id, task, otherTask, status, note, toUser, requestDate, pickUpDate, receivedDate) async {
    final response = await Dio().post(apiUrl + 'api/form/update', data: {
      'id': id,
      'task': task,
      'other_task': otherTask,
      'status': status,
      'note': note,
      'to_id': toUser,
      'request_date': requestDate,
      'pick_up_date': pickUpDate,
      'received_date': receivedDate,
    });
    if (response.statusCode == 200) {
      find.getDetail(form.id);
      find.getHttp();
      Get.back();
    }
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
          // updateForm(data['id'], data['task'], data['request_date'], data['received_date']);
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

  Future deleteOtherTransaction(int transactionId) async {
    final response = await Dio().post(apiUrl + 'api/otherTransaction/delete', data: {'id': transactionId});
    if (response.statusCode == 200) {
      find.getDetail(form.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Data berhasil dihapus',
                style: GoogleFonts.sourceSansPro(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    find.getDetail(form.id);
  }

  TextEditingController otherTransactionController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  final Controller find = Get.find();

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
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Request Detail",
          style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
            find.getHttp();
            find.detailData.clear();
          },
        ),
      ),
      body: GetX<Controller>(
        builder: (controller) {
          if (controller.detailData.isNotEmpty) {
            FormResult formResult = controller.detailData[0];
            noteController.text = formResult.note;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
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
                                    moreBottomSheet(context, formResult);
                                  },
                                ),
                              if (formResult.task == null &&
                                  formResult.otherTask != formResult.otherTransactions.length)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    // scanQR();
                                    moreBottomSheet(context, formResult);
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
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: formResult.otherTransactions.length,
                                  itemBuilder: (ctx, i) {
                                    // return Column(
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     Row(
                                    //       children: [
                                    //         Text(formResult.otherTransactions[i].name),
                                    //         Spacer(),
                                    //         if (formResult.otherTransactions[i].selected == 1) Icon(Icons.check),
                                    //       ],
                                    //     ),
                                    //     SizedBox(height: 10),
                                    //   ],
                                    // );
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${i + 1}. ${formResult.otherTransactions[i].name}'),
                                      trailing: SizedBox(
                                        child: IconButton(
                                          onPressed: () {
                                            deleteOtherTransaction(formResult.otherTransactions[i].id);
                                          },
                                          icon: Icon(Icons.delete),
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catatan',
                                style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              TextFormField(
                                maxLength: 50,
                                controller: noteController,
                                decoration: InputDecoration(border: InputBorder.none, hintText: 'Tambah catatan'),
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
                              if (noteController.text.isNotEmpty) {
                                updateForm(
                                  formResult.id,
                                  formResult.task,
                                  formResult.otherTask,
                                  formResult.status,
                                  noteController.text,
                                  formResult.toUser.id,
                                  formResult.requestDate.toString(),
                                  formResult.pickUpDate,
                                  formResult.receivedDate,
                                );
                              } else {
                                find.getHttp();
                                Get.back();
                              }
                            },
                            child: Text('Selesai'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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

  moreBottomSheet(BuildContext context, FormResult form) {
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
                  Text('Surat Non Barcode',
                      style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
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
