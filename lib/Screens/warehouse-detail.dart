import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';

class WarehouseDetail extends StatefulWidget {
  const WarehouseDetail({Key key}) : super(key: key);

  @override
  _WarehouseDetailState createState() => _WarehouseDetailState();
}

class _WarehouseDetailState extends State<WarehouseDetail> {
  TextEditingController otherTransactionController = TextEditingController();
  TextEditingController manualTransactionController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  final Controller find = Get.find();

  final FormResult form = Get.arguments;

  refresh() {
    find.getDetail(form.id);
    find.getHttp();
  }

  @override
  void initState() {
    super.initState();
    find.getDetail(form.id);
  }

  @override
  Widget build(BuildContext context) {
    var finalStatus;
    var status = form.status;
    switch (status) {
      case -1:
        finalStatus = 'Menunggu Diproses';
        break;
      case 0:
        finalStatus = 'Menunggu Diproses';
        break;
      case 2:
        finalStatus = 'Menunggu Diproses';
        break;
      case 3:
        finalStatus = 'Proses Validasi';
        break;
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Warehouse Detail",
          style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
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
                                    finalStatus ?? '',
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
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${i + 1}. ${formResult.transactions[i].name}'),
                                      trailing: formResult.transactions[i].selected == 1
                                          ? SizedBox(height: 24, width: 24, child: Icon(Icons.check))
                                          : IconButton(
                                              onPressed: () {
                                                find.apiController
                                                    .deleteTransaction(formResult.transactions[i].id)
                                                    .then((value) {
                                                  refresh();
                                                }, onError: (e) {
                                                  print(e);
                                                });
                                              },
                                              icon: Icon(Icons.delete),
                                              highlightColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                            ),
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
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: formResult.otherTransactions.length,
                                  itemBuilder: (ctx, i) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${i + 1}. ${formResult.otherTransactions[i].name}'),
                                      trailing: formResult.otherTransactions[i].selected == 1
                                          ? SizedBox(height: 24, width: 24, child: Icon(Icons.check))
                                          : IconButton(
                                              onPressed: () {
                                                find.apiController
                                                    .deleteOtherTransaction(formResult.otherTransactions[i].id)
                                                    .then((value) {
                                                  refresh();
                                                }, onError: (e) {
                                                  print(e);
                                                });
                                              },
                                              icon: Icon(Icons.delete),
                                              highlightColor: Colors.transparent,
                                              splashColor: Colors.transparent,
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
                              if (noteController.text.isNotEmpty && formResult.task != null) {
                                find.apiController
                                    .updateForm(
                                  formResult.id,
                                  formResult.task,
                                  null,
                                  noteController.text,
                                  formResult.status,
                                  formResult.fromUser.id,
                                  null,
                                  formResult.requestDate != null ? formResult.requestDate.toString() : null,
                                  formResult.pickUpDate != null ? formResult.pickUpDate.toString() : null,
                                  null,
                                )
                                    .then((value) {
                                  refresh();
                                }, onError: (e) {
                                  print(e);
                                });
                              } else if (noteController.text.isNotEmpty && formResult.otherTask != null) {
                                find.apiController
                                    .updateForm(
                                  formResult.id,
                                  formResult.task,
                                  formResult.otherTask,
                                  formResult.status,
                                  noteController.text,
                                  formResult.fromUser.id,
                                  formResult.toUser.id,
                                  formResult.requestDate != null ? formResult.requestDate.toString() : null,
                                  formResult.pickUpDate != null ? formResult.pickUpDate.toString() : null,
                                  formResult.receivedDate != null ? formResult.receivedDate.toString() : null,
                                )
                                    .then((value) {
                                  refresh();
                                }, onError: (e) {
                                  print(e);
                                });
                              }
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
                    find.barcodeController.scanQR().then((value) {
                      if (!form.transactions.map((e) => e.name).contains(value)) {
                        find.apiController.createTransactions(form.id, value).then(
                              (value) => refresh(),
                              onError: (e) => print(e),
                            );
                      }
                    });
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
                Divider(thickness: 1),
                ListTile(
                  enabled: form.task != form.transactions.length,
                  onTap: () {
                    Get.back();
                    addManual(context);
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text('Tambah surat manual'),
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
                        find.apiController.createOtherTransactions(form.id, otherTransactionController.text).then(
                            (value) {
                          refresh();
                        }, onError: (e) {
                          print(e);
                        });
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

  addManual(BuildContext context) {
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
                  Text('Surat Jalan Manual',
                      style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: manualTransactionController,
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
                        find.apiController.createTransactions(form.id, manualTransactionController.text).then((value) {
                          refresh();
                        }, onError: (e) {
                          print(e);
                        });
                        Get.back();
                        manualTransactionController.clear();
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
