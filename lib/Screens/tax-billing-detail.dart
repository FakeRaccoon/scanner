import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';
import 'package:scanner/Screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaxAndBillingDetail extends StatefulWidget {
  @override
  _TaxAndBillingDetailState createState() => _TaxAndBillingDetailState();
}

class _TaxAndBillingDetailState extends State<TaxAndBillingDetail> {
  FormResult form = Get.arguments;

  SharedPreferences sharedPreferences;

  Future scanQR() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String role = sharedPreferences.getString('role');
    String username = sharedPreferences.getString('username');
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (form.transactions.map((e) => e.name).contains(barcodeScanRes)) {
        String roleResult;
        int transactionIndex = form.transactions.indexWhere((element) => element.name == barcodeScanRes);
        if (form.transactions[transactionIndex].toUser.username == username || role == 'Admin') {
          // roleResult = "Tax";
          // if (role == roleResult || role == 'Admin') {
          //   updateTransactions(form.transactions[transactionIndex].id, form.transactions[transactionIndex].type, 1, 1);
          // }
          updateTransactions(
              form.transactions[transactionIndex].id, form.transactions[transactionIndex].toUser.id, 1, 1);
        }
        // } else if (form.transactions[transactionIndex].type == 2) {
        //   roleResult = "Billing";
        //   if (role == roleResult || role == 'Admin') {
        //     updateTransactions(form.transactions[transactionIndex].id, form.transactions[transactionIndex].type, 1, 1);
        //   }
        // }
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

  updateTransactions(int id, int toId, int selected, int selected2) async {
    final response = await Dio().post(apiUrl + 'api/transaction/update', data: {
      'id': id,
      'to_id': toId,
      'selected': selected,
      'selected2': selected2,
    });
    find.getDetail(form.id);
    find.getHttp();
    print(response.data);
  }

  updateOtherTransactions(int id, type, int selected, int selected2) async {
    final response = await Dio().post(apiUrl + 'api/otherTransaction/update', data: {
      'id': id,
      'type': type,
      'selected': selected,
      'selected2': selected2,
    });
    find.getDetail(form.id);
    print(response.data);
  }

  final Controller find = Get.find();

  @override
  void initState() {
    super.initState();
    formFuture = getFormId(form.id);
    find.getDetail(form.id);
    getRole();
  }

  Future<void> getRole() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      role = sharedPreferences.getString('role');
      username = sharedPreferences.getString('username');
    });
  }

  Future<Null> refresh() async {
    setState(() {
      formFuture = getFormId(form.id);
    });
  }

  Future formFuture;

  String role;
  String username;

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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Tax & Billing Detail",
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
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
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
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: formResult.transactions.length,
                                  itemBuilder: (ctx, i) {
                                    if (formResult.transactions[i].toUser.username == username || role == 'Admin') {
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text('${i + 1}. ${formResult.transactions[i].name}'),
                                        trailing: formResult.transactions[i].selected2 == 0
                                            ? SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Checkbox(
                                                  value: formResult.transactions[i].selected2 == 0 ? false : true,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      updateTransactions(
                                                        formResult.transactions[i].id,
                                                        formResult.transactions[i].toUser.id,
                                                        1,
                                                        1,
                                                      );
                                                    });
                                                  },
                                                ),
                                              )
                                            : Text(formResult.transactions[i].toUser.name,
                                                style: TextStyle(color: Colors.green)),
                                      );
                                    }
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${i + 1}. ${formResult.transactions[i].name}'),
                                      trailing: Text(
                                        formResult.transactions[i].toUser.name,
                                        style: TextStyle(
                                            color: formResult.transactions[i].selected2 == 1
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                    );
                                    // return Column(
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     Row(
                                    //       children: [
                                    //         Text(formResult.transactions[i].name),
                                    //         Spacer(),
                                    //         if (formResult.transactions[i].type == 1)
                                    //           Text('Tax',
                                    //               style: TextStyle(
                                    //                   color:
                                    //                       formResult.transactions[i].selected2 == 1 ? Colors.green : Colors.red))
                                    //         else
                                    //           Text('Billing',
                                    //               style: TextStyle(
                                    //                   color:
                                    //                       formResult.transactions[i].selected2 == 1 ? Colors.green : Colors.red)),
                                    //         SizedBox(width: 10),
                                    //       ],
                                    //     ),
                                    //     SizedBox(height: 10),
                                    //   ],
                                    // );
                                  },
                                ),
                              ],
                            ),
                          ),
                        // if (formResult.otherTransactions.isNotEmpty)
                        //   Padding(
                        //     padding: const EdgeInsets.all(10),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text(
                        //           'List Surat Lain / Non Barcode',
                        //           style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                        //         ),
                        //         SizedBox(height: 10),
                        //         ListView.builder(
                        //           physics: NeverScrollableScrollPhysics(),
                        //           shrinkWrap: true,
                        //           itemCount: formResult.otherTransactions.length,
                        //           itemBuilder: (ctx, i) {
                        //             var roleCheck = formResult.otherTransactions[i].type == 1 ? 'Tax' : 'Billing';
                        //             return Column(
                        //               crossAxisAlignment: CrossAxisAlignment.start,
                        //               children: [
                        //                 Row(
                        //                   children: [
                        //                     Text(formResult.otherTransactions[i].name),
                        //                     Spacer(),
                        //                     if (role == roleCheck || role == 'Admin')
                        //                       Checkbox(
                        //                         activeColor: Colors.grey[900],
                        //                         splashRadius: 1,
                        //                         value: formResult.otherTransactions[i].selected2 == 0 ? false : true,
                        //                         onChanged: (bool value) {
                        //                           setState(() {
                        //                             if (value == false) {
                        //                               updateOtherTransactions(
                        //                                 formResult.otherTransactions[i].id,
                        //                                 formResult.otherTransactions[i].type,
                        //                                 1,
                        //                                 0,
                        //                               );
                        //                             } else if (value == true) {
                        //                               updateOtherTransactions(
                        //                                 formResult.otherTransactions[i].id,
                        //                                 formResult.otherTransactions[i].type,
                        //                                 1,
                        //                                 1,
                        //                               );
                        //                             }
                        //                           });
                        //                         },
                        //                       )
                        //                     else if (formResult.otherTransactions[i].type == 1)
                        //                       Text(
                        //                         'Tax',
                        //                         style: TextStyle(
                        //                             color: formResult.otherTransactions[i].selected2 == 1
                        //                                 ? Colors.green
                        //                                 : Colors.red),
                        //                       )
                        //                     else if (formResult.otherTransactions[i].type == 2)
                        //                       Text('Billing',
                        //                           style: TextStyle(
                        //                               color: formResult.otherTransactions[i].selected2 == 1
                        //                                   ? Colors.green
                        //                                   : Colors.red)),
                        //                   ],
                        //                 ),
                        //                 SizedBox(height: 10),
                        //               ],
                        //             );
                        //           },
                        //         ),
                        //       ],
                        //     ),
                        //   ),
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
                              find.getHttp();
                              Get.back();
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
}
