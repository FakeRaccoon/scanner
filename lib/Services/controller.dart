import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanner/Services/api-service.dart';
import 'package:scanner/Services/barcode-service.dart';
import 'package:scanner/form-model.dart';
import 'package:scanner/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControllerData {
  int userId;
  String name;
  TextEditingController userController;

  ControllerData({
    this.userId,
    this.name,
    this.userController,
  });
}

class Controller extends GetxController with SingleGetTickerProviderMixin {
  var controllerData = ControllerData().obs;
  var visible = true.obs;
  var selectedRadio = 1.obs;
  var apiController = APIService();
  var barcodeController = BarcodeService();
  var userTextController = TextEditingController().obs;

  var smallestDate = DateTime(2012, 12, 12).obs;
  var toDate = DateTime.now().obs;

  var requestLoading = true.obs;
  var warehouseLoading = true.obs;
  var courierLoading = true.obs;
  var stockLoading = true.obs;
  var taxLoading = true.obs;
  var historyLoading = true.obs;

  /*Shared Preference*/
  var role = ''.obs;
  var name = ''.obs;
  var username = ''.obs;

  var detailData = [].obs;
  var userData = [].obs;
  var requestData = [FormResult()].obs;
  var warehouseData = [FormResult()].obs;
  var courierData = [FormResult()].obs;
  var stockData = [FormResult()].obs;
  var taxData = [FormResult()].obs;
  var historyData = [FormResult()].obs;

  TabController tabController;
  int tabIndex = 0;

  Future<Null> getHttp() async {
    apiController.getFormStatus2(-1, 1).then((value) {
      requestData.value = value;
      requestLoading.value = false;
    });
    apiController.getFormStatus2(2, 2).then((value) {
      warehouseData.value = value;
      warehouseLoading.value = false;
    });
    apiController.getFormStatus2(0, 3).then((value) {
      courierData.value = value;
      courierLoading.value = false;
    });
    apiController.getFormStatus2(3, 5).then((value) {
      stockData.value = value;
      stockLoading.value = false;
    });
    apiController.getFormStatus2(5, 5).then((value) {
      taxData.value = value;
      taxLoading.value = false;
    });
    apiController.getFormStatus(6).then((value) {
      List<FormResult> data = value;
      List<DateTime> date = [];
      data.forEach((element) {
        if (element.receivedDate != null) {
          date.add(element.receivedDate);
        }
      });
      smallestDate.value = date.last;
      print(smallestDate.value);
      historyData.value = value;
      historyLoading.value = false;
    });
  }

  historyDateFilter() {
    historyLoading.value;
    apiController.getFormDate(6, smallestDate.value, toDate.value).then((value) {
      historyData.value = value;
      historyLoading.value = false;
    }, onError: (e) {});
  }

  SharedPreferences sharedPreferences;

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Get.offAll(() => Login());
    } else {
      role.value = sharedPreferences.getString('role');
      name.value = sharedPreferences.getString('name');
      username.value = sharedPreferences.getString('username');
    }
  }

  getDetail(int id) async {
    apiController.getFormDetail(id).then((value) {
      detailData.value = value;
    });
    update();
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 6, vsync: this);
    apiController.getUser().then((value) => userData.value = value);
    checkLoginStatus();
    getHttp();
  }

  @override
  void onClose() {
    super.onClose();
    tabController.dispose();
  }
}
