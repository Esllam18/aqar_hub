abstract class OnboardingState {
  const OnboardingState();
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingPageChanged extends OnboardingState {
  final int currentPage;
  const OnboardingPageChanged(this.currentPage);
}

class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}
