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
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';
import 'package:scanner/Screens/home.dart';
import 'package:scanner/user_model.dart';

class StockPageDetail extends StatefulWidget {
  @override
  _StockPageDetailState createState() => _StockPageDetailState();
}

class _StockPageDetailState extends State<StockPageDetail> {
  FormResult form = Get.arguments;

  final Controller find = Get.find();

  Future scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (form.transactions.map((e) => e.name).contains(barcodeScanRes)) {
        int transactionIndex = form.transactions.indexWhere((element) => element.name == barcodeScanRes);
        setState(() {
          updateTransactions(form.transactions[transactionIndex].id, 1, null, null);
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

  Future updateTransactions(int id, int selected, int type, int toId) async {
    try {
      final response = await Dio().post(apiUrl + 'api/transaction/update', data: {
        'id': id,
        'selected': selected,
        'selected2': 0,
        'type': type,
        'to_id': toId,
      });
      find.getDetail(form.id);
      find.getHttp();
      return response.data;
    } on DioError catch (e) {
      print(e.response);
    }
  }

  getFormId(int id) async {
    final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {
      'id': id,
    });
    print(response.data['result'][0]);
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  Future getDetail() async {
    // find.getHttp();
    // find.getDetail(form.id);
    // final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {
    //   'id': form.id,
    // });
    // List<FormResult> transactions = response.data['result'][0];
    // if (!transactions.map((e) => e.toUser).contains(null)) {
    //   updateForm(form.id, form.task, form.otherTask, form.note, form.requestDate, form.pickUpDate, form.receivedDate);
    // }
    find.apiController.getFormDetail(form.id).then((value) {
      FormResult data = value[0];
      if (!data.transactions.map((e) => e.toUser).contains(null)) {
        updateForm(
          data.id,
          data.task,
          data.otherTask,
          data.note,
          data.requestDate,
          data.pickUpDate,
          data.receivedDate,
        );
      }
    });
  }

  updateForm(int id, int task, otherTask, note, requestDate, pickUpDate, receivedDate) async {
    try {
      final response = await Dio().post(apiUrl + 'api/form/update', data: {
        'id': id,
        'task': task,
        'other_task': otherTask,
        'note': note,
        'status': 5,
        'request_date': requestDate == null ? null : requestDate.toString(),
        'pick_up_date': pickUpDate == null ? null : pickUpDate.toString(),
        'received_date': receivedDate == null ? null : receivedDate.toString(),
      });
      print(response.data);
      find.getHttp();
      Get.back();
    } on DioError catch (e) {
      print(e.response.data);
    }
  }

  int userId;

  @override
  void initState() {
    super.initState();
    find.getDetail(form.id);
  }

  TextEditingController userController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Stock Detail",
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
                              if (formResult.status == 3 && formResult.transactions.map((e) => e.selected).contains(0))
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
                                    if (formResult.transactions[i].toUser == null) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (formResult.status == 3)
                                            // Row(
                                            //   children: [
                                            //     Text(formResult.transactions[i].name),
                                            //     Spacer(),
                                            //     if (formResult.transactions[i].selected == 0)
                                            //       Icon(Icons.check, color: Colors.red)
                                            //     else
                                            //       Icon(Icons.check, color: Colors.green),
                                            //     SizedBox(width: 10),
                                            //   ],
                                            // )
                                            ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Text('${i + 1}. ${formResult.transactions[i].name}'),
                                                trailing: formResult.transactions[i].selected == 0
                                                    ? SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: Checkbox(
                                                          value:
                                                              formResult.transactions[i].selected == 0 ? false : true,
                                                          onChanged: (bool value) {
                                                            setState(() {
                                                              updateTransactions(formResult.transactions[i].id,
                                                                  value == false ? 0 : 1, null, null);
                                                            });
                                                          },
                                                        ),
                                                      )
                                                    : Icon(Icons.check, color: Colors.green))
                                          else
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: Text('${i + 1}. ${formResult.transactions[i].name}'),
                                              trailing: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Checkbox(
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
                                                        type.removeWhere((element) =>
                                                            element.containsValue(formResult.transactions[i].name));
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          // Row(
                                          //   children: [
                                          //     Text(formResult.transactions[i].name),
                                          //     Spacer(),
                                          //     SizedBox(
                                          //       height: 24,
                                          //       width: 24,
                                          //       child: Checkbox(
                                          //         activeColor: Colors.grey[900],
                                          //         splashRadius: 1,
                                          //         value: formResult.transactions[i].selected1,
                                          //         onChanged: (bool value) {
                                          //           setState(() {
                                          //             formResult.transactions[i].selected1 = value;
                                          //             if (value == true) {
                                          //               type.add({
                                          //                 "id": formResult.transactions[i].id,
                                          //                 "name": formResult.transactions[i].name,
                                          //                 "selected": formResult.transactions[i].selected,
                                          //               });
                                          //             } else if (value == false) {
                                          //               type.removeWhere((element) =>
                                          //                   element.containsValue(formResult.transactions[i].name));
                                          //             }
                                          //           });
                                          //         },
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      );
                                    }
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${i + 1}. ${formResult.transactions[i].name}'),
                                      trailing: Text(formResult.transactions[i].toUser.name),
                                    );
                                    // return Column(
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     Row(
                                    //       children: [
                                    //         Text(formResult.transactions[i].name),
                                    //         Spacer(),
                                    //         if (formResult.transactions[i].type == 1)
                                    //           Text('Tax')
                                    //         else
                                    //           Text('Billing'),
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
                        if (formResult.status == 3)
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
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tujuan',
                                  style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                TextFormField(
                                  onTap: () {
                                    buildShowMaterialModalBottomSheet(context);
                                  },
                                  controller: userController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Pilih tujuan',
                                      border: InputBorder.none,
                                      suffix: Icon(Icons.arrow_drop_down)),
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  width: Get.width,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (userController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            content: Text(
                                              'Pilih tujuan pengiriman',
                                              style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold),
                                            )));
                                      } else {
                                        type.forEach((element) {
                                          print('${element['name']} + ${userController.text} + $userId');
                                          updateTransactions(element['id'], 1, null, userId).then((value) {
                                            getDetail();
                                          });
                                        });
                                        type.clear();
                                        userController.clear();
                                      }
                                    },
                                    child: Text('Kirim'),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.grey[900],
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                  ),
                                ),
                              ],
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

  buildShowMaterialModalBottomSheet(BuildContext context) {
    return showMaterialModalBottomSheet(
      expand: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (context) {
        return GetX<Controller>(
          builder: (controller) {
            if (controller.userData.isNotEmpty) {
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
                      itemCount: controller.userData.length,
                      itemBuilder: (BuildContext context, int index) {
                        UserResult user = controller.userData[index];
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
                        UserResult user = controller.userData[index];
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
            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
