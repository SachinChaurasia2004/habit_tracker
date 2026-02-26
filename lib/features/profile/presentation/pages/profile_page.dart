import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            _ => null,
          };

          if (profile == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () =>
                    context.read<ProfileBloc>().add(const LoadProfileEvent()),
                child: const Text('Retry'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state is ProfileUpdating) const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  title: const Text('Name'),
                  subtitle: Text(profile.name),
                  trailing: const Icon(Icons.edit_rounded),
                  onTap: () => _editName(context, profile.name),
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
                  value: profile.notificationsEnabled,
                  onChanged: (value) => context
                      .read<ProfileBloc>()
                      .add(ToggleNotificationsEvent(value)),
                ),
              ),
              Card(
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: profile.darkModeEnabled,
                  onChanged: (value) =>
                      context.read<ProfileBloc>().add(ToggleDarkModeEvent(value)),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () =>
                    context.read<ProfileBloc>().add(const ResetProfileEvent()),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset Profile'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value == null || value.isEmpty || value == currentName) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    context.read<ProfileBloc>().add(UpdateNameEvent(value));
  }
}
