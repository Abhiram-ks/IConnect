import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_menu_usecase.dart';
import 'menu_state.dart';

/// Menu Cubit - Manages menu state
class MenuCubit extends Cubit<MenuState> {
  final GetMenuUseCase getMenuUseCase;

  MenuCubit({required this.getMenuUseCase}) : super(const MenuState());

  /// Load menu by handle
  Future<void> loadMenu(String handle) async {
    emit(state.copyWith(status: MenuStatus.loading));

    final result = await getMenuUseCase(GetMenuParams(handle: handle));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MenuStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (menu) => emit(
        state.copyWith(
          status: MenuStatus.loaded,
          menu: menu,
        ),
      ),
    );
  }

  /// Toggle menu item expansion
  void toggleItem(String itemTitle) {
    final updatedExpandedItems = Map<String, bool>.from(state.expandedItems);
    updatedExpandedItems[itemTitle] = !(updatedExpandedItems[itemTitle] ?? false);
    
    emit(state.copyWith(expandedItems: updatedExpandedItems));
  }

  /// Check if item is expanded
  bool isItemExpanded(String itemTitle) {
    return state.expandedItems[itemTitle] ?? false;
  }

  /// Collapse all items
  void collapseAll() {
    emit(state.copyWith(expandedItems: {}));
  }
}

