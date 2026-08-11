import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/streak_notification_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileInitial || state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = switch (state) {
            ProfileLoaded loaded => loaded.profile,
            ProfileUpdating updating => updating.profile,
            ProfileError error => error.profile,
            _ => null,
          };
          if (profile == null) return _retryButton(context);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state is ProfileUpdating) const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: _ProfileAvatar(avatar: profile.avatarPath, size: 56),
                  title: Text(profile.name),
                  subtitle: const Text('Tap to choose an avatar'),
                  trailing: const Icon(Icons.edit_rounded),
                  onTap: () => _editAvatar(context, profile.avatarPath),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Joined'),
                  subtitle: Text(
                    '${profile.joinDate.day}/${profile.joinDate.month}/${profile.joinDate.year}',
                  ),
                ),
              ),
              Card(
                child: SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Habit reminders and streak milestones'),
                  value: profile.notificationsEnabled,
                  onChanged: (value) => _toggleNotifications(context, value),
                ),
              ),
              Card(
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use the app’s dark colour scheme'),
                  value: profile.darkModeEnabled,
                  onChanged: (value) => context.read<ProfileBloc>().add(
                    ToggleDarkModeEvent(value),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _confirmReset(context),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset profile'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _retryButton(BuildContext context) => Center(
    child: ElevatedButton(
      onPressed: () =>
          context.read<ProfileBloc>().add(const LoadProfileEvent()),
      child: const Text('Retry'),
    ),
  );

  Future<void> _editAvatar(BuildContext context, String? currentAvatar) async {
    const avatars = ['🙂', '😄', '🌟', '🔥', '🎯', '💪', '🌱', '🚀'];
    final selectedAvatar = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final avatar in avatars)
                ChoiceChip(
                  label: Text(avatar, style: const TextStyle(fontSize: 24)),
                  selected: avatar == currentAvatar,
                  onSelected: (_) => Navigator.pop(context, avatar),
                ),
              ActionChip(
                avatar: const Icon(Icons.person_outline),
                label: const Text('Default'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || selectedAvatar == currentAvatar) return;
    context.read<ProfileBloc>().add(UpdateAvatarEvent(selectedAvatar));
  }

  Future<void> _toggleNotifications(BuildContext context, bool enabled) async {
    var notificationsEnabled = enabled;
    if (enabled) {
      notificationsEnabled = await StreakNotificationService()
          .requestPermissions();
    }
    if (!context.mounted) return;

    context.read<ProfileBloc>().add(
      ToggleNotificationsEvent(notificationsEnabled),
    );
    if (enabled && !notificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission was not granted.'),
        ),
      );
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset profile?'),
        content: const Text(
          'This resets your name, avatar, and preferences. Your habits are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (shouldReset == true && context.mounted) {
      context.read<ProfileBloc>().add(const ResetProfileEvent());
    }
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatar, required this.size});

  final String? avatar;
  final double size;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    child: avatar == null
        ? Icon(Icons.person, size: size * .5)
        : Text(avatar!, style: TextStyle(fontSize: size * .48)),
  );
}
