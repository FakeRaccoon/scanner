import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scanner/Screens/home.dart';
import 'package:scanner/form-model.dart';
import 'package:scanner/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIService {
  SharedPreferences sharedPreferences;

  static final BaseOptions baseOptions = BaseOptions(
    baseUrl: '$apiUrl/api',
    connectTimeout: 1000 * 10,
    receiveTimeout: 1000 * 10,
  );

  Dio dio = Dio(baseOptions);

  Future getUser() async {
    try {
      final response = await dio.get(apiUrl + 'api/user');
      return userResultFromJson(jsonEncode(response.data['result']));
    } on DioError catch (e) {
      throw e.message;
    }
  }

  Future getFormStatus(int status) async {
    try {
      final response = await dio.get(apiUrl + 'api/form/status', queryParameters: {'status': status});
      return formResultFromJson(jsonEncode(response.data['result']));
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  Future getFormDetail(int id) async {
    try {
      final response = await dio.get(apiUrl + 'api/form/id', queryParameters: {'id': id});
      return formResultFromJson(jsonEncode(response.data['result']));
    } on DioError catch (e) {
      throw e.message;
    }
  }

  Future getFormDate(int status, DateTime fromDate, DateTime toDate) async {
    try {
      final response = await dio.get(apiUrl + 'api/form/date', queryParameters: {
        'status': status,
        'from_date': fromDate.toString(),
        'to_date': toDate.toString(),
      });
      return formResultFromJson(jsonEncode(response.data['result']));
    } on DioError catch (e) {
      print(e);
    }
  }

  Future<List<FormResult>> getFormStatus2(int status1, int status2) async {
    try {
      final response = await dio.get(
        apiUrl + 'api/form/status2',
        queryParameters: {
          'status1': status1,
          'status2': status2,
        },
      );
      return formResultFromJson(jsonEncode(response.data['result']));
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  Future createSJForm(status, task, otherTask, toId, date) async {
    sharedPreferences = await SharedPreferences.getInstance();
    try {
      final response = await dio.post(apiUrl + 'api/form/create', data: {
        'status': status,
        'task': task,
        'from_id': sharedPreferences.getInt('userId'),
        'to_id': toId,
        'other_task': otherTask,
        'request_date': date.toString(),
      });
      return response.statusCode;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        throw 'Cek koneksi internet';
      }
      throw 'Gagal memproses data';
    }
  }

  Future createSLForm(status, otherTask, toId, date) async {
    sharedPreferences = await SharedPreferences.getInstance();
    try {
      final response = await dio.post(apiUrl + 'api/form/create', data: {
        'status': status,
        'task': null,
        'from_id': sharedPreferences.getInt('userId'),
        'to_id': toId,
        'other_task': otherTask,
        'request_date': date.toString(),
      });
      return response.statusCode;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        throw 'Cek koneksi internet';
      }
      throw 'Gagal memproses data';
    }
  }

  ///update form sj

  Future updateForm(id, task, otherTask, note, status, fromId, toId, requestDate, pickUpDate, receivedDate) async {
    try {
      final response = await dio.post(apiUrl + 'api/form/update', data: {
        'id': id,
        'task': task,
        'other_task': otherTask,
        'note': note,
        'status': status,
        'from_id': fromId,
        'to_id': toId,
        'request_date': requestDate == null ? null : requestDate.toString(),
        'pick_up_date': pickUpDate == null ? null : pickUpDate.toString(),
        'received_date': receivedDate == null ? null : receivedDate.toString(),
      });
      print(response.data);
    } on DioError catch (e) {
      print(e);
      print(e.response.data);
      if (e.type == DioErrorType.connectTimeout) {
        throw 'Cek koneksi internet';
      }
      throw 'Gagal memproses data';
    }
  }

  //
  // Future updateFormSL(id, task, otherTask, note, toId, status, requestDate, pickUpDate, receivedDate) async {
  //   final response = await dio.post(apiUrl + 'api/form/update', data: {
  //     'id': id,
  //     'task': task,
  //     'other_task': otherTask,
  //     'note': note,
  //     'to_id': toId,
  //     'status': status,
  //     'request_date': requestDate,
  //     'pick_up_date': pickUpDate,
  //     'received_date': receivedDate,
  //   });
  //   if (response.statusCode == 200) {
  //     getHttp();
  //   }
  //   print(response.data);
  // }
  //
  // Future updateFormSL2(id, task, otherTask, note, toId, status, requestDate, pickUpDate, receivedDate) async {
  //   final response = await dio.post(apiUrl + 'api/form/update', data: {
  //     'id': id,
  //     'task': task,
  //     'other_task': otherTask,
  //     'note': note,
  //     'to_id': toId,
  //     'status': status,
  //     'request_date': requestDate,
  //     'pick_up_date': pickUpDate,
  //     'received_date': receivedDate,
  //   });
  //   if (response.statusCode == 200) {
  //     getHttp();
  //     _tabController.animateTo(5);
  //   }
  //   print(response.data);
  // }
  //
  // updateForm2(id, task, note, requestDate, pickUpDate) async {
  //   final response = await dio.post(apiUrl + 'api/form/update', data: {
  //     'id': id,
  //     'task': task,
  //     'note': note,
  //     'status': 4,
  //     'request_date': requestDate,
  //     'pick_up_date': pickUpDate,
  //     'received_date': DateTime.now().toString(),
  //   });
  //   if (response.statusCode == 200) {
  //     getHttp();
  //     _tabController.animateTo(3);
  //   }
  //   print(response.data);
  // }
  //
  // updateFormFinal(id, task, note, tax, billing, requestDate, pickUpDate, receivedDate) async {
  //   final response = await dio.post(apiUrl + 'api/form/update', data: {
  //     'id': id,
  //     'task': task,
  //     'note': note,
  //     'status': 5,
  //     'tax': tax,
  //     'billing': billing,
  //     'request_date': requestDate,
  //     'pick_up_date': pickUpDate,
  //     'received_date': receivedDate,
  //   });
  //   if (response.statusCode == 200) {
  //     final getResponse = await dio.get(apiUrl + 'api/form/id', queryParameters: {'id': id});
  //     int tax = getResponse.data['result'][0]['tax'];
  //     int billing = getResponse.data['result'][0]['billing'];
  //     if (tax != null && billing != null) {
  //       if (tax + billing == 2) {
  //         updateFormFinalFinal(id, task, note, 6, 1, 1, requestDate, pickUpDate, receivedDate);
  //       } else if (tax == null || billing == null) {
  //         getHttp();
  //         _tabController.animateTo(4);
  //       }
  //     }
  //     print(response.data);
  //   }
  //   print('TAX UPDATE SUCCESS');
  // }
  //
  // updateFormFinal2(id, task, note, tax, billing, requestDate, pickUpDate, receivedDate) async {
  //   final response = await dio.post(apiUrl + 'api/form/update', data: {
  //     'id': id,
  //     'task': task,
  //     'note': note,
  //     'status': 5,
  //     'tax': tax,
  //     'billing': billing,
  //     'request_date': requestDate,
  //     'pick_up_date': pickUpDate,
  //     'received_date': receivedDate,
  //   });
  //   if (response.statusCode == 200) {
  //     final getResponse = await dio.get(apiUrl + 'api/form/id', queryParameters: {'id': id});
  //     int tax = getResponse.data['result'][0]['tax'];
  //     int billing = getResponse.data['result'][0]['billing'];
  //     if (tax != null && billing != null) {
  //       if (tax + billing == 2) {
  //         updateFormFinalFinal(id, task, note, 6, 1, 1, requestDate, pickUpDate, receivedDate);
  //       } else if (tax == null || billing == null) {
  //         setState(() {
  //           getHttp();
  //           _tabController.animateTo(4);
  //         });
  //       }
  //     }
  //     print(response.data);
  //   }
  //   print('BILLING UPDATE SUCCESS');
  // }
  //
  // updateFormFinalFinal(id, task, note, status, tax, billing, requestDate, pickUpDate, receivedDate) async {
  //   final response = await dio.post(apiUrl + 'api/form/update', data: {
  //     'id': id,
  //     'task': task,
  //     'note': note,
  //     'status': status,
  //     'tax': tax,
  //     'billing': billing,
  //     'request_date': requestDate,
  //     'pick_up_date': pickUpDate,
  //     'received_date': receivedDate,
  //   });
  //   if (response.statusCode == 200) {
  //     getHttp();
  //     _tabController.animateTo(5);
  //   }
  //   print(response.data);
  // }
  //
  Future createTransactions(formId, name) async {
    try {
      final response = await dio.post(apiUrl + 'api/transaction/create', data: {
        'form_id': formId,
        'name': name,
        'selected': 0,
        'selected2': 0,
      });
      return response.data;
    } on DioError catch (e) {
      throw e.message;
    }
  }

  Future createOtherTransactions(formId, name) async {
    try {
      final response = await dio.post(apiUrl + 'api/otherTransaction/create', data: {
        'form_id': formId,
        'name': name,
        'selected': 0,
        'selected2': 0,
      });
      return response.data;
    } on DioError catch (e) {
      throw e.message;
    }
  }

  Future deleteTransaction(id) async {
    try {
      final response = await dio.post(apiUrl + 'api/transaction/delete', data: {
        'id': id,
      });
      return response.data;
    } on DioError catch (e) {
      throw e.message;
    }
  }

  Future deleteOtherTransaction(id) async {
    try {
      final response = await dio.post(apiUrl + 'api/otherTransaction/delete', data: {
        'id': id,
      });
      return response.data;
    } on DioError catch (e) {
      throw e.message;
    }
  }

  Future deleteFormRequest(id) async {
    try {
      final response = await dio.post(apiUrl + 'api/form/delete', data: {
        'id': id,
      });
      return response.data;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future deleteFormWarehouse(id) async {
    try {
      final response = await dio.post(apiUrl + 'api/form/delete', data: {
        'id': id,
      });
      return response.data;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
