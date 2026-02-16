import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/habit.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';

class AddHabitPage extends StatefulWidget {
  final Habit? habit; // For editing existing habit

  const AddHabitPage({Key? key, this.habit}) : super(key: key);

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedIcon = 'yoga';
  int _selectedColorIndex = 0;

  bool get isEditMode => widget.habit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.habit!.name;
      _selectedIcon = widget.habit!.iconName;
      _selectedColorIndex = AppColors.habitColors.indexWhere(
        (color) => color.value == widget.habit!.colorCode,
      );
      if (_selectedColorIndex == -1) _selectedColorIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Habit' : 'New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Habit created successfully!')),
            );
            Navigator.pop(context);
          } else if (state is HabitUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Habit updated successfully!')),
            );
            Navigator.pop(context);
          } else if (state is HabitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Habit Name
                Text(
                  'Habit Name',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Morning Yoga',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a habit name';
                    }
                    if (value.length > AppConstants.habitNameMaxLength) {
                      return 'Name too long (max ${AppConstants.habitNameMaxLength} characters)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Icon Selection
                Text(
                  'Choose an Icon',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildIconSelector(),

                const SizedBox(height: 32),

                // Color Selection
                Text(
                  'Choose a Color',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildColorSelector(),

                const SizedBox(height: 32),

                // Preview Card
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildPreview(),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<HabitBloc, HabitState>(
                    builder: (context, state) {
                      final isLoading = state is HabitLoading;
                      
                      return ElevatedButton(
                        onPressed: isLoading ? null : _saveHabit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(isEditMode ? 'Update Habit' : 'Create Habit'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: AppConstants.habitIcons.length,
      itemBuilder: (context, index) {
        final icon = AppConstants.habitIcons[index];
        final isSelected = _selectedIcon == icon;

        return InkWell(
          onTap: () => setState(() => _selectedIcon = icon),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                _getIconData(icon),
                size: 32,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        AppColors.habitColors.length,
        (index) {
          final color = AppColors.habitColors[index];
          final isSelected = _selectedColorIndex == index;

          return InkWell(
            onTap: () => setState(() => _selectedColorIndex = index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 28,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.habitColors[_selectedColorIndex].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconData(_selectedIcon),
              color: AppColors.habitColors[_selectedColorIndex],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty 
                      ? 'Habit Name' 
                      : _nameController.text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                const Text(
                  '0 Day Streak',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'yoga':
        return Icons.self_improvement;
      case 'water':
        return Icons.water_drop;
      case 'book':
        return Icons.menu_book;
      case 'gym':
        return Icons.fitness_center;
      case 'meditation':
        return Icons.spa;
      case 'walk':
        return Icons.directions_walk;
      case 'sleep':
        return Icons.bedtime;
      case 'nutrition':
        return Icons.restaurant;
      default:
        return Icons.check_circle_outline;
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      if (isEditMode) {
        context.read<HabitBloc>().add(
              UpdateHabitEvent(
                habitId: widget.habit!.id,
                name: _nameController.text.trim(),
                iconName: _selectedIcon,
                colorCode: AppColors.habitColors[_selectedColorIndex].value,
              ),
            );
      } else {
        context.read<HabitBloc>().add(
              CreateHabitEvent(
                name: _nameController.text.trim(),
                iconName: _selectedIcon,
                colorCode: AppColors.habitColors[_selectedColorIndex].value,
              ),
            );
      }
    }
  }
}