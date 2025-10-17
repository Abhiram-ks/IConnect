class Category {
  final String id;
  final String name;
  final String? icon;
  final List<Category>? subcategories;
  final bool isExpanded;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.subcategories,
    this.isExpanded = false,
  });

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    List<Category>? subcategories,
    bool? isExpanded,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      subcategories: subcategories ?? this.subcategories,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'subcategories': subcategories?.map((x) => x.toJson()).toList(),
      'isExpanded': isExpanded,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      subcategories: json['subcategories'] != null
          ? List<Category>.from(json['subcategories'].map((x) => Category.fromJson(x)))
          : null,
      isExpanded: json['isExpanded'] ?? false,
    );
  }
}
