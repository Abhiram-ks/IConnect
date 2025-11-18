import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuantityState extends Equatable {
  final int count;
  final int min;
  final int max;

  const QuantityState({
    required this.count,
    required this.min,
    required this.max,
  });

  QuantityState copyWith({int? count, int? min, int? max}) {
    return QuantityState(
      count: count ?? this.count,
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }

  bool get isAtMin => count <= min;
  bool get isAtMax => count >= max;

  @override
  List<Object?> get props => [count, min, max];
}

class QuantityCubit extends Cubit<QuantityState> {
  QuantityCubit({int initial = 1, int min = 1, int max = 10})
      : assert(min <= initial && initial <= max,
            'Initial must be between min and max'),
        super(QuantityState(count: initial, min: min, max: max));

  void increment() {
    if (state.count < state.max) {
      emit(state.copyWith(count: state.count + 1));
    }
  }

  void decrement() {
    if (state.count > state.min) {
      emit(state.copyWith(count: state.count - 1));
    }
  }
}


