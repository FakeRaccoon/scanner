import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:scanner/Screens/home.dart';
import 'package:scanner/Services/api-service.dart';
import 'package:scanner/Services/controller.dart';

import '../form-model.dart';

class BarcodeService {
  Future scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      print(barcodeScanRes);
      if (barcodeScanRes != '-1') {
        return barcodeScanRes;
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  Future finalScanQRCourier() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        return formResultFromJson(jsonEncode(response.data['result']));
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  Future finalScanRequest() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        if (response.data['result'][0]['status'] == 0) {
          final data = response.data['result'][0];
          print(data);
          // updateFormSL(
          //   data['id'],
          //   data['task'],
          //   data['other_task'],
          //   data['note'],
          //   data['to_id'],
          //   4,
          //   data['request_date'],
          //   DateTime.now().toString(),
          //   data['received_date'],
          // );
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  Future finalScanQRStock() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        if (response.data['result'][0]['status'] == 3) {
          final data = response.data['result'][0];
          print(data);
          return formResultFromJson(jsonEncode(response.data['result']));
          // updateForm2(data['id'], data['task'], data['note'], data['request_date'], data['pick_up_date']);
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  Future finalScanQRTax() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR);
      if (barcodeScanRes != null) {
        int result = int.tryParse(barcodeScanRes.replaceAll("FORM-ID-", ""));
        final response = await Dio().get(apiUrl + 'api/form/id', queryParameters: {'id': result});
        final data = response.data['result'][0];
        return formResultFromJson(jsonEncode(response.data['result']));
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }
}
