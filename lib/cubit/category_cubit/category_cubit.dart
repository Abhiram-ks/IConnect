import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/category.dart';
import '../../data/category_data.dart';

class CategoryCubit extends Cubit<List<Category>> {
  CategoryCubit() : super([]) {
    loadCategories();
  }

  void loadCategories() {
    emit(CategoryData.getCategories());
  }

  void toggleCategory(String categoryId) {
    final updatedCategories = _toggleCategoryRecursive(List.from(state), categoryId);
    emit(updatedCategories);
  }

  List<Category> _toggleCategoryRecursive(List<Category> categories, String categoryId) {
    return categories.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(isExpanded: !category.isExpanded);
      } else if (category.subcategories != null) {
        return category.copyWith(
          subcategories: _toggleCategoryRecursive(category.subcategories!, categoryId),
        );
      }
      return category;
    }).toList();
  }

  void expandCategory(String categoryId) {
    final updatedCategories = _expandCategoryRecursive(List.from(state), categoryId);
    emit(updatedCategories);
  }

  List<Category> _expandCategoryRecursive(List<Category> categories, String categoryId) {
    return categories.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(isExpanded: true);
      } else if (category.subcategories != null) {
        return category.copyWith(
          subcategories: _expandCategoryRecursive(category.subcategories!, categoryId),
        );
      }
      return category;
    }).toList();
  }

  void collapseCategory(String categoryId) {
    final updatedCategories = _collapseCategoryRecursive(List.from(state), categoryId);
    emit(updatedCategories);
  }

  List<Category> _collapseCategoryRecursive(List<Category> categories, String categoryId) {
    return categories.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(isExpanded: false);
      } else if (category.subcategories != null) {
        return category.copyWith(
          subcategories: _collapseCategoryRecursive(category.subcategories!, categoryId),
        );
      }
      return category;
    }).toList();
  }

  void collapseAll() {
    final updatedCategories = _collapseAllRecursive(List.from(state));
    emit(updatedCategories);
  }

  List<Category> _collapseAllRecursive(List<Category> categories) {
    return categories.map((category) {
      if (category.subcategories != null) {
        return category.copyWith(
          isExpanded: false,
          subcategories: _collapseAllRecursive(category.subcategories!),
        );
      }
      return category.copyWith(isExpanded: false);
    }).toList();
  }
}
