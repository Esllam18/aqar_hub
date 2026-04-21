import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingInitial());

  int _currentPage = 0;

  int getCurrentPage() => _currentPage;

  void onPageChanged(int index) {
    _currentPage = index;
    emit(OnboardingPageChanged(index));
  }

  void completeOnboarding() {
    emit(const OnboardingCompleted());
  }
}
