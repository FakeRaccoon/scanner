import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanner/Screens/warehouse-detail.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';

class Warehouse extends StatefulWidget {
  const Warehouse({Key key}) : super(key: key);

  @override
  _WarehouseState createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse> {
  final find = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.black,
      onRefresh: find.getHttp,
      child: GetX<Controller>(builder: (controller) {
        if (controller.warehouseLoading.value == true) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.warehouseData.isEmpty) {
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
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(10),
          itemCount: controller.warehouseData.length,
          itemBuilder: (context, index) {
            FormResult form = controller.warehouseData[index];
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
                if (controller.role.value == 'Warehouse' || controller.role.value == 'Admin') {
                  Get.to(() => WarehouseDetail(), arguments: form);
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
                          if (controller.role.value == 'Admin' || controller.role.value == 'Warehouse')
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
                                                  controller.apiController.deleteFormWarehouse(form.id).then((value) {
                                                    Get.back();
                                                    find.getHttp();
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
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('${i + 1}. ${form.transactions[i].name}'),
                                    trailing: form.transactions[i].selected == 1
                                        ? SizedBox(height: 24, width: 24, child: Icon(Icons.check))
                                        : SizedBox(),
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
                      if (controller.role.value != 'Stock' &&
                          controller.role.value != 'Courier' &&
                          controller.role.value != 'Tax' &&
                          controller.role.value != 'Billing' &&
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
              ),
            );
          },
        );
      }),
    );
  }
}
