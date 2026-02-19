import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/habit.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../widgets/add_habit_color_selector.dart';
import '../widgets/add_habit_icon_selector.dart';
import '../widgets/add_habit_name_field.dart';
import '../widgets/add_habit_preview_card.dart';
import '../widgets/add_habit_save_button.dart';
import '../widgets/add_section_label.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key, this.habit});

  final Habit? habit;

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late String _selectedIcon;
  late int _selectedColorIndex;

  bool get _isEditMode => widget.habit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.habit!.name;
      _selectedIcon = widget.habit!.iconName;
      _selectedColorIndex = _indexOfColor(widget.habit!.colorCode);
    } else {
      _selectedIcon = AppConstants.habitIcons.first;
      _selectedColorIndex = 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int _indexOfColor(int colorCode) {
    final index = AppColors.habitColors.indexWhere((c) => c.value == colorCode);
    return index == -1 ? 0 : index;
  }

  Color get _selectedColor => AppColors.habitColors[_selectedColorIndex];

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final colorCode = _selectedColor.value;

    if (_isEditMode) {
      context.read<HabitBloc>().add(
        UpdateHabitEvent(
          habitId: widget.habit!.id,
          name: name,
          iconName: _selectedIcon,
          colorCode: colorCode,
        ),
      );
    } else {
      context.read<HabitBloc>().add(
        CreateHabitEvent(
          name: name,
          iconName: _selectedIcon,
          colorCode: colorCode,
        ),
      );
    }
  }

  void _onStateChanged(BuildContext context, HabitState state) {
    if (state is HabitCreated) {
      _showSnackBar(context, 'Habit created successfully!');
      Navigator.pop(context);
    } else if (state is HabitUpdated) {
      _showSnackBar(context, 'Habit updated successfully!');
      Navigator.pop(context);
    } else if (state is HabitError) {
      _showSnackBar(context, state.message, isError: true);
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Habit' : 'New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<HabitBloc, HabitState>(
        listener: _onStateChanged,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Habit Name'),
                const SizedBox(height: 12),
                HabitNameField(
                  controller: _nameController,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 32),
                const SectionLabel('Choose an Icon'),
                const SizedBox(height: 12),
                HabitIconSelector(
                  selected: _selectedIcon,
                  onSelected: (icon) => setState(() => _selectedIcon = icon),
                ),
                const SizedBox(height: 32),
                const SectionLabel('Choose a Color'),
                const SizedBox(height: 12),
                HabitColorSelector(
                  selectedIndex: _selectedColorIndex,
                  onSelected: (index) =>
                      setState(() => _selectedColorIndex = index),
                ),
                const SizedBox(height: 32),
                const SectionLabel('Preview'),
                const SizedBox(height: 12),
                HabitPreviewCard(
                  name: _nameController.text,
                  iconName: _selectedIcon,
                  color: _selectedColor,
                ),
                const SizedBox(height: 32),
                HabitSaveButton(isEditMode: _isEditMode, onPressed: _saveHabit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
