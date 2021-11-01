import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scanner/Screens/tax-billing-detail.dart';
import 'package:scanner/Services/barcode-service.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';

class TaxAndBilling extends StatefulWidget {
  const TaxAndBilling({Key key}) : super(key: key);

  @override
  _TaxAndBillingState createState() => _TaxAndBillingState();
}

class _TaxAndBillingState extends State<TaxAndBilling> {
  final find = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    return GetX<Controller>(builder: (controller) {
      if (controller.taxData.isEmpty) {
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
      return RefreshIndicator(
        color: Colors.black,
        onRefresh: find.getHttp,
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: controller.taxData.length,
          itemBuilder: (context, index) {
            FormResult form = controller.taxData[index];
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
                if (controller.role.value == 'Tax' ||
                    controller.role.value == 'Billing' ||
                    controller.role.value == 'Admin') {
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
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: form.transactions.length,
                                itemBuilder: (ctx, i) {
                                  if (form.transactions[i].toUser == null) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${i + 1}. ${form.transactions[i].name}'),
                                      trailing: form.transactions[i].selected == 0
                                          ? Icon(Icons.check, color: Colors.red)
                                          : Icon(Icons.check, color: Colors.green),
                                    );
                                  }
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('${i + 1}. ${form.transactions[i].name}'),
                                    trailing: Text(
                                      form.transactions[i].toUser.name,
                                      style: TextStyle(
                                        color: form.transactions[i].selected2 == 1 ? Colors.green : Colors.red,
                                      ),
                                    ),
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
                      if (form.transactions.map((e) => e.toUser.username).contains(controller.username.value) &&
                          form.transactions != null &&
                          !form.transactions.map((e) => e.selected2).contains(0))
                        Center(
                          child: Column(
                            children: [
                              Card(
                                elevation: 4,
                                child: IconButton(
                                  icon: Icon(Icons.qr_code_scanner),
                                  onPressed: () {
                                    controller.barcodeController.finalScanQRTax().then((value) {
                                      FormResult data = value[0];
                                      find.apiController
                                          .updateForm(
                                        data.id,
                                        data.task,
                                        null,
                                        data.note,
                                        6,
                                        null,
                                        null,
                                        data.requestDate,
                                        data.pickUpDate,
                                        DateTime.now(),
                                      )
                                          .then((value) {
                                        find.tabController.animateTo(5);
                                        find.getHttp();
                                      });
                                      // updateFormFinalFinal(
                                      //   data['id'],
                                      //   data['task'],
                                      //   data['note'],
                                      //   6,
                                      //   null,
                                      //   null,
                                      //   data['request_date'],
                                      //   data['pick_up_date'],
                                      //   data['received_date'],
                                      // );
                                    });
                                  },
                                ),
                              ),
                              // Text('Scan QR'),
                              SizedBox(height: 5),
                            ],
                          ),
                        )
                      else if (controller.role.value == 'Admin' &&
                          form.transactions != null &&
                          !form.transactions.map((e) => e.selected2).contains(0))
                        Center(
                          child: Column(
                            children: [
                              Card(
                                elevation: 4,
                                child: IconButton(
                                  icon: Icon(Icons.qr_code_scanner),
                                  onPressed: () {
                                    controller.barcodeController.finalScanQRTax().then((value) {
                                      FormResult data = value[0];
                                      find.apiController
                                          .updateForm(
                                        data.id,
                                        data.task,
                                        null,
                                        data.note,
                                        6,
                                        null,
                                        null,
                                        data.requestDate,
                                        data.pickUpDate,
                                        DateTime.now(),
                                      )
                                          .then((value) {
                                        find.tabController.animateTo(5);
                                        find.getHttp();
                                      });
                                    });
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
        ),
      );
    });
  }
}
