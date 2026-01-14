class CoffeeModel {
  final int id;
  final String name;
  final String brand;
  final String? description;
  final double price;
  final int stock;
  final String? imagePath;
  final String? imageUrl;
  final String? imageFullUrl;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const CoffeeModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.stock,
    required this.isActive,
    this.description,
    this.imagePath,
    this.imageUrl,
    this.imageFullUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory CoffeeModel.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
    int parseInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

    return CoffeeModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      description: json['description']?.toString(),
      price: parsePrice(json['price']),
      stock: parseInt(json['stock']),
      imagePath: json['image_path']?.toString(),
      imageUrl: json['image_url']?.toString(),
      imageFullUrl: json['image_full_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'description': description,
        'price': price,
        'stock': stock,
        'image_path': imagePath,
        'image_url': imageUrl,
        'image_full_url': imageFullUrl,
        'is_active': isActive,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
