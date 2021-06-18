// To parse this JSON data, do
//
//     final userResult = userResultFromJson(jsonString);

import 'dart:convert';

List<UserResult> userResultFromJson(String str) => List<UserResult>.from(json.decode(str).map((x) => UserResult.fromJson(x)));

String userResultToJson(List<UserResult> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserResult {
  UserResult({
    this.id,
    this.username,
    this.name,
    this.role,
    this.token,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String username;
  String name;
  String role;
  String token;
  DateTime createdAt;
  DateTime updatedAt;

  factory UserResult.fromJson(Map<String, dynamic> json) => UserResult(
    id: json["id"] == null ? null : json["id"],
    username: json["username"] == null ? null : json["username"],
    name: json["name"] == null ? null : json["name"],
    role: json["role"] == null ? null : json["role"],
    token: json["token"] == null ? null : json["token"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "username": username == null ? null : username,
    "name": name == null ? null : name,
    "role": role == null ? null : role,
    "token": token == null ? null : token,
    "created_at": createdAt == null ? null : createdAt.toIso8601String(),
    "updated_at": updatedAt == null ? null : updatedAt.toIso8601String(),
  };
}
