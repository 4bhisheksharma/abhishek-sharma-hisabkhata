import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(AnalyticsInitial()) {
    on<AnalyticsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
