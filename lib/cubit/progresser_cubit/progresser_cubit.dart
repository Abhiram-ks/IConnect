import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'progresser_state.dart';

class ProgresserCubit extends Cubit<ProgresserState> {
  ProgresserCubit() : super(ProgresserInitial());

    void startLoading() {
    emit(ButtonProgressStart());
  }

  void stopLoading() {
    emit(ButtonprogressStop());
  }
//! send message states 
    void sendButtonStart() {
    emit(MessageSendLoading());
  }

  void sendButtonStop() {
    emit(MessageSendSuccess());
  }
}