// To parse this JSON data, do
//
//     final formResult = formResultFromJson(jsonString);

import 'dart:convert';

List<FormResult> formResultFromJson(String str) =>
    List<FormResult>.from(json.decode(str).map((x) => FormResult.fromJson(x)));

String formResultToJson(List<FormResult> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FormResult {
  FormResult({
    this.id,
    this.status,
    this.task,
    this.otherTask,
    this.note,
    this.tax,
    this.billing,
    this.requestDate,
    this.pickUpDate,
    this.receivedDate,
    this.transactions,
    this.otherTransactions,
    this.fromUser,
    this.toUser,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  int status;
  int task;
  int otherTask;
  String note;
  int tax;
  int billing;
  DateTime requestDate;
  DateTime pickUpDate;
  DateTime receivedDate;
  List<Transaction> transactions;
  List<OtherTransaction> otherTransactions;
  User fromUser;
  User toUser;
  DateTime createdAt;
  DateTime updatedAt;

  factory FormResult.fromJson(Map<String, dynamic> json) => FormResult(
        id: json["id"] == null ? null : json["id"],
        status: json["status"] == null ? null : json["status"],
        task: json["task"] == null ? null : json["task"],
        otherTask: json["other_task"] == null ? null : json["other_task"],
        note: json["note"] == null ? null : json["note"],
        tax: json["tax"] == null ? null : json["tax"],
        billing: json["billing"] == null ? null : json["billing"],
        fromUser: json["from_user"] == null ? null : User.fromJson(json["from_user"]),
        toUser: json["to_user"] == null ? null : User.fromJson(json["to_user"]),
        requestDate: json["request_date"] == null ? null : DateTime.parse(json["request_date"]),
        pickUpDate: json["pick_up_date"] == null ? null : DateTime.parse(json["pick_up_date"]),
        receivedDate: json["received_date"] == null ? null : DateTime.parse(json["received_date"]),
        transactions: json["transactions"] == null
            ? null
            : List<Transaction>.from(json["transactions"].map((x) => Transaction.fromJson(x))),
        otherTransactions: json["other_transactions"] == null
            ? null
            : List<OtherTransaction>.from(json["other_transactions"].map((x) => OtherTransaction.fromJson(x))),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "status": status == null ? null : status,
        "task": task == null ? null : task,
        "other_task": otherTask == null ? null : otherTask,
        "note": note == null ? null : note,
        "tax": tax == null ? null : tax,
        "billing": billing == null ? null : billing,
        "from_user": fromUser == null ? null : fromUser.toJson(),
        "to_user": toUser == null ? null : toUser.toJson(),
        "request_date": requestDate == null ? null : requestDate.toIso8601String(),
        "pick_up_date": pickUpDate == null ? null : pickUpDate.toIso8601String(),
        "received_date": receivedDate == null ? null : receivedDate.toIso8601String(),
        "transactions": transactions == null ? null : List<dynamic>.from(transactions.map((x) => x.toJson())),
        "other_transactions":
            otherTransactions == null ? null : List<dynamic>.from(otherTransactions.map((x) => x.toJson())),
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
      };
}

class Transaction {
  Transaction({
    this.id,
    this.formId,
    this.name,
    this.type,
    this.selected,
    this.selected1,
    this.selected2,
    this.toUser,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  int formId;
  String name;
  int selected;
  int selected2;
  int type;
  bool selected1;
  User toUser;
  DateTime createdAt;
  DateTime updatedAt;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"] == null ? null : json["id"],
        formId: json["form_id"] == null ? null : json["form_id"],
        name: json["name"] == null ? null : json["name"],
        type: json["type"] == null ? null : json["type"],
        selected: json["selected"] == null ? null : json["selected"],
        selected2: json["selected2"] == null ? null : json["selected2"],
        selected1: false,
        toUser: json["to_user"] == null ? null : User.fromJson(json["to_user"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "form_id": formId == null ? null : formId,
        "name": name == null ? null : name,
        "type": type == null ? null : type,
        "selected": selected == null ? null : selected,
        "selected2": selected2 == null ? null : selected2,
        "selected1": selected1,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
        "to_user": toUser == null ? null : toUser.toJson(),
      };
}

class OtherTransaction {
  OtherTransaction({
    this.id,
    this.formId,
    this.name,
    this.type,
    this.selected,
    this.selected1,
    this.selected2,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  int formId;
  String name;
  int selected;
  int selected2;
  int type;
  bool selected1;
  DateTime createdAt;
  DateTime updatedAt;

  factory OtherTransaction.fromJson(Map<String, dynamic> json) => OtherTransaction(
        id: json["id"] == null ? null : json["id"],
        formId: json["form_id"] == null ? null : json["form_id"],
        name: json["name"] == null ? null : json["name"],
        type: json["type"] == null ? null : json["type"],
        selected: json["selected"] == null ? null : json["selected"],
        selected2: json["selected2"] == null ? null : json["selected2"],
        selected1: false,
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "form_id": formId == null ? null : formId,
        "name": name == null ? null : name,
        "type": type == null ? null : type,
        "selected": selected == null ? null : selected,
        "selected2": selected2 == null ? null : selected2,
        "selected1": selected1,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
      };
}

class User {
  User({
    this.id,
    this.name,
    this.username,
    this.role,
    this.token,
    this.selected,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String name;
  String username;
  String role;
  String token;
  int selected;
  DateTime createdAt;
  DateTime updatedAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        username: json["username"] == null ? null : json["username"],
        role: json["role"] == null ? null : json["role"],
        token: json["token"] == null ? null : json["token"],
        selected: json["selected"] == null ? null : json["selected"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "username": username == null ? null : username,
        "role": role == null ? null : role,
        "token": token == null ? null : token,
        "selected": selected == null ? null : selected,
        "created_at": createdAt == null ? null : createdAt.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
      };
}
