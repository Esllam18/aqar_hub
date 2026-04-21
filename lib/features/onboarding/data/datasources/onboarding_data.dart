import 'package:aqar_hub/core/constants/app_assets.dart';
import 'package:aqar_hub/features/onboarding/data/models/onboarding_model.dart';

abstract final class OnboardingData {
  static List<OnboardingModel> get pages => const [
    OnboardingModel(
      titleKey: 'onboarding_page1_title',
      descriptionKey: 'onboarding_page1_description',
      lottie: AppLottie.home,
    ),
    OnboardingModel(
      titleKey: 'onboarding_page2_title',
      descriptionKey: 'onboarding_page2_description',
      lottie: AppLottie.house,
    ),
    OnboardingModel(
      titleKey: 'onboarding_page3_title',
      descriptionKey: 'onboarding_page3_description',
      lottie: AppLottie.apartment,
    ),
  ];
}
