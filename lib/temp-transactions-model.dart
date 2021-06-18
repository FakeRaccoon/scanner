// To parse this JSON data, do
//
//     final temporaryTransactions = temporaryTransactionsFromJson(jsonString);

import 'dart:convert';

List<TemporaryTransactions> temporaryTransactionsFromJson(String str) => List<TemporaryTransactions>.from(json.decode(str).map((x) => TemporaryTransactions.fromJson(x)));

String temporaryTransactionsToJson(List<TemporaryTransactions> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TemporaryTransactions {
  TemporaryTransactions({
    this.formId,
    this.name,
    this.selected,
  });

  int formId;
  String name;
  int selected;

  factory TemporaryTransactions.fromJson(Map<String, dynamic> json) => TemporaryTransactions(
    formId: json["form_id"] == null ? null : json["form_id"],
    name: json["name"] == null ? null : json["name"],
    selected: json["selected"] == null ? null : json["selected"],
  );

  Map<String, dynamic> toJson() => {
    "form_id": formId == null ? null : formId,
    "name": name == null ? null : name,
    "selected": selected == null ? null : selected,
  };
}
