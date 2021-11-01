import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanner/Screens/request-detail.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';

class Request extends StatefulWidget {
  const Request({Key key}) : super(key: key);

  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> {
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
          data.fromUser.id,
          data.toUser.id,
          data.requestDate,
          data.pickUpDate,
          DateTime.now(),
        )
            .then((value) {
          find.getHttp();
          find.tabController.animateTo(5);
        }, onError: (e) {});
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
          find.tabController.animateTo(5);
          find.getHttp();
        }, onError: (e) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetX<Controller>(builder: (controller) {
      if (controller.requestLoading.value == true) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.requestData.isEmpty) {
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
      return RefreshIndicator(
        onRefresh: controller.getHttp,
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(10),
          itemCount: controller.requestData.length,
          itemBuilder: (context, index) {
            final form = controller.requestData[index];
            var finalStatus;
            switch (form.status) {
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
            return InkWell(
              onTap: () {
                if (form.status == 0 && controller.username.value == form.fromUser.username) {
                  Get.to(() => RequestDetail(), arguments: form);
                } else if (form.status == -1 && controller.username.value == form.fromUser.username) {
                  Get.to(() => RequestDetail(), arguments: form);
                } else if (form.status == -1 && controller.role.value == "Admin") {
                  Get.to(() => RequestDetail(), arguments: form);
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
                          if (form.fromUser.username == controller.username.value || controller.role.value == 'Admin')
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
                                                  controller.apiController.deleteFormRequest(form.id).then((value) {
                                                    Get.back();
                                                    controller.getHttp();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        duration: Duration(seconds: 5),
                                                        content: Text('Berhasil hapus',
                                                            style: TextStyle(
                                                                color: Colors.white, fontWeight: FontWeight.bold)),
                                                      ),
                                                    );
                                                  }, onError: (e) {
                                                    print(e);
                                                  });
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
                      if (form.status == -1)
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipe',
                                style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Text('Non Kurir'),
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
                                  //         if (form.otherTransactions[i].selected == 1) Icon(Icons.check),
                                  //       ],
                                  //     ),
                                  //     SizedBox(height: 10),
                                  //   ],
                                  // );
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('${i + 1}. ${form.otherTransactions[i].name}'),
                                    trailing: form.otherTransactions[i].selected == 1 ? Icon(Icons.check) : SizedBox(),
                                  );
                                },
                              ),
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
                          form.fromUser.username == controller.username.value)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                elevation: 4,
                                child: IconButton(
                                  onPressed: () {
                                    if (controller.username.value == form.fromUser.username) {
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
                                    if (controller.username.value == form.fromUser.username ||
                                        controller.role.value == 'Admin') {
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
                      else if (form.status == 1 && form.toUser.username == controller.username.value)
                        Center(
                          child: Card(
                            elevation: 4,
                            child: IconButton(
                              onPressed: () {
                                scanQR();
                              },
                              icon: Icon(Icons.qr_code_scanner),
                            ),
                          ),
                        )
                      else if (form.status == 1 && controller.role.value == 'Admin')
                        Center(
                          child: Card(
                            elevation: 4,
                            child: IconButton(
                              onPressed: () {
                                scanQR();
                              },
                              icon: Icon(Icons.qr_code_scanner),
                            ),
                          ),
                        )
                      else if (form.status == -1 &&
                          form.fromUser.username == controller.username.value &&
                          form.otherTransactions.isNotEmpty)
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
                        )
                      else if (form.status == -1 &&
                          form.toUser.username == controller.username.value &&
                          form.otherTransactions.isNotEmpty)
                        Center(
                          child: Card(
                            elevation: 4,
                            child: IconButton(
                              onPressed: () {
                                scanQR();
                              },
                              icon: Icon(Icons.qr_code_scanner),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
