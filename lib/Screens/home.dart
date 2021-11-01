import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanner/Screens/courier.dart';
import 'package:scanner/Screens/request.dart';
import 'package:scanner/Screens/stock.dart';
import 'package:scanner/Screens/tax-billing.dart';
import 'package:scanner/Screens/warehouse.dart';
import 'package:scanner/create-user.dart';
import 'package:scanner/Screens/history.dart';
import 'package:scanner/request-bottomsheet.dart';
import 'package:scanner/user-page.dart';

import '../Services/controller.dart';

const apiUrl = 'http://192.168.5.114:8000/';
// const apiUrl = 'http://kurir.angkasamulyatrading.com/';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final controller = Get.put(Controller());

  TextStyle header = GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, color: Colors.black);
  TextStyle body = GoogleFonts.sourceSansPro(color: Colors.grey, fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(controller.name.value, style: header),
            ),
            Obx(
              () => Text(controller.role.value, style: body),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.grey[700]),
        actions: [
          Obx(
            () => Visibility(
              visible: controller.role.value == 'Admin' ? true : false,
              child: IconButton(
                tooltip: 'Add new user',
                icon: Icon(Icons.person_add_rounded),
                onPressed: () => Get.to(() => CreateUser()),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.person_outline_rounded),
            onPressed: () {
              Get.to(() => UserPage());
            },
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          indicator: BoxDecoration(color: Colors.transparent),
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.grey[900],
          labelStyle: GoogleFonts.sourceSansPro(fontWeight: FontWeight.bold, fontSize: 18),
          tabs: [
            Tab(
              child: Text('Request'),
            ),
            Tab(
              child: Text('Warehouse'),
            ),
            Tab(
              child: Text('Courier'),
            ),
            Tab(
              child: Text('Stock'),
            ),
            Tab(
              child: Text('Tax & Billing'),
            ),
            Tab(
              child: Text('History'),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () {
          if (controller.tabController.index == 0 && controller.role.value != 'Courier') {
            return FloatingActionButton(
              mini: true,
              backgroundColor: Colors.grey[900],
              onPressed: () {
                showMaterialModalBottomSheet(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  context: context,
                  builder: (context) => RequestBottomSheet(),
                );
              },
              child: Icon(Icons.add),
            );
          }
          return SizedBox();
        },
      ),
      body: Obx(
        () => TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller.tabController,
          children: [
            controller.role.value == 'Courier' ? Center(child: Text('Not Authorized')) : Request(),
            Warehouse(),
            Courier(),
            Stock(),
            TaxAndBilling(),
            HistoryPage(),
          ],
        ),
      ),
    );
  }
}
