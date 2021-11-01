import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scanner/Services/api-service.dart';
import 'package:scanner/Screens/home.dart';
import 'package:scanner/Services/controller.dart';
import 'package:scanner/user_model.dart';

class RequestBottomSheet extends StatefulWidget {
  const RequestBottomSheet({Key key}) : super(key: key);

  @override
  _RequestBottomSheetState createState() => _RequestBottomSheetState();
}

class _RequestBottomSheetState extends State<RequestBottomSheet> {
  final Controller find = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Request', style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ListTile(
            enabled: find.role.value == 'Admin' || find.role.value == 'Warehouse' ? true : false,
            onTap: () {
              showMaterialModalBottomSheet(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                context: context,
                builder: (context) {
                  return SuratJalanBottomSheet();
                },
              );
            },
            contentPadding: EdgeInsets.zero,
            title: Text('Surat Jalan'),
          ),
          Divider(thickness: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              find.userTextController.value.clear();
              showMaterialModalBottomSheet(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                context: context,
                builder: (context) => SuratLainBottomSheet(),
              );
            },
            title: Text('Surat Lain'),
          ),
        ],
      ),
    );
  }
}

class SuratLainBottomSheet extends StatefulWidget {
  const SuratLainBottomSheet({Key key}) : super(key: key);

  @override
  _SuratLainBottomSheetState createState() => _SuratLainBottomSheetState();
}

class _SuratLainBottomSheetState extends State<SuratLainBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController taskController = TextEditingController();
  TextEditingController otherTaskController = TextEditingController();
  TextEditingController userController = TextEditingController();
  bool isSwitched = true;
  DateTime date = DateTime.now();

  final Controller find = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Surat Lain', style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextFormField(
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Isi jumlah surat jalan';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                controller: otherTaskController,
                decoration: InputDecoration(labelText: 'Banyak Surat Lain / Non Barcode'),
              ),
              Obx(
                () => TextFormField(
                  readOnly: true,
                  onTap: () {
                    showMaterialModalBottomSheet(
                      expand: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      context: context,
                      builder: (context) {
                        return DestinationBottomSheet();
                      },
                    );
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Isi tujuan pengiriman';
                    }
                    return null;
                  },
                  // controller: find.controllerData.value.userController,
                  controller: find.userTextController.value,
                  decoration: InputDecoration(labelText: 'Tujuan Pengiriman'),
                ),
              ),
              TextFormField(
                onTap: () {
                  DatePicker.showDatePicker(
                    context,
                    minTime: DateTime.now(),
                    maxTime: DateTime(2023, 1, 1),
                    locale: LocaleType.id,
                    onConfirm: (DateTime value) {
                      if (value != null) {
                        date = value;
                        dateController.text = DateFormat('d MMMM y').format(date);
                      }
                    },
                  );
                },
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Tanggal Pengambilan'),
              ),
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Dengan Kurir'),
                trailing: CupertinoSwitch(
                  activeColor: Colors.grey[700],
                  onChanged: (bool value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                  value: isSwitched,
                ),
              ),
              SizedBox(height: 20),
              confirmButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget confirmButton(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            if (isSwitched == true) {
              APIService().createSLForm(0, otherTaskController.text, find.controllerData.value.userId, date).then(
                  (value) {
                Get.until((route) => route.isFirst);
                find.getHttp();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 5),
                    content: ListTile(
                      title: Text(
                        'Berhasil menambahkan surat lain',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }, onError: (e) {
                Get.until((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 5),
                    content: Text('$e', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              });
            } else {
              APIService().createSLForm(-1, otherTaskController.text, find.controllerData.value.userId, date).then(
                  (value) {
                Get.until((route) => route.isFirst);
                find.getHttp();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 5),
                    content: Text(
                      'Berhasil menambahkan surat lain',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }, onError: (e) {
                Get.until((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 5),
                    content: Text('$e', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
              });
            }
            otherTaskController.clear();
            dateController.text = DateFormat('d MMMM y').format(DateTime.now());
          }
        },
        child: Text('Simpan'),
      ),
    );
  }
}

class DestinationBottomSheet extends StatefulWidget {
  const DestinationBottomSheet({Key key}) : super(key: key);

  @override
  _DestinationBottomSheetState createState() => _DestinationBottomSheetState();
}

class _DestinationBottomSheetState extends State<DestinationBottomSheet> {
  final Controller find = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetX<Controller>(builder: (controller) {
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
                if (user.role != 'Admin' || user.role != 'Courier') {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      controller.userTextController.value.text = user.name;
                      controller.controllerData.value.name = user.name;
                      controller.controllerData.value.userId = user.id;
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
                if (user.role != 'Admin' || user.role != 'Courier') {
                  return Divider(thickness: 1);
                }
                return SizedBox();
              },
            ),
          ),
        ],
      );
    });
  }
}

class SuratJalanBottomSheet extends StatefulWidget {
  const SuratJalanBottomSheet({Key key}) : super(key: key);

  @override
  _SuratJalanBottomSheetState createState() => _SuratJalanBottomSheetState();
}

class _SuratJalanBottomSheetState extends State<SuratJalanBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController taskController = TextEditingController();
  TextEditingController otherTaskController = TextEditingController();
  TextEditingController userController = TextEditingController();
  bool isSwitched = true;
  DateTime date = DateTime.now();

  final find = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Surat Jalan', style: GoogleFonts.sourceSansPro(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextFormField(
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Isi jumlah surat jalan';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                controller: taskController,
                decoration: InputDecoration(labelText: 'Banyak Surat Jalan'),
              ),
              TextFormField(
                onTap: () {
                  DatePicker.showDatePicker(
                    context,
                    minTime: DateTime.now(),
                    maxTime: DateTime(2023, 1, 1),
                    locale: LocaleType.id,
                    onConfirm: (DateTime value) {
                      if (value != null) {
                        date = value;
                        dateController.text = DateFormat('d MMMM y').format(date);
                      }
                    },
                  );
                },
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Tanggal Pengambilan'),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: Get.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      APIService().createSJForm(2, taskController.text, null, null, date).then((value) {
                        Get.until((route) => route.isFirst);
                        find.getHttp();
                        find.tabController.animateTo(1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 5),
                            content: Text(
                              'Berhasil menambahkan surat jalan',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }, onError: (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 5),
                            content: Text('$e', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        );
                      });
                      taskController.clear();
                      dateController.text = DateFormat('d MMMM y').format(DateTime.now());
                    }
                  },
                  child: Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
