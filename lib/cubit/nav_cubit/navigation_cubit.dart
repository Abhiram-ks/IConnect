import 'package:bloc/bloc.dart';


enum NavItem {home, product, cart, categories, search, iphone17, offers, profile}

class ButtomNavCubit extends Cubit<NavItem> {
  ButtomNavCubit() : super(NavItem.home);
  
  void selectItem (NavItem item) {
    emit(item);
  }
}