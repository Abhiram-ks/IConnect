import 'package:equatable/equatable.dart';
import '../../domain/entities/menu_entity.dart';

/// Menu State
class MenuState extends Equatable {
  final MenuStatus status;
  final MenuEntity? menu;
  final String? errorMessage;
  final Map<String, bool> expandedItems; // Track expanded state of menu items

  const MenuState({
    this.status = MenuStatus.initial,
    this.menu,
    this.errorMessage,
    this.expandedItems = const {},
  });

  MenuState copyWith({
    MenuStatus? status,
    MenuEntity? menu,
    String? errorMessage,
    Map<String, bool>? expandedItems,
  }) {
    return MenuState(
      status: status ?? this.status,
      menu: menu ?? this.menu,
      errorMessage: errorMessage ?? this.errorMessage,
      expandedItems: expandedItems ?? this.expandedItems,
    );
  }

  @override
  List<Object?> get props => [status, menu, errorMessage, expandedItems];
}

/// Menu Status Enum
enum MenuStatus {
  initial,
  loading,
  loaded,
  error,
}

