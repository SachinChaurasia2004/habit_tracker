import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/hive_setup.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../tracking/presentation/bloc/stats_bloc.dart';
import '../../../tracking/presentation/bloc/stats_event.dart';
import '../../../tracking/presentation/bloc/stats_state.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_event.dart';
import '../../../habits/presentation/bloc/habit_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    
    // Load profile data
    context.read<ProfileBloc>().add(const LoadProfileEvent());
    
    // Load stats
    final statsState = context.read<StatisticsBloc>().state;
    if (statsState is! StatisticsLoaded) {
      context.read<StatisticsBloc>().add(const LoadStatisticsEvent());
    }
    
    // Load habits
    final habitState = context.read<HabitBloc>().state;
    if (habitState is! HabitsLoaded) {
      context.read<HabitBloc>().add(const LoadActiveHabitsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              if (profileState is ProfileLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (profileState is ProfileLoaded) {
                return _buildLoadedContent(context, profileState);
              }

              return const Center(
                child: Text('Something went wrong'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, ProfileLoaded profileState) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            context.pagePadding,
            16,
            context.pagePadding,
            20 + MediaQuery.of(context).padding.bottom + 90,
          ),
          children: [
            // Page Title
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: context.fontSize(28),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Profile Header (Now using BLoC state)
            _buildProfileHeader(context, profileState),

            SizedBox(height: context.spacing(20)),

            // Quick Stats
            _buildQuickStats(context),

            SizedBox(height: context.spacing(20)),

            // Achievements
            _buildSectionTitle(context, 'Achievements'),
            SizedBox(height: context.spacing(12)),
            _buildAchievements(context),

            SizedBox(height: context.spacing(20)),

            // Settings (Now using BLoC)
            _buildSectionTitle(context, 'Settings'),
            SizedBox(height: context.spacing(12)),
            _buildSettingsSection(context, profileState),

            SizedBox(height: context.spacing(20)),

            // About
            _buildSectionTitle(context, 'About'),
            SizedBox(height: context.spacing(12)),
            _buildAboutSection(context),

            SizedBox(height: context.spacing(20)),

            // Danger Zone
            _buildDangerZone(context),
          ],
        ),
      ),
    );
  }

  // ─── SECTION TITLE ───────────────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.fontSize(18),
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ─── PROFILE HEADER ──────────────────────────────────────────────────

   Widget _buildProfileHeader(BuildContext context, ProfileLoaded profileState) {
    return Container(
      padding: EdgeInsets.all(context.spacing(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.progressGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.cardBackground,
              child: Text(
                profileState.userName.isNotEmpty 
                    ? profileState.userName[0].toUpperCase() 
                    : '?',
                style: TextStyle(
                  fontSize: context.fontSize(32),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          SizedBox(height: context.spacing(16)),

          // Name from BLoC
          Text(
            profileState.userName,
            style: TextStyle(
              fontSize: context.fontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: context.spacing(6)),

          // Member since from BLoC
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Member since ${profileState.joinDateFormatted}',
                style: TextStyle(
                  fontSize: context.fontSize(13),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: context.spacing(16)),

          // Edit button
          OutlinedButton.icon(
            onPressed: () => _showEditNameDialog(context, profileState.userName),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ─── QUICK STATS ─────────────────────────────────────────────────────

  Widget _buildQuickStats(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, statsState) {
        return BlocBuilder<HabitBloc, HabitState>(
          builder: (context, habitState) {
            int totalHabits = 0;
            int daysTracked = 0;
            int bestStreak = 0;
            double completionRate = 0;

            if (habitState is HabitsLoaded) {
              totalHabits = habitState.habits.length;
            }
            if (statsState is StatisticsLoaded) {
              daysTracked = statsState.overallStats.daysTracked;
              bestStreak = statsState.overallStats.bestStreak;
              completionRate = statsState.overallStats.overallCompletionRate;
            }

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.auto_awesome,
                    iconColor: AppColors.meditationPurple,
                    value: '$totalHabits',
                    label: 'Habits',
                  ),
                ),
                SizedBox(width: context.spacing(10)),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.calendar_month,
                    iconColor: AppColors.waterBlue,
                    value: '$daysTracked',
                    label: 'Days',
                  ),
                ),
                SizedBox(width: context.spacing(10)),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.local_fire_department,
                    iconColor: AppColors.readOrange,
                    value: '$bestStreak',
                    label: 'Best Streak',
                  ),
                ),
                SizedBox(width: context.spacing(10)),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.pie_chart_rounded,
                    iconColor: AppColors.yogaGreen,
                    value: '${completionRate.toInt()}%',
                    label: 'Done',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.spacing(14),
        horizontal: context.spacing(6),
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: context.fontSize(22)),
          SizedBox(height: context.spacing(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: context.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: context.spacing(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.fontSize(11),
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── ACHIEVEMENTS ────────────────────────────────────────────────────

  Widget _buildAchievements(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, statsState) {
        return BlocBuilder<HabitBloc, HabitState>(
          builder: (context, habitState) {
            int totalHabits = 0;
            int bestStreak = 0;
            double completionRate = 0;
            int daysTracked = 0;

            if (habitState is HabitsLoaded) {
              totalHabits = habitState.habits.length;
            }
            if (statsState is StatisticsLoaded) {
              bestStreak = statsState.overallStats.bestStreak;
              completionRate = statsState.overallStats.overallCompletionRate;
              daysTracked = statsState.overallStats.daysTracked;
            }

            final achievements = [
              _Achievement(
                icon: Icons.add_circle_outline,
                title: 'First Step',
                subtitle: 'Created your first habit',
                unlocked: totalHabits >= 1,
                color: AppColors.yogaGreen,
              ),
              _Achievement(
                icon: Icons.local_fire_department,
                title: '7-Day Streak',
                subtitle: 'Maintained a 7-day streak',
                unlocked: bestStreak >= 7,
                color: AppColors.readOrange,
              ),
              _Achievement(
                icon: Icons.emoji_events,
                title: '30-Day Streak',
                subtitle: 'Maintained a 30-day streak',
                unlocked: bestStreak >= 30,
                color: AppColors.walkYellow,
              ),
              _Achievement(
                icon: Icons.star_rounded,
                title: 'Perfect Day',
                subtitle: 'Completed all habits in a day',
                unlocked: completionRate >= 100,
                color: AppColors.meditationPurple,
              ),
              _Achievement(
                icon: Icons.auto_awesome,
                title: 'Habit Collector',
                subtitle: 'Created 5 habits',
                unlocked: totalHabits >= 5,
                color: AppColors.waterBlue,
              ),
              _Achievement(
                icon: Icons.calendar_today,
                title: 'Dedicated',
                subtitle: 'Tracked for 30 days',
                unlocked: daysTracked >= 30,
                color: AppColors.gymRed,
              ),
            ];

            return Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: achievements.asMap().entries.map((entry) {
                  final i = entry.key;
                  final a = entry.value;
                  return Column(
                    children: [
                      _buildAchievementTile(context, a),
                      if (i < achievements.length - 1)
                        Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.06),
                          indent: 68,
                        ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementTile(BuildContext context, _Achievement a) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: a.unlocked
              ? a.color.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          a.icon,
          color: a.unlocked
              ? a.color
              : AppColors.textTertiary,
          size: 22,
        ),
      ),
      title: Text(
        a.title,
        style: TextStyle(
          fontSize: context.fontSize(14),
          fontWeight: FontWeight.w600,
          color: a.unlocked ? Colors.white : AppColors.textTertiary,
        ),
      ),
      subtitle: Text(
        a.subtitle,
        style: TextStyle(
          fontSize: context.fontSize(12),
          color: a.unlocked
              ? AppColors.textSecondary
              : AppColors.textTertiary,
        ),
      ),
      trailing: a.unlocked
          ? Icon(Icons.check_circle, color: a.color, size: 22)
          : Icon(Icons.lock_outline, color: AppColors.textTertiary, size: 20),
    );
  }

  // ─── SETTINGS ────────────────────────────────────────────────────────

   Widget _buildSettingsSection(BuildContext context, ProfileLoaded profileState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingToggle(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            value: profileState.notificationsEnabled,
            onChanged: (v) {
              context.read<ProfileBloc>().add(ToggleNotificationsEvent(v));
              if (v) {
                _showSnack(context, 'Notifications enabled');
              } else {
                _showSnack(context, 'Notifications disabled');
              }
            },
          ),
          _divider(),
          _buildSettingToggle(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            value: profileState.darkModeEnabled,
            onChanged: (v) {
              context.read<ProfileBloc>().add(ToggleDarkModeEvent(v));
              _showSnack(context, 'Theme preference saved');
            },
          ),
          _divider(),
          _buildSettingTile(
            context,
            icon: Icons.download_outlined,
            title: 'Export Data',
            onTap: () => _showSnack(context, 'Export feature coming soon!'),
          ),
          _divider(),
          _buildSettingTile(
            context,
            icon: Icons.cloud_upload_outlined,
            title: 'Backup & Restore',
            onTap: () => _showSnack(context, 'Backup & Restore coming soon!'),
          ),
        ],
      ),
    );
  }
  // ─── ABOUT ───────────────────────────────────────────────────────────

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'Version',
            trailing: Text(
              AppConstants.appVersion,
              style: TextStyle(
                fontSize: context.fontSize(14),
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _divider(),
          _buildSettingTile(
            context,
            icon: Icons.star_outline,
            title: 'Rate App',
            onTap: () => _showSnack(context, 'Thanks for the love! ❤️'),
          ),
          _divider(),
          _buildSettingTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _showSnack(context, 'Privacy Policy coming soon'),
          ),
          _divider(),
          _buildSettingTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () =>
                _showSnack(context, 'Terms of Service coming soon'),
          ),
        ],
      ),
    );
  }

  // ─── DANGER ZONE ─────────────────────────────────────────────────────

  Widget _buildDangerZone(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: context.fontSize(15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(8)),
          Text(
            'This will permanently delete all your habits and tracking data.',
            style: TextStyle(
              fontSize: context.fontSize(13),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: context.spacing(12)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text('Reset All Data'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────────────────

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: context.fontSize(14),
          color: Colors.white,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildSettingToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: context.fontSize(14),
          color: Colors.white,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceVariant,
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.06),
      indent: 56,
    );
  }

  // ─── DIALOGS & SNACKBAR ──────────────────────────────────────────────

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

   void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: AppConstants.habitNameMaxLength,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Your name',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            counterStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                context.read<ProfileBloc>().add(UpdateNameEvent(newName));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Reset All Data', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Are you sure? This action cannot be undone. All habits and tracking history will be permanently deleted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HiveSetup.clearAll();
              if (mounted) {
                context.read<HabitBloc>().add(const LoadActiveHabitsEvent());
                context
                    .read<StatisticsBloc>()
                    .add(const RefreshStatisticsEvent());
                _showSnack(context, 'All data has been reset');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}

// ─── MODELS ──────────────────────────────────────────────────────────────

class _Achievement {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool unlocked;
  final Color color;

  const _Achievement({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.unlocked,
    required this.color,
  });
}
