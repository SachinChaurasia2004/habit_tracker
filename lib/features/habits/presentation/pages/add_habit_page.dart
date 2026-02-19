import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/responsive.dart';
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
  Color get _selectedColor => AppColors.habitColors[_selectedColorIndex];

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

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final colorCode = _selectedColor.value;

    if (_isEditMode) {
      context.read<HabitBloc>().add(UpdateHabitEvent(
            habitId: widget.habit!.id,
            name: name,
            iconName: _selectedIcon,
            colorCode: colorCode,
          ));
    } else {
      context.read<HabitBloc>().add(CreateHabitEvent(
            name: name,
            iconName: _selectedIcon,
            colorCode: colorCode,
          ));
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

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.pagePadding;
    final isTablet = context.isTabletOrLarger;

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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: isTablet
                    ? _TabletLayout(
                        nameController: _nameController,
                        selectedIcon: _selectedIcon,
                        selectedColorIndex: _selectedColorIndex,
                        selectedColor: _selectedColor,
                        isEditMode: _isEditMode,
                        onIconSelected: (icon) =>
                            setState(() => _selectedIcon = icon),
                        onColorSelected: (index) =>
                            setState(() => _selectedColorIndex = index),
                        onNameChanged: () => setState(() {}),
                        onSave: _saveHabit,
                      )
                    : _PhoneLayout(
                        nameController: _nameController,
                        selectedIcon: _selectedIcon,
                        selectedColorIndex: _selectedColorIndex,
                        selectedColor: _selectedColor,
                        isEditMode: _isEditMode,
                        onIconSelected: (icon) =>
                            setState(() => _selectedIcon = icon),
                        onColorSelected: (index) =>
                            setState(() => _selectedColorIndex = index),
                        onNameChanged: () => setState(() {}),
                        onSave: _saveHabit,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layouts
// ---------------------------------------------------------------------------

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({
    required this.nameController,
    required this.selectedIcon,
    required this.selectedColorIndex,
    required this.selectedColor,
    required this.isEditMode,
    required this.onIconSelected,
    required this.onColorSelected,
    required this.onNameChanged,
    required this.onSave,
  });

  final TextEditingController nameController;
  final String selectedIcon;
  final int selectedColorIndex;
  final Color selectedColor;
  final bool isEditMode;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onNameChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Habit Name'),
        SizedBox(height: context.spacing(12)),
        HabitNameField(controller: nameController, onChanged: onNameChanged),
        SizedBox(height: context.spacing(32)),
        const SectionLabel('Choose an Icon'),
        SizedBox(height: context.spacing(12)),
        HabitIconSelector(selected: selectedIcon, onSelected: onIconSelected),
        SizedBox(height: context.spacing(32)),
        const SectionLabel('Choose a Color'),
        SizedBox(height: context.spacing(12)),
        HabitColorSelector(
            selectedIndex: selectedColorIndex, onSelected: onColorSelected),
        SizedBox(height: context.spacing(32)),
        const SectionLabel('Preview'),
        SizedBox(height: context.spacing(12)),
        HabitPreviewCard(
            name: nameController.text,
            iconName: selectedIcon,
            color: selectedColor),
        SizedBox(height: context.spacing(32)),
        HabitSaveButton(isEditMode: isEditMode, onPressed: onSave),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.nameController,
    required this.selectedIcon,
    required this.selectedColorIndex,
    required this.selectedColor,
    required this.isEditMode,
    required this.onIconSelected,
    required this.onColorSelected,
    required this.onNameChanged,
    required this.onSave,
  });

  final TextEditingController nameController;
  final String selectedIcon;
  final int selectedColorIndex;
  final Color selectedColor;
  final bool isEditMode;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onNameChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column — name, icon, color
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Habit Name'),
              SizedBox(height: context.spacing(12)),
              HabitNameField(
                  controller: nameController, onChanged: onNameChanged),
              SizedBox(height: context.spacing(32)),
              const SectionLabel('Choose an Icon'),
              SizedBox(height: context.spacing(12)),
              HabitIconSelector(
                  selected: selectedIcon, onSelected: onIconSelected),
              SizedBox(height: context.spacing(32)),
              const SectionLabel('Choose a Color'),
              SizedBox(height: context.spacing(12)),
              HabitColorSelector(
                  selectedIndex: selectedColorIndex,
                  onSelected: onColorSelected),
            ],
          ),
        ),

        SizedBox(width: context.spacing(32)),

        // Right column — preview + save
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Preview'),
              SizedBox(height: context.spacing(12)),
              HabitPreviewCard(
                  name: nameController.text,
                  iconName: selectedIcon,
                  color: selectedColor),
              SizedBox(height: context.spacing(32)),
              HabitSaveButton(isEditMode: isEditMode, onPressed: onSave),
            ],
          ),
        ),
      ],
    );
  }
}