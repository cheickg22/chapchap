import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class SliderButtonState {
  final double sliderPosition;
  final bool isSliding;
  final double initialPosition; // Store the starting position

  SliderButtonState({
    this.sliderPosition = 0.0,
    this.isSliding = false,
    this.initialPosition = 0.0,
  });
}

class SliderButtonEvent {}

class SliderDragEvent extends SliderButtonEvent {
  final double position;

  SliderDragEvent(this.position);
}

class SliderDragStartEvent extends SliderButtonEvent {
  final double initialPosition;

  SliderDragStartEvent(this.initialPosition);
}

class SliderDragEndEvent extends SliderButtonEvent {
  final double position;
  final Future<bool?> Function() onSlideSuccess;
  final double maxPosition;

  SliderDragEndEvent(this.position, this.onSlideSuccess, this.maxPosition);
}

class SliderButtonBloc extends Bloc<SliderButtonEvent, SliderButtonState> {
  SliderButtonBloc() : super(SliderButtonState()) {
    on<SliderDragStartEvent>((event, emit) {
      emit(SliderButtonState(
        sliderPosition: event.initialPosition,
        isSliding: false,
        initialPosition: event.initialPosition,
      ));
    });

    on<SliderDragEvent>((event, emit) {
      emit(SliderButtonState(
        sliderPosition: event.position,
        isSliding: false,
        initialPosition: state.initialPosition,
      ));
    });

    on<SliderDragEndEvent>((event, emit) async {
      if (event.position >= (event.maxPosition - 5)) {
        // Small tolerance (5 px)
        final success = await event.onSlideSuccess();
        if (success == true) {
          emit(SliderButtonState(sliderPosition: 0.0, isSliding: false));
        }
      } else {
        emit(SliderButtonState(
            sliderPosition: 0.0, isSliding: false)); // Reset back
      }
    });
  }
}
