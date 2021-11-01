import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/form-model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return GetX<Controller>(builder: (controller) {
      if (controller.historyData.isEmpty) {
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: InkWell(
              onTap: () {
                showMaterialModalBottomSheet(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  context: context,
                  builder: (BuildContext context) => _BottomSheet(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(Get.width),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Semua Tanggal'),
                      Icon(Icons.keyboard_arrow_down_outlined),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              color: Colors.black,
              onRefresh: controller.getHttp,
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                itemCount: controller.historyData.length,
                itemBuilder: (context, index) {
                  FormResult form = controller.historyData[index];
                  var finalStatus;
                  var status = form.status;
                  switch (status) {
                    case 6:
                      finalStatus = 'Selesai';
                  }
                  return Card(
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
                                    Text(
                                      finalStatus,
                                      style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold),
                                    ),
                                    Text(DateFormat('d MMM y').format(form.receivedDate)),
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
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text('${i + 1}. ${form.transactions[i].name}'),
                                        trailing: Text(form.transactions[i].toUser.name),
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
                          if (form.task == null)
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
                                      //     Text(form.otherTransactions[i].name),
                                      //     SizedBox(height: 10),
                                      //   ],
                                      // );
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text('${i + 1}. ${form.otherTransactions[i].name}'),
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
                                  SizedBox(height: 10),
                                  Divider(thickness: 1),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('From',
                                              style: GoogleFonts.sourceSansPro(fontSize: 17, color: Colors.grey)),
                                          Text(form.fromUser.name,
                                              style:
                                                  GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('To',
                                              style: GoogleFonts.sourceSansPro(fontSize: 17, color: Colors.grey)),
                                          Text(form.toUser.name,
                                              style:
                                                  GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 17)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _BottomSheet extends StatefulWidget {
  const _BottomSheet({
    Key key,
  }) : super(key: key);

  @override
  __BottomSheetState createState() => __BottomSheetState();
}

class __BottomSheetState extends State<_BottomSheet> {
  final Controller find = Get.find();

  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  DateTime fromDateFilter;
  DateTime toDateFilter;
  DateTime smallestMinDate;

  @override
  void initState() {
    super.initState();
    fromDate.text = DateFormat('d MMMM y').format(find.smallestDate.value);
    toDate.text = DateFormat('d MMMM y').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.clear),
            ),
            title: Text(
              'Pilih Tanggal',
              style: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          SizedBox(height: 10),
          RadioListTile(
            activeColor: Colors.grey[900],
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            value: 1,
            groupValue: find.selectedRadio.value,
            onChanged: (newValue) {
              setState(() {
                find.selectedRadio.value = newValue;
              });
            },
            title: Text('Semua Tanggal Transaksi'),
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          Divider(thickness: 1),
          RadioListTile(
            activeColor: Colors.grey[900],
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            value: 2,
            groupValue: find.selectedRadio.value,
            onChanged: (newValue) {
              setState(() {
                find.selectedRadio.value = newValue;
              });
            },
            title: Text('Pilih Tanggal'),
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          Divider(thickness: 1),
          Visibility(
            visible: find.selectedRadio.value == 1 ? false : true,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Mulai dari'),
                      controller: fromDate,
                      readOnly: true,
                      onTap: () {
                        DatePicker.showDatePicker(
                          context,
                          minTime: find.smallestDate.value,
                          currentTime: find.smallestDate.value,
                          maxTime: DateTime.now(),
                          locale: LocaleType.id,
                          onConfirm: (DateTime value) {
                            if (value != null) {
                              find.smallestDate.value = value;
                              smallestMinDate = value;
                              fromDateFilter = value;
                              fromDate.text = DateFormat('d MMMM y', 'id').format(value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Sampai'),
                      controller: toDate,
                      readOnly: true,
                      onTap: () {
                        DatePicker.showDatePicker(
                          context,
                          minTime: smallestMinDate,
                          maxTime: DateTime.now(),
                          locale: LocaleType.id,
                          onConfirm: (DateTime value) {
                            if (value != null) {
                              find.toDate.value = value;
                              toDateFilter = value;
                              toDate.text = DateFormat('d MMMM y', 'id').format(value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: Get.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.grey[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  if (find.selectedRadio.value == 2) {
                    find.historyDateFilter();
                  } else if (find.selectedRadio.value == 1) {
                    find.getHttp();
                  }
                  Get.back();
                },
                child: Text('Terapkan'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
