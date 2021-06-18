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
import 'package:scanner/form-model.dart';

class Warehouse extends StatefulWidget {
  @override
  _WarehouseState createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse> {
  getForm() async {
    final response = await Dio().get('http://192.168.5.101:8000/api/form');
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  getFormByDate() async {
    final response = await Dio().get('http://192.168.5.101:8000/api/form/date', queryParameters: {
      'from_date': fromDate,
      'to_date': toDate,
    });
    return formResultFromJson(jsonEncode(response.data['result']));
  }

  createForm(task) async {
    final response = await Dio().post('http://192.168.5.101:8000/api/form/create', data: {
      'status': 0,
      'task': task,
      'request_date': date.toString(),
    });
    if (response.statusCode == 200) {
      setState(() {
        formFuture = getForm();
      });
    }
    print(response.data);
  }

  Future formFuture;

  DateTime date = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  String dateFilter = 'Semua Tanggal';

  bool filtered = false;

  TextEditingController dateController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formFuture = getForm();
    fromDateController.text = DateFormat('d MMM y').format(fromDate);
    toDateController.text = DateFormat('d MMM y').format(toDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Warehouse',
          style: GoogleFonts.sourceSansPro(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dateController.text = DateFormat('d MMM y').format(date);
          addJob(context);
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: filtered,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            filtered = false;
                            dateFilter = "Semua Tanggal";
                            formFuture = getForm();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.clear),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(width: 10),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     border: Border.all(width: 1),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Row(
                    //       children: [
                    //         Text('Semua Status'),
                    //         Icon(Icons.keyboard_arrow_down),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        dateFilterBottomSheet(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(dateFilter),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: formFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty) {
                    return Center(child: Text('Data tidak ditemukan'));
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
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                        Text(finalStatus,
                                            style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold)),
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
                              if (form.transactions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                  child: Text('${form.transactions.length} Surat Jalan'),
                                )
                              else
                                SizedBox(),
                              if (form.transactions.isNotEmpty)
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
                                            form.transactions[i].selected == 0 ? SizedBox() : Icon(Icons.check),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                )
                              else
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  title: Text("form.task"),
                                ),
                            ],
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
    );
  }

  Future addJob(BuildContext context) {
    return showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setModalState) {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('More', style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: taskController,
                        decoration: InputDecoration(labelText: 'Task'),
                      ),
                      TextFormField(
                        onTap: () {},
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Date'),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: Get.width,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              createForm(taskController.text);
                            });
                            Get.back();
                          },
                          child: Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future dateFilterBottomSheet(BuildContext context) {
    return showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setModalState) {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('More', style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Text('Semua Tanggal',
                          style: GoogleFonts.sourceSansPro(fontSize: 17, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Pilih Tanggal',
                          style: GoogleFonts.sourceSansPro(fontSize: 17, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onTap: () {},
                              controller: fromDateController,
                              readOnly: true,
                              decoration: InputDecoration(labelText: 'From'),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              onTap: () {},
                              controller: toDateController,
                              readOnly: true,
                              decoration: InputDecoration(labelText: 'To'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: Get.width,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filtered = true;
                              formFuture = getFormByDate();
                              dateFilter =
                                  '${DateFormat('dd/MM/y').format(fromDate)} - ${DateFormat('dd/MM/y').format(toDate)}';
                            });
                            Get.back();
                          },
                          child: Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
