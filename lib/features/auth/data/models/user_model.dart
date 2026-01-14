import 'dart:convert';

import 'role_model.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final List<RoleModel> roles;
  final String? createdAt;
  final String? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.roles = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesJson = (json['roles'] as List?) ?? [];
    return UserModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: rolesJson.map((r) => RoleModel.fromJson(Map<String, dynamic>.from(r as Map))).toList(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'roles': roles.map((r) => r.toJson()).toList(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  String toRawJson() => jsonEncode(toJson());

  static UserModel? fromRawJson(String? data) {
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  bool get isAdmin => roles.any((r) => r.name == 'admin');
  bool get isClient => roles.any((r) => r.name == 'client');
}
