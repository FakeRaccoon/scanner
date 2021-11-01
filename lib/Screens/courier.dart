import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanner/Screens/courier-detail.dart';
import 'package:scanner/Services/barcode-service.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';

class Courier extends StatefulWidget {
  const Courier({Key key}) : super(key: key);

  @override
  _CourierState createState() => _CourierState();
}

class _CourierState extends State<Courier> {
  final find = Get.find<Controller>();

  scanQR() {
    find.barcodeController.finalScanQRCourier().then((value) {
      FormResult data = value[0];
      if (data.status == -1) {
        find.apiController
            .updateForm(
          data.id,
          data.task,
          data.otherTask,
          data.note,
          6,
          null,
          data.toUser.id,
          data.requestDate,
          data.pickUpDate,
          DateTime.now(),
        )
            .then((value) {
          find.getHttp();
        }, onError: (e) {});
      }
      if (data.status == 0) {
        find.apiController
            .updateForm(
          data.id,
          data.task,
          data.otherTask,
          data.note,
          1,
          data.fromUser.id,
          data.toUser.id,
          data.requestDate,
          DateTime.now(),
          data.receivedDate,
        )
            .then((value) {
          find.getHttp();
        }, onError: (e) {});
        // updateFormSL(
        //   data['id'],
        //   data['task'],
        //   data['other_task'],
        //   data['note'],
        //   data['to_user']['id'],
        //   1,
        //   data['request_date'],
        //   DateTime.now().toString(),
        //   data['received_date'],
        // );
      }
      if (data.status == 1) {
        find.apiController
            .updateForm(
          data.id,
          data.task,
          data.otherTask,
          data.note,
          6,
          data.fromUser.id,
          data.toUser.id,
          data.requestDate,
          data.pickUpDate,
          DateTime.now(),
        )
            .then((value) {
          find.getHttp();
        }, onError: (e) {});
        // updateFormSL2(
        //   data['id'],
        //   data['task'],
        //   data['other_task'],
        //   data['note'],
        //   data['to_user']['id'],
        //   6,
        //   data['request_date'],
        //   data['pick_up_date'],
        //   DateTime.now().toString(),
        // );
      }
      if (data.status == 2) {
        find.apiController
            .updateForm(
          data.id,
          data.task,
          data.otherTask,
          data.note,
          3,
          null,
          null,
          data.requestDate,
          DateTime.now(),
          data.receivedDate,
        )
            .then((value) {
          find.getHttp();
        }, onError: (e) {});
        // updateFormSJ(
        //   data['id'],
        //   data['task'],
        //   data['other_task'],
        //   data['note'],
        //   3,
        //   data['request_date'],
        //   DateTime.now().toString(),
        //   data['received_date'],
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.black,
      onRefresh: find.getHttp,
      child: GetX<Controller>(builder: (controller) {
        if (controller.courierData.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.getHttp,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: Get.height * 0.40),
                    Text('Tidak ada data'),
                  ],
                ),
              ),
            ),
          );
        }
        if (controller.taxLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(10),
          itemCount: controller.courierData.length,
          itemBuilder: (context, index) {
            FormResult form = controller.courierData[index];
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
                if (controller.role.value == 'Courier' || controller.role.value == 'Admin') {
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
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: form.transactions.length,
                                itemBuilder: (ctx, i) {
                                  if (form.transactions[i].type == null) {
                                    // return Column(
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     Row(
                                    //       children: [
                                    //         Text(form.transactions[i].name),
                                    //         Spacer(),
                                    //         if (form.transactions[i].selected == 1)
                                    //           Icon(Icons.check, color: Colors.green)
                                    //       ],
                                    //     ),
                                    //     SizedBox(height: 10),
                                    //   ],
                                    // );
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${i + 1}. ${form.transactions[i].name}'),
                                      trailing: form.transactions[i].selected == 1
                                          ? SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Icon(Icons.check, color: Colors.green),
                                            )
                                          : SizedBox(),
                                    );
                                  }
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('${i + 1}. ${form.transactions[i].name}'),
                                    trailing: Text(form.transactions[i].toUser.name),
                                  );
                                  // return Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: [
                                  //     Row(
                                  //       children: [
                                  //         Text(form.transactions[i].name),
                                  //         Spacer(),
                                  //         if (form.transactions[i].type == 1)
                                  //           Text('Tax',
                                  //               style: TextStyle(
                                  //                   color: form.transactions[i].selected2 == 1
                                  //                       ? Colors.green
                                  //                       : Colors.red))
                                  //         else
                                  //           Text('Billing',
                                  //               style: TextStyle(
                                  //                   color: form.transactions[i].selected2 == 1
                                  //                       ? Colors.green
                                  //                       : Colors.red)),
                                  //       ],
                                  //     ),
                                  //     SizedBox(height: 10),
                                  //   ],
                                  // );
                                },
                              ),
                              // SizedBox(height: 10),
                              // Text(
                              //   'Total ${form.transactions.length}',
                              //   style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                              // ),
                              if (form.note != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Catatan',
                                      style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text(form.note ?? ''),
                                  ],
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
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: form.otherTransactions.length,
                                itemBuilder: (ctx, i) {
                                  // return Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: [
                                  //     Row(
                                  //       children: [
                                  //         Text(form.otherTransactions[i].name),
                                  //         Spacer(),
                                  //         if (form.otherTransactions[i].selected == 1)
                                  //           Icon(Icons.check, color: Colors.green)
                                  //       ],
                                  //     ),
                                  //     SizedBox(height: 10),
                                  //   ],
                                  // );
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('${i + 1}. ${form.otherTransactions[i].name}'),
                                    trailing: form.otherTransactions[i].selected == 1
                                        ? Icon(Icons.check, color: Colors.green)
                                        : SizedBox(),
                                  );
                                },
                              ),
                              // SizedBox(height: 10),
                              // Text(
                              //   'Total ${form.otherTransactions.length}',
                              //   style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                              // ),
                              if (form.note != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Catatan',
                                      style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text(form.note ?? ''),
                                  ],
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
                          ],
                        ),
                      if (form.task == null &&
                          form.status == 0 &&
                          form.otherTask == form.otherTransactions.length &&
                          controller.role.value != 'Stock' &&
                          controller.role.value != 'Warehouse' &&
                          controller.role.value != 'Tax' &&
                          controller.role.value != 'Billing')
                        Center(
                          child: Card(
                            elevation: 4,
                            child: IconButton(
                              onPressed: () {
                                scanQR();
                              },
                              icon: Icon(Icons.qr_code_scanner_rounded),
                            ),
                          ),
                        )
                      else if (form.task == null &&
                          form.status == 1 &&
                          controller.role.value != 'Stock' &&
                          controller.role.value != 'Warehouse' &&
                          controller.role.value != 'Tax' &&
                          controller.role.value != 'Billing')
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
                            if (controller.role.value != 'Stock' &&
                                controller.role.value != 'Warehouse' &&
                                controller.role.value != 'Tax' &&
                                controller.role.value != 'Billing' &&
                                form.status == 2 &&
                                form.task == form.transactions.length &&
                                form.task != null)
                              Card(
                                elevation: 4,
                                child: IconButton(
                                  onPressed: () {
                                    scanQR();
                                  },
                                  icon: Icon(Icons.qr_code_scanner),
                                ),
                              )
                            else if (controller.role.value != 'Stock' &&
                                controller.role.value != 'Warehouse' &&
                                controller.role.value != 'Tax' &&
                                controller.role.value != 'Billing' &&
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
                            else if (controller.role.value != 'Stock' &&
                                controller.role.value != 'Warehouse' &&
                                controller.role.value != 'Tax' &&
                                controller.role.value != 'Billing' &&
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
                            else if (controller.role.value != 'Stock' &&
                                controller.role.value != 'Warehouse' &&
                                controller.role.value != 'Tax' &&
                                controller.role.value != 'Billing' &&
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
      }),
    );
  }
}
