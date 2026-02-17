import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/database/hive_setup.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/navigation/main_navigation.dart';
import 'features/habits/presentation/bloc/habit_bloc.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<HabitBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<TrackingBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Habit Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: MainNavigation(),
      ),
    );
  }
}

