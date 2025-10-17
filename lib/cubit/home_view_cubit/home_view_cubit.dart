import 'package:flutter_bloc/flutter_bloc.dart';

enum HomeViewState { home, bannerDetails }

class HomeViewData {
  final HomeViewState viewState;
  final String? bannerTitle;
  final List<Map<String, dynamic>>? bannerProducts;

  const HomeViewData({
    required this.viewState,
    this.bannerTitle,
    this.bannerProducts,
  });

  HomeViewData copyWith({
    HomeViewState? viewState,
    String? bannerTitle,
    List<Map<String, dynamic>>? bannerProducts,
  }) {
    return HomeViewData(
      viewState: viewState ?? this.viewState,
      bannerTitle: bannerTitle ?? this.bannerTitle,
      bannerProducts: bannerProducts ?? this.bannerProducts,
    );
  }
}

class HomeViewCubit extends Cubit<HomeViewData> {
  HomeViewCubit()
      : super(const HomeViewData(
          viewState: HomeViewState.home,
          bannerTitle: null,
          bannerProducts: null,
        ));

  void showHome() {
    emit(const HomeViewData(
      viewState: HomeViewState.home,
      bannerTitle: null,
      bannerProducts: null,
    ));
  }

  void showBannerDetails({
    required String bannerTitle,
    required List<Map<String, dynamic>> bannerProducts,
  }) {
    emit(HomeViewData(
      viewState: HomeViewState.bannerDetails,
      bannerTitle: bannerTitle,
      bannerProducts: bannerProducts,
    ));
  }
}

