import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_event.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../widgets/daily_goals_card.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/delete_habit_dialog_box.dart';
import '../widgets/habits_section_header.dart';
import '../widgets/habits_sliver_list.dart';
import '../widgets/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateHelper.normalize(DateTime.now());
    _loadData();
  }

  void _loadData() {
    context.read<HabitBloc>().add(const LoadActiveHabitsEvent());
    context.read<TrackingBloc>().add(LoadDateTrackingEvent(_currentDate));
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _currentDate = DateHelper.normalize(newDate));
    context.read<TrackingBloc>().add(LoadDateTrackingEvent(newDate));
  }

  void _onHabitStateChanged(BuildContext context, HabitState state) {
    if (state is HabitCreated ||
        state is HabitUpdated ||
        state is HabitDeleted) {
      context.read<TrackingBloc>().add(LoadDateTrackingEvent(_currentDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: BlocListener<HabitBloc, HabitState>(
            listener: _onHabitStateChanged,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: HomeHeader()),
                SliverToBoxAdapter(
                  child: DateSelectorWidget(
                    currentDate: _currentDate,
                    onDateChanged: _onDateChanged,
                  ),
                ),
                const SliverToBoxAdapter(child: DailyGoalsCard()),
                SliverToBoxAdapter(
                  child: HabitsSectionHeader(date: _currentDate),
                ),
                HabitsSliverList(
                  currentDate: _currentDate,
                  onDeleteRequested: (ctx, id) =>
                      DeleteHabitDialog.show(ctx, id),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}