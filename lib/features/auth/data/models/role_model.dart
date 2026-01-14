class RoleModel {
  final int id;
  final String name;
  final String guardName;

  const RoleModel({
    required this.id,
    required this.name,
    required this.guardName,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      guardName: json['guard_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'guard_name': guardName,
      };
}
