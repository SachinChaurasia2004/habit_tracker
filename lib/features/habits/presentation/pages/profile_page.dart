import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).padding.bottom + 90,
        ),
        children: [
          // Profile Header
          _buildProfileHeader(),

          const SizedBox(height: 24),

          // Settings
          _buildSettingsSection(context),

          const SizedBox(height: 24),

          // About
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),

          const SizedBox(height: 16),

          // Name
          const Text(
            'Sachin',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Join date
          Text(
            'Member since Jan 2026',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // Edit button
          OutlinedButton(
            onPressed: () {
              // TODO: Edit profile
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.download,
            title: 'Export Data',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.backup,
            title: 'Backup & Restore',
            onTap: () {},
          ),
          _buildSettingItem(icon: Icons.palette, title: 'Theme', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingItem(icon: Icons.info, title: 'About', onTap: () {}),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.star,
            title: 'Rate App',
            onTap: () {},
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.white.withOpacity(0.1), indent: 72),
      ],
    );
  }
}
