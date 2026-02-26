import '../../../core/theme/app_colors.dart';
import 'models/onboarding_page_model.dart';

class OnboardingContent {
  static final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: 'Welcome to Habitus',
      description: 'Build better habits, track your progress, and transform your life one day at a time.',
      image: '🎯',
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.primaryLight,
    ),
    OnboardingPageModel(
      title: 'Track Your Habits',
      description: 'Easily create and track daily habits with a beautiful, intuitive interface.',
      image: '📊',
      primaryColor: AppColors.yogaGreen,
      secondaryColor: AppColors.success,
    ),
    OnboardingPageModel(
      title: 'Build Streaks',
      description: 'Stay motivated with streak tracking and never break the chain!',
      image: '🔥',
      primaryColor: AppColors.readOrange,
      secondaryColor: AppColors.warning,
    ),
    OnboardingPageModel(
      title: 'Visualize Progress',
      description: 'Beautiful charts and insights help you understand your patterns and improve.',
      image: '📈',
      primaryColor: AppColors.waterBlue,
      secondaryColor: AppColors.info,
    ),
    OnboardingPageModel(
      title: 'Start Your Journey',
      description: 'Ready to become your best self? Let\'s build those habits together!',
      image: '🚀',
      primaryColor: AppColors.meditationPurple,
      secondaryColor: AppColors.primary,
    ),
  ];
}