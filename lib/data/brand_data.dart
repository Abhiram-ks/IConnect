class BrandData {
static const List<Map<String, dynamic>> brands = [
  {
    "id": 1,
    "imageUrl": "https://graphicsprings.com/wp-content/uploads/2023/07/image-58-1024x512.png",
  },
  {
    "id": 2,
    "imageUrl": "https://images.indianexpress.com/2021/07/Nothing-logo.jpg",
  },
  {
    "id": 3,
    "imageUrl": "https://cdn.logojoy.com/wp-content/uploads/20240909124957/Samsung-logo-1993-600x319.png",
  },
  {
    "id": 4,
    "imageUrl": "https://static.vecteezy.com/system/resources/previews/019/909/657/non_2x/nokia-transparent-nokia-free-free-png.png",
  },
  {
    "id": 5,
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Sony_logo.svg/800px-Sony_logo.svg.png",
  },
  {
    "id": 6,
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/1/13/OPPO_Logo_wiki.png",
  },
  {
    "id": 7,
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/e/e5/Vivo_mobile_logo.png",
  },
  {
    "id": 8,
    "imageUrl": "https://toppng.com/uploads/preview/windows-logo-and-name-116093828229pgbffxv7q.png",
  }
];

  static List<Map<String, dynamic>> getBrands() {
    return List.from(brands);
  }

  static Map<String, dynamic>? getBrandById(int id) {
    try {
      return brands.firstWhere((brand) => brand['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getBrandsByCategory(String category) {
    return brands.where((brand) => brand['category'] == category).toList();
  }
}
