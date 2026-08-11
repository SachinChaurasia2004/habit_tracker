import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/hive_setup.dart';
import 'core/di/injection.dart';
import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/services/streak_notification_service.dart';
import 'features/habits/presentation/bloc/habit_bloc.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/profile/presentation/bloc/profile_state.dart';
import 'features/tracking/presentation/bloc/calendar_bloc.dart';
import 'features/tracking/presentation/bloc/stats_bloc.dart';
import 'features/tracking/presentation/bloc/tracking_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[Main] App starting...');

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

  debugPrint('[Main] Initializing Hive database...');
  await HiveSetup.initialize();

  debugPrint('[Main] Setting up dependencies...');
  await setupDependencies();

  // Initialize notifications
  debugPrint('[Main] Initializing notification service...');
  await StreakNotificationService().initialize();
  debugPrint('[Main] Notification service initialized');

  // Check if onboarding completed
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  debugPrint('[Main] Onboarding complete: $onboardingComplete');

  debugPrint('[Main] App initialization complete, launching...');
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
          create: (context) =>
              getIt<ProfileBloc>()
                ..add(const LoadProfileEvent()), // Load profile on app start
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final darkModeEnabled = switch (state) {
            ProfileLoaded loaded => loaded.profile.darkModeEnabled,
            ProfileUpdating updating => updating.profile.darkModeEnabled,
            _ => true,
          };

          return MaterialApp(
            title: 'Habitus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
            home: showOnboarding
                ? const OnboardingPage()
                : const NotificationPermissionGate(child: MainNavigation()),
          );
        },
      ),
    );
  }
}

class NotificationPermissionGate extends StatefulWidget {
  final Widget child;

  const NotificationPermissionGate({super.key, required this.child});

  @override
  State<NotificationPermissionGate> createState() =>
      _NotificationPermissionGateState();
}

class _NotificationPermissionGateState
    extends State<NotificationPermissionGate> {
  static const String _promptShownKey = 'notification_permission_prompt_shown';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNotificationPermissionDialogIfNeeded();
    });
  }

  Future<void> _showNotificationPermissionDialogIfNeeded() async {
    final platform = defaultTargetPlatform;
    if (kIsWeb ||
        (platform != TargetPlatform.android &&
            platform != TargetPlatform.iOS)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final promptShown = prefs.getBool(_promptShownKey) ?? false;
    if (promptShown || !mounted) {
      return;
    }

    if (platform == TargetPlatform.android) {
      final notificationsEnabled = await StreakNotificationService()
          .areNotificationsEnabled();
      if (notificationsEnabled) {
        await prefs.setBool(_promptShownKey, true);
        return;
      }
    }

    if (!mounted) {
      return;
    }

    final shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enable reminders?'),
          content: const Text(
            'Get gentle reminders for unfinished habits and streak milestones.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );

    await prefs.setBool(_promptShownKey, true);

    if (shouldRequest != true || !mounted) {
      return;
    }

    final granted = await StreakNotificationService().requestPermissions();
    if (!mounted) {
      return;
    }

    context.read<ProfileBloc>().add(ToggleNotificationsEvent(granted));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
