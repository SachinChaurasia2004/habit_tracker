import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/hive_setup.dart';
import 'core/di/injection.dart';
import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/habits/presentation/bloc/habit_bloc.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/tracking/presentation/bloc/calendar_bloc.dart';
import 'features/tracking/presentation/bloc/stats_bloc.dart';
import 'features/tracking/presentation/bloc/tracking_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await HiveSetup.initialize();

  await setupDependencies();


    // Check if onboarding completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;


  runApp(MyApp(showOnboarding: !onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<HabitBloc>()),
        BlocProvider(create: (context) => getIt<TrackingBloc>()),
        BlocProvider(create: (context) => getIt<StatisticsBloc>()),
        BlocProvider(create: (context) => getIt<CalendarBloc>()),
        BlocProvider(
          create: (context) => getIt<ProfileBloc>()
            ..add(const LoadProfileEvent()),  // Load profile on app start
        ),
      ],
      child: MaterialApp(
        title: 'Habit Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home:  showOnboarding 
            ? const OnboardingPage()  // Show onboarding first time
            : MainNavigation(),  
      ),
    );
  }
}

