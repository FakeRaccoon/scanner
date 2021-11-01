import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';
import 'package:scanner/Screens/stock-detail.dart';

class Stock extends StatefulWidget {
  const Stock({Key key}) : super(key: key);

  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {
  final find = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.black,
      onRefresh: find.getHttp,
      child: GetX<Controller>(builder: (controller) {
        if (controller.stockLoading.value == true) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.stockData.isEmpty) {
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
          itemCount: controller.stockData.length,
          itemBuilder: (context, index) {
            FormResult form = controller.stockData[index];
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
                if (controller.role.value == 'Stock' || controller.role.value == 'Admin') {
                  Get.to(() => StockPageDetail(), arguments: form);
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
                                          color: form.transactions[i].selected2 == 1 ? Colors.green : Colors.red),
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
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (controller.role.value != 'Courier' &&
                                controller.role.value != 'Warehouse' &&
                                controller.role.value != 'Tax' &&
                                controller.role.value != 'Billing' &&
                                form.status == 3 &&
                                form.transactions.isNotEmpty &&
                                !form.transactions.map((e) => e.selected).contains(0))
                              Card(
                                elevation: 4,
                                child: IconButton(
                                  onPressed: () {
                                    // updateForm2(data['id'], data['task'], data['note'], data['request_date'], data['pick_up_date']);
                                    controller.barcodeController.finalScanQRStock().then((value) {
                                      FormResult data = value[0];
                                      controller.apiController
                                          .updateForm(
                                            data.id,
                                            data.task,
                                            null,
                                            data.note,
                                            4,
                                            null,
                                            null,
                                            data.requestDate,
                                            data.pickUpDate,
                                            data.receivedDate,
                                          )
                                          .then((value) => controller.getHttp());
                                    });
                                  },
                                  icon: Icon(Icons.qr_code_scanner_rounded),
                                ),
                              )
                            else if (controller.role.value != 'Courier' &&
                                controller.role.value != 'Warehouse' &&
                                controller.role.value != 'Tax' &&
                                controller.role.value != 'Billing' &&
                                form.status == 3 &&
                                form.otherTransactions.isNotEmpty &&
                                !form.otherTransactions.map((e) => e.selected).contains(0))
                              Card(
                                elevation: 4,
                                child: IconButton(
                                  onPressed: () {
                                    controller.barcodeController.finalScanQRStock();
                                  },
                                  icon: Icon(Icons.qr_code_scanner_rounded),
                                ),
                              )
                            else if (controller.role.value != 'Courier' &&
                                controller.role.value != 'Warehouse' &&
                                controller.role.value != 'Tax' &&
                                controller.role.value != 'Billing' &&
                                form.status == 5 &&
                                form.transactions.isNotEmpty &&
                                !form.transactions.map((e) => e.toUser).contains(null) &&
                                !form.transactions.map((e) => e.selected2).contains(0))
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
                            else if (controller.role.value != 'Courier' &&
                                controller.role.value != 'Warehouse' &&
                                controller.role.value != 'Tax' &&
                                controller.role.value != 'Billing' &&
                                form.status == 5 &&
                                form.otherTransactions.isNotEmpty &&
                                !form.otherTransactions.map((e) => e.type).contains(null) &&
                                !form.otherTransactions.map((e) => e.selected2).contains(0))
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
                            // if (form.status == 1 && !form.transactions.map((e) => e.selected).contains(0))
                            //   Text('Scan QR')
                            // else if (form.status == 3 &&
                            //     !form.transactions.map((e) => e.type).contains(null) &&
                            //     !form.transactions.map((e) => e.selected2).contains(0))
                            //   Text('Show QR'),
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
