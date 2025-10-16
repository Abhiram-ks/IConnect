import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrandScrollCubit extends Cubit<int> {
  final ScrollController scrollController = ScrollController();
  final List<Map<String, dynamic>> brandList;
  Timer? autoScrollTimer;

  BrandScrollCubit({required this.brandList}) : super(0) {
    _startAutoScroll();
  }

  void _startAutoScroll() {
    autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (scrollController.hasClients) {
        int nextIndex = state + 1;
        if (nextIndex >= brandList.length) {
          nextIndex = 0;
        }
        _scrollToIndex(nextIndex);
        emit(nextIndex);
      }
    });
  }

  void _scrollToIndex(int index) {
    if (scrollController.hasClients) {
      final double itemWidth = 108.0;
      final double targetOffset = index * itemWidth;
      
      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void updateScrollPosition(double position) {
    if (scrollController.hasClients) {
      final double itemWidth = 108.0;
      final int newIndex = (position / itemWidth).round();
      
      if (newIndex != state && newIndex >= 0 && newIndex < brandList.length) {
        emit(newIndex);
      }
    }
  }

  void scrollToIndex(int index) {
    if (index >= 0 && index < brandList.length) {
      _scrollToIndex(index);
      emit(index);
    }
  }

  void dispose() {
    autoScrollTimer?.cancel();
    scrollController.dispose();
  }
}
